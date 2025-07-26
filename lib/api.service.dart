import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://cashwave.my.id/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil produk: ${response.body}');
    }
  }
}