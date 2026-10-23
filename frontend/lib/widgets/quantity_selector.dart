import 'package:flutter/material.dart';

// [-]  1  [+]
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const QuantitySelector({super.key, required this.quantity, this.onMinus, this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(onPressed: onMinus, icon: const Icon(Icons.remove)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        IconButton.outlined(onPressed: onPlus, icon: const Icon(Icons.add)),
      ],
    );
  }
}
