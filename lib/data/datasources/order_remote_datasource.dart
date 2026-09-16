import 'dart:convert';

import 'package:cashwave_mobile/core/constants/variables.dart';
import 'package:cashwave_mobile/data/models/request/order_request_model.dart';
import 'package:http/http.dart' as http;

import 'auth_local_datasource.dart';

class OrderRemoteDatasource {
  Future<bool> sendOrder(OrderRequestModel requestModel) async {
    try {
      // Ambil token login
      final authData = await AuthLocalDatasource().getAuthData();
      final token = authData?.token;

      if (token == null || token.isEmpty) {
        print('⚠️ Token tidak ditemukan, silakan login terlebih dahulu.');
        return false;
      }

      // Header request
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      // Data order
      final jsonBody = jsonEncode(requestModel.toMap());

      print('📦 Mengirim order...');
      print('URL: ${Variables.baseUrl}/orders');
      print('Body: $jsonBody');

      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/orders'),
        headers: headers,
        body: jsonBody,
      );

      print('📡 Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Order berhasil disimpan');
        return true;
      }

      print('❌ Order gagal disimpan');
      return false;
    } catch (e) {
      print('❌ Gagal mengirim order: $e');
      return false;
    }
  }
}
