import 'package:flutter/material.dart';

import 'cart_screen.dart';
import 'consumer_home_screen.dart';
import 'orders_screen.dart';
import '../shared/profile_screen.dart';

// Holds the bottom NavigationBar: Home, Cart, Orders, Profile
class ConsumerShell extends StatefulWidget {
  const ConsumerShell({super.key});

  @override
  State<ConsumerShell> createState() => _ConsumerShellState();
}

class _ConsumerShellState extends State<ConsumerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Only the selected page is built, so each tab reloads fresh data when opened
    final pages = [
      const ConsumerHomeScreen(),
      CartScreen(onOrderPlaced: () => setState(() => _index = 2)),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
