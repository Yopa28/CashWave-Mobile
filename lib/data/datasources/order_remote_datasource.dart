import 'dart:convert';
import 'package:cashwave_mobile/core/constants/variables.dart';
import 'package:cashwave_mobile/data/models/request/order_request_model.dart';
import 'package:http/http.dart' as http;

import 'auth_local_datasource.dart';

class OrderRemoteDatasource {
  Future<bool> sendOrder(OrderRequestModel requestModel) async {
    try {
      // Ambil data auth
      final authData = await AuthLocalDatasource().getAuthData();
      final token = authData?.token;

      // Pastikan token tersedia
      if (token == null || token.isEmpty) {
        print('⚠️ Token tidak ditemukan, silakan login dulu.');
        return false;
      }

      // Siapkan header
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      // Buat JSON body
      final jsonBody = jsonEncode(requestModel.toMap());

      print('📦 Request body: $jsonBody');

      // Kirim POST
      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/api/orders'),
        headers: headers,
        body: jsonBody,
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Error mengirim order: $e');
      return false;
    }
  }
}
