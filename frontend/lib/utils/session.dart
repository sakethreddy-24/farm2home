import 'package:shared_preferences/shared_preferences.dart';

// Holds the logged-in user's details and stores them on the phone.
class Session {
  static String? token;
  static int id = 0;
  static String name = '';
  static String email = '';
  static String phone = '';
  static String role = '';

  static bool get isLoggedIn => token != null;

  static Future<void> save(Map<String, dynamic> data) async {
    token = data['token'];
    id = data['id'];
    name = data['name'];
    email = data['email'];
    phone = data['phone'];
    role = data['role'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token!);
    await prefs.setInt('id', id);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
    await prefs.setString('role', role);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    id = prefs.getInt('id') ?? 0;
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    phone = prefs.getString('phone') ?? '';
    role = prefs.getString('role') ?? '';
  }

  static Future<void> clear() async {
    token = null;
    id = 0;
    name = email = phone = role = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
