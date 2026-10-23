import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({super.key, required this.product, required this.onTap, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.green.shade50,
                child: Icon(categoryIcon(product.category), color: primaryGreen, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
                    Text(product.category, style: TextStyle(color: Colors.grey.shade700)),
                    Text('by ${product.farmerName}', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
              FilledButton(
                onPressed: product.quantity > 0 ? onAddToCart : null,
                child: Text(product.quantity > 0 ? 'Add to Cart' : 'Sold out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
