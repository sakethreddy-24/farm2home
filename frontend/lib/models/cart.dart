import 'product.dart';
import '../utils/constants.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

// The cart lives in memory only (no database table).
class Cart {
  static final List<CartItem> items = [];

  static void add(Product product, int qty) {
    final index = items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      // Do not go above the available stock
      final newQty = items[index].quantity + qty;
      items[index].quantity = newQty > product.quantity ? product.quantity : newQty;
    } else {
      items.add(CartItem(product: product, quantity: qty));
    }
  }

  static void remove(CartItem item) => items.remove(item);

  static void clear() => items.clear();

  static double get subtotal =>
      items.fold(0, (sum, i) => sum + i.product.price * i.quantity);

  static double get total => items.isEmpty ? 0 : subtotal + deliveryFee;
}
