import 'package:flutter/material.dart';

import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/session.dart';
import '../../widgets/product_card.dart';
import 'product_details_screen.dart';

class ConsumerHomeScreen extends StatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  State<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  int _requestId = 0; // ignores old responses while the user keeps typing

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await ApiService.getProducts(search: _searchController.text.trim());
      if (!mounted || id != _requestId) return;
      setState(() => _products = products);
    } on ApiException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() => _error = e.message);
    }
    if (mounted && id == _requestId) setState(() => _loading = false);
  }

  void _addToCart(Product p) {
    setState(() => Cart.add(p, 1));
    showMessage(context, '${p.name} added to cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm2Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${Session.name} 👋',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Fresh products from local farmers 🌱', style: TextStyle(color: primaryGreen)),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _load();
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_products.isEmpty) return const Center(child: Text('No products found'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, i) {
          final p = _products[i];
          return ProductCard(
            product: p,
            onAddToCart: () => _addToCart(p),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: p.id)),
            ),
          );
        },
      ),
    );
  }
}
