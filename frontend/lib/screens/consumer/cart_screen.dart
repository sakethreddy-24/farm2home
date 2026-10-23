import 'package:flutter/material.dart';

import '../../models/cart.dart';
import '../../utils/constants.dart';
import '../../widgets/quantity_selector.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  // Called after an order is placed so the shell can open the Orders tab
  final VoidCallback onOrderPlaced;

  const CartScreen({super.key, required this.onOrderPlaced});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _checkout() async {
    final placed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
    if (placed == true) widget.onOrderPlaced();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: Cart.items.map(_itemCard).toList(),
                  ),
                ),
                _summary(),
              ],
            ),
    );
  }

  Widget _itemCard(CartItem item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('₹${item.product.price.toStringAsFixed(0)} each'),
                  Text('Quantity: ${item.quantity}'),
                  TextButton.icon(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: Colors.red),
                    onPressed: () => setState(() => Cart.remove(item)),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            ),
            QuantitySelector(
              quantity: item.quantity,
              onMinus: item.quantity > 1 ? () => setState(() => item.quantity--) : null,
              onPlus: item.quantity < item.product.quantity ? () => setState(() => item.quantity++) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
      ),
      child: Column(
        children: [
          _line('Subtotal', Cart.subtotal),
          _line('Delivery Fee', deliveryFee),
          const Divider(),
          _line('Total', Cart.total, bold: true),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(onPressed: _checkout, child: const Text('Proceed to Checkout')),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, double amount, {bool bold = false}) {
    final style = TextStyle(fontSize: bold ? 18 : 15, fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text('₹${amount.toStringAsFixed(0)}', style: style)],
      ),
    );
  }
}
