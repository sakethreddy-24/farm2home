import 'package:flutter/material.dart';

import 'farmer_dashboard_screen.dart';
import 'farmer_orders_screen.dart';
import 'my_products_screen.dart';
import '../shared/profile_screen.dart';

// Holds the bottom NavigationBar: Dashboard, Products, Orders, Profile
class FarmerShell extends StatefulWidget {
  const FarmerShell({super.key});

  @override
  State<FarmerShell> createState() => _FarmerShellState();
}

class _FarmerShellState extends State<FarmerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      FarmerDashboardScreen(onGoToTab: (i) => setState(() => _index = i)),
      const MyProductsScreen(),
      const FarmerOrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
