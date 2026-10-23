import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/cart.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../screens/auth/login_screen.dart';
import '../utils/constants.dart';
import '../utils/session.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

// Used to jump to the Login screen from anywhere (e.g. when the token expires)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// All backend calls are in this one class.
class ApiService {
  static Future<dynamic> _request(String method, String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
    };

    http.Response res;
    try {
      switch (method) {
        case 'POST':
          res = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers);
          break;
        default:
          res = await http.get(uri, headers: headers);
      }
    } on SocketException {
      throw ApiException('Cannot reach the server. Is the backend running?');
    } on http.ClientException {
      throw ApiException('Cannot reach the server. Is the backend running?');
    }

    final data = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (res.statusCode >= 400) {
      // Token expired or invalid while logged in -> force logout
      if (res.statusCode == 401 && Session.isLoggedIn) {
        await logout();
      }
      throw ApiException(data is Map && data['message'] != null ? data['message'] : 'Request failed');
    }
    return data;
  }

  static Future<void> logout() async {
    await Session.clear();
    Cart.clear();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ---------- Auth ----------
  static Future<void> register(String name, String email, String phone, String password, String role) async {
    await _request('POST', '/api/auth/register',
        body: {'name': name, 'email': email, 'phone': phone, 'password': password, 'role': role});
  }

  static Future<void> login(String email, String password) async {
    final data = await _request('POST', '/api/auth/login', body: {'email': email, 'password': password});
    await Session.save(data);
  }

  // ---------- Products ----------
  static Future<List<Product>> getProducts({String search = '', bool mine = false}) async {
    final query = Uri(queryParameters: {
      if (search.isNotEmpty) 'search': search,
      if (mine) 'mine': 'true',
    }).query;
    final data = await _request('GET', '/api/products${query.isEmpty ? '' : '?$query'}');
    return (data as List).map((j) => Product.fromJson(j)).toList();
  }

  static Future<Product> getProduct(int id) async {
    final data = await _request('GET', '/api/products/$id');
    return Product.fromJson(data);
  }

  static Future<void> addProduct(
      String name, String description, double price, String category, int quantity) async {
    await _request('POST', '/api/products', body: {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'quantity': quantity,
    });
  }

  static Future<void> deleteProduct(int id) async {
    await _request('DELETE', '/api/products/$id');
  }

  // ---------- Orders ----------
  static Future<void> placeOrder(List<CartItem> items) async {
    await _request('POST', '/api/orders', body: {
      'items': items.map((i) => {'product_id': i.product.id, 'quantity': i.quantity}).toList(),
    });
  }

  static Future<List<Order>> getMyOrders() async {
    final data = await _request('GET', '/api/orders/my-orders');
    return (data as List).map((j) => Order.fromJson(j)).toList();
  }
}
