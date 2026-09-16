import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import 'package:cashwave_mobile/core/constants/variables.dart';
import 'package:cashwave_mobile/data/models/response/dashboard_response_model.dart';
import 'auth_local_datasource.dart';

class DashboardRemoteDatasource {
  Future<Either<String, DashboardResponseModel>> getDashboard() async {
    try {
      final token = await AuthLocalDatasource().getToken();

      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return right(DashboardResponseModel.fromJson(response.body));
      } else if (response.statusCode == 401) {
        return left("Unauthenticated, login dulu.");
      } else {
        return left("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      return left("Connection error: $e");
    }
  }
}
