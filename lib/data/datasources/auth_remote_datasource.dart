import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:cashwave_mobile/core/constants/variables.dart';
import 'package:cashwave_mobile/data/datasources/auth_local_datasource.dart';
import 'package:cashwave_mobile/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  /// 🔑 LOGIN
  Future<Either<String, AuthResponseModel>> login(
      String email,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/login'),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(AuthResponseModel.fromMap(data));
      } else {
        // coba decode isi error untuk menampilkan pesan
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? 'Login gagal';
          return left(message);
        } catch (_) {
          return left('Login gagal: ${response.body}');
        }
      }
    } catch (e) {
      return left('Connection error: $e');
    }
  }

  /// 🚪 LOGOUT
  Future<Either<String, String>> logout() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();

      // ✅ Cek apakah authData atau token-nya null atau kosong
      final token = authData?.token;
      if (token == null || token.isEmpty) {
        return left('Token tidak ditemukan, silakan login dulu.');
      }

      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return right('Logout berhasil');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? 'Logout gagal';
          return left(message);
        } catch (_) {
          return left('Logout gagal: ${response.body}');
        }
      }
    } catch (e) {
      return left('Connection error: $e');
    }
  }
}
