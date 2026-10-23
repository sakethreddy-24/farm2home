const router = require('express').Router();
const { verifyToken, requireRole } = require('../middleware/auth');
const c = require('../controllers/orderController');

router.post('/', verifyToken, requireRole('consumer'), c.placeOrder);
router.get('/my-orders', verifyToken, c.getMyOrders);

module.exports = router;
