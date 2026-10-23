import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/session.dart';

// Shared by consumer and farmer
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: primaryGreen,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(Session.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.email), title: Text(Session.email)),
                  ListTile(leading: const Icon(Icons.phone), title: Text(Session.phone)),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(Session.role == 'farmer' ? 'Farmer' : 'Consumer'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: ApiService.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
