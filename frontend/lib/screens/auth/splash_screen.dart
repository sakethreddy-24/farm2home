import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/session.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  // Wait 2 seconds, then go to Home (if already logged in) or Login
  Future<void> _start() async {
    await Session.load();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (Session.isLoggedIn) {
      goToHome(context);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: primaryGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, size: 90, color: Colors.white),
            SizedBox(height: 16),
            Text('Farm2Home',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 6),
            Text('Fresh from the farm to your home', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
