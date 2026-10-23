import 'package:flutter/material.dart';

import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/quantity_selector.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? _product;
  String? _error;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ApiService.getProduct(widget.productId);
      if (mounted) setState(() => _product = p);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  void _addToCart() {
    Cart.add(_product!, _qty);
    showMessage(context, '${_product!.name} added to cart');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: _error != null
          ? Center(child: Text(_error!))
          : p == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.green.shade50,
                        child: Icon(categoryIcon(p.category), size: 60, color: primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(p.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    Text('₹${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, color: primaryGreen, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _row(Icons.person, 'Farmer', p.farmerName),
                    // The database does not store a location, so this is fixed text
                    _row(Icons.location_on, 'Location', 'Local farm'),
                    _row(Icons.category, 'Category', p.category),
                    _row(Icons.inventory_2, 'Available Quantity', '${p.quantity}'),
                    const SizedBox(height: 12),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(p.description.isEmpty ? 'No description' : p.description),
                    const SizedBox(height: 24),
                    if (p.quantity > 0) ...[
                      Center(
                        child: QuantitySelector(
                          quantity: _qty,
                          onMinus: _qty > 1 ? () => setState(() => _qty--) : null,
                          onPlus: _qty < p.quantity ? () => setState(() => _qty++) : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: FilledButton(onPressed: _addToCart, child: const Text('Add to Cart')),
                      ),
                    ] else
                      const Center(child: Text('Out of stock', style: TextStyle(color: Colors.red))),
                  ],
                ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryGreen),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
