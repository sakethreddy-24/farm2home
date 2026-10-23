const db = require('../config/db');

const DELIVERY_FEE = 30;

// Body: { items: [{ product_id, quantity }] }
// Prices are read from the database so the client cannot fake them.
exports.placeOrder = async (req, res) => {
  const { items } = req.body;
  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ message: 'Cart is empty' });
  }

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    let total = 0;
    const lines = [];
    for (const item of items) {
      const qty = parseInt(item.quantity, 10);
      if (!qty || qty < 1) throw { status: 400, message: 'Invalid quantity' };

      const [rows] = await conn.query('SELECT * FROM products WHERE id = ? FOR UPDATE', [
        item.product_id,
      ]);
      if (rows.length === 0) throw { status: 400, message: 'A product no longer exists' };
      const p = rows[0];
      if (p.quantity < qty) {
        throw { status: 400, message: `Only ${p.quantity} of ${p.name} available` };
      }

      total += Number(p.price) * qty;
      lines.push({ id: p.id, qty, price: p.price });
    }
    total += DELIVERY_FEE;

    const [order] = await conn.query(
      'INSERT INTO orders (consumer_id, total_amount, status) VALUES (?, ?, ?)',
      [req.user.id, total, 'Confirmed']
    );
    for (const l of lines) {
      await conn.query(
        'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
        [order.insertId, l.id, l.qty, l.price]
      );
      await conn.query('UPDATE products SET quantity = quantity - ? WHERE id = ?', [l.qty, l.id]);
    }

    await conn.commit();
    res.status(201).json({ message: 'Order placed', order_id: order.insertId });
  } catch (e) {
    await conn.rollback();
    if (e.status) return res.status(e.status).json({ message: e.message });
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  } finally {
    conn.release();
  }
};

// Consumer: their own orders. Farmer: orders containing their products.
exports.getMyOrders = async (req, res) => {
  try {
    const base = `SELECT o.id, o.total_amount, o.status, o.created_at, u.name AS customer_name,
                         oi.quantity, oi.price, p.name AS product_name
                  FROM orders o
                  JOIN users u ON u.id = o.consumer_id
                  JOIN order_items oi ON oi.order_id = o.id
                  JOIN products p ON p.id = oi.product_id`;
    const where = req.user.role === 'farmer' ? 'WHERE p.farmer_id = ?' : 'WHERE o.consumer_id = ?';

    const [rows] = await db.query(`${base} ${where} ORDER BY o.id DESC`, [req.user.id]);

    // Group the flat rows into orders, each with an items list
    const orders = [];
    const byId = {};
    for (const r of rows) {
      if (!byId[r.id]) {
        byId[r.id] = {
          id: r.id,
          total_amount: r.total_amount,
          status: r.status,
          created_at: r.created_at,
          customer_name: r.customer_name,
          items: [],
        };
        orders.push(byId[r.id]);
      }
      byId[r.id].items.push({
        product_name: r.product_name,
        quantity: r.quantity,
        price: r.price,
      });
    }
    res.json(orders);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};
