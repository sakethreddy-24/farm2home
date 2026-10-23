import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/session.dart';
import 'add_product_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  // Switches the bottom navigation tab (1 = Products, 2 = Orders)
  final void Function(int) onGoToTab;

  const FarmerDashboardScreen({super.key, required this.onGoToTab});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int? _productCount;
  int? _orderCount;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final products = await ApiService.getProducts(mine: true);
      final orders = await ApiService.getMyOrders();
      if (!mounted) return;
      setState(() {
        _productCount = products.length;
        _orderCount = orders.length;
      });
    } on ApiException {
      // Stats stay as "-" if the server cannot be reached
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Welcome, Farmer 👨‍🌾', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(Session.name, style: const TextStyle(color: primaryGreen, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statCard('My Products', _productCount, Icons.inventory_2)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Orders', _orderCount, Icons.receipt_long)),
            ],
          ),
          const SizedBox(height: 24),
          _button('Add Product', Icons.add, () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
            _loadStats();
          }),
          _button('My Products', Icons.inventory_2, () => widget.onGoToTab(1)),
          _button('Orders', Icons.receipt_long, () => widget.onGoToTab(2)),
          _button('Logout', Icons.logout, ApiService.logout),
        ],
      ),
    );
  }

  Widget _statCard(String label, int? value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: primaryGreen, size: 32),
            const SizedBox(height: 6),
            Text(value?.toString() ?? '-', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _button(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 48,
        child: FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
      ),
    );
  }
}
