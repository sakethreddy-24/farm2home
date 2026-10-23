const db = require('../config/db');

// Optional ?search= and ?mine=true (farmer's own products)
exports.getProducts = async (req, res) => {
  try {
    const { search, mine } = req.query;
    let sql = `SELECT p.*, u.name AS farmer_name FROM products p
               JOIN users u ON u.id = p.farmer_id WHERE 1=1`;
    const params = [];

    if (mine === 'true') {
      sql += ' AND p.farmer_id = ?';
      params.push(req.user.id);
    }
    if (search) {
      sql += ' AND (p.name LIKE ? OR p.category LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }
    sql += ' ORDER BY p.id DESC';

    const [rows] = await db.query(sql, params);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getProduct = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT p.*, u.name AS farmer_name FROM products p
       JOIN users u ON u.id = p.farmer_id WHERE p.id = ?`,
      [req.params.id]
    );
    if (rows.length === 0) return res.status(404).json({ message: 'Product not found' });
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.addProduct = async (req, res) => {
  try {
    const { name, description, price, category, quantity } = req.body;
    if (!name || price === undefined || !category || quantity === undefined) {
      return res.status(400).json({ message: 'Name, price, category and quantity are required' });
    }
    if (isNaN(price) || Number(price) <= 0 || isNaN(quantity) || Number(quantity) < 0) {
      return res.status(400).json({ message: 'Invalid price or quantity' });
    }

    // farmer_id comes from the JWT, not from the request body
    const [result] = await db.query(
      'INSERT INTO products (name, description, price, category, quantity, farmer_id) VALUES (?, ?, ?, ?, ?, ?)',
      [name, description || '', price, category, quantity, req.user.id]
    );
    res.status(201).json({ message: 'Product added', id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.deleteProduct = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT farmer_id FROM products WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: 'Product not found' });
    if (rows[0].farmer_id !== req.user.id) {
      return res.status(403).json({ message: 'You can delete only your own products' });
    }

    try {
      await db.query('DELETE FROM products WHERE id = ?', [req.params.id]);
    } catch (e) {
      // Foreign key from order_items: product was already ordered
      if (e.code === 'ER_ROW_IS_REFERENCED_2') {
        return res
          .status(409)
          .json({ message: 'Product is part of existing orders and cannot be deleted' });
      }
      throw e;
    }
    res.json({ message: 'Product deleted' });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};
