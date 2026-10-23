const router = require('express').Router();
const { verifyToken, requireRole } = require('../middleware/auth');
const c = require('../controllers/productController');

router.get('/', verifyToken, c.getProducts);
router.get('/:id', verifyToken, c.getProduct);
router.post('/', verifyToken, requireRole('farmer'), c.addProduct);
router.delete('/:id', verifyToken, requireRole('farmer'), c.deleteProduct);

module.exports = router;
