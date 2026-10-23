import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await ApiService.getMyOrders();
      if (!mounted) return;
      setState(() => _orders = orders);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(child: Text('No orders yet'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _orders.length,
                        itemBuilder: (context, i) => _orderCard(_orders[i]),
                      ),
                    ),
    );
  }

  Widget _orderCard(Order o) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${o.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(formatDate(o.createdAt)),
            const SizedBox(height: 6),
            ...o.items.map((it) => Text('${it.productName} × ${it.quantity}')),
            const SizedBox(height: 6),
            Text('Total: ₹${o.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Status: ${o.status}', style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
