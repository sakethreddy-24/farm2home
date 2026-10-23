import 'package:flutter/material.dart';

import '../../models/cart.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../utils/session.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: Session.name);
  final _phone = TextEditingController(text: Session.phone);
  final _address = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.placeOrder(Cart.items);
      Cart.clear();
      if (!mounted) return;
      showMessage(context, 'Order placed successfully!');
      Navigator.pop(context, true);
      return;
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Delivery Address', prefixIcon: Icon(Icons.home)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter delivery address' : null,
              ),
              const SizedBox(height: 24),
              Text('Order Total: ₹${Cart.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('(includes delivery fee)'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _placeOrder,
                  child: _loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Place Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
