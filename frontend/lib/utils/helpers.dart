import 'package:flutter/material.dart';

import '../screens/consumer/consumer_shell.dart';
import '../screens/farmer/farmer_shell.dart';
import 'session.dart';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

// Consumer -> ConsumerShell, Farmer -> FarmerShell
void goToHome(BuildContext context) {
  final page = Session.role == 'farmer' ? const FarmerShell() : const ConsumerShell();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
}
