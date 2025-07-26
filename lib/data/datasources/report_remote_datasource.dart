import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/variables.dart';
import '../models/response/product_sales_report.dart';
import '../models/response/summary_response_model.dart';
import 'auth_local_datasource.dart';

class ReportRemoteDatasource {
  /// 🔹 GET Summary Report
  Future<Either<String, SummaryResponseModel>> getSummary(
      String startDate, String endDate) async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      final token = authData?.token;

      if (token == null || token.isEmpty) {
        return left('Token tidak ditemukan, silakan login terlebih dahulu.');
      }

      final response = await http.get(
        Uri.parse(
          '${Variables.baseUrl}/api/reports/summary?start_date=$startDate&end_date=$endDate',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return right(SummaryResponseModel.fromJson(response.body));
      } else {
        return left('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return left('Connection error: $e');
    }
  }

  /// 🔹 GET Product Sales
  Future<Either<String, ProductSalesResponseModel>> getProductSales(
      String startDate, String endDate) async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      final token = authData?.token;

      if (token == null || token.isEmpty) {
        return left('Token tidak ditemukan, silakan login terlebih dahulu.');
      }

      final response = await http.get(
        Uri.parse(
          '${Variables.baseUrl}/api/reports/product-sales?start_date=$startDate&end_date=$endDate',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return right(ProductSalesResponseModel.fromJson(response.body));
      } else {
        return left('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return left('Connection error: $e');
    }
  }

  /// 🔹 Close Cashier
  Future<Either<String, String>> closeCashier() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      final token = authData?.token;

      if (token == null || token.isEmpty) {
        return left('Token tidak ditemukan, silakan login terlebih dahulu.');
      }

      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/reports/close-cashier'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return right('Success');
      } else {
        return left('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return left('Connection error: $e');
    }
  }
}
