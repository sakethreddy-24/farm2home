import 'package:flutter/material.dart';

// Android emulator reaches the computer's localhost through 10.0.2.2.
// On a physical phone, replace it with your computer's IP, e.g. http://192.168.1.5:5000
const String baseUrl = 'http://10.0.2.2:5000';

const double deliveryFee = 30;

const Color primaryGreen = Color(0xFF2E7D32);

const List<String> categories = ['Vegetables', 'Fruits', 'Leafy Greens', 'Grains', 'Dairy', 'Other'];

// Simple icon per category instead of product images
IconData categoryIcon(String category) {
  switch (category) {
    case 'Fruits':
      return Icons.apple;
    case 'Leafy Greens':
      return Icons.eco;
    case 'Grains':
      return Icons.grass;
    case 'Dairy':
      return Icons.water_drop;
    case 'Vegetables':
      return Icons.local_florist;
    default:
      return Icons.shopping_basket;
  }
}

String formatDate(String iso) {
  final d = DateTime.parse(iso).toLocal();
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
