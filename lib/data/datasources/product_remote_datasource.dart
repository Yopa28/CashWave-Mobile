import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:cashwave_mobile/core/constants/variables.dart';
import 'package:cashwave_mobile/data/models/request/product_request_model.dart';
import 'package:cashwave_mobile/data/models/response/add_product_response_model.dart';
import 'package:cashwave_mobile/data/models/response/product_response_model.dart';
import 'package:cashwave_mobile/data/models/response/category_response_model.dart';
import 'auth_local_datasource.dart'; // ✅ kita pakai untuk ambil

class ProductRemoteDatasource {
  /// ✅ GET products dengan token
  Future<Either<String, ProductResponseModel>> getProducts() async {
    try {
      final token = await AuthLocalDatasource().getToken();
      final response = await http.get(
        Uri.parse('https://cashwave.my.id/api/products'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return right(ProductResponseModel.fromJson(response.body));
      } else if (response.statusCode == 401) {
        return left("Unauthenticated, login dulu.");
      } else {
        return left("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      return left("Connection error: $e");
    }
  }

  /// ✅ POST tambah product dengan token
  Future<Either<String, AddProductResponseModel>> addProduct(
      ProductRequestModel productRequestModel,
      ) async {
    try {
      final token = await AuthLocalDatasource().getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://cashwave.my.id/api/products'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll(productRequestModel.toMap());

      if (productRequestModel.image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            productRequestModel.image!.path,
          ),
        );
      }

      http.StreamedResponse response = await request.send();
      final String body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return right(AddProductResponseModel.fromJson(body));
      } else if (response.statusCode == 401) {
        return left("Unauthenticated, login dulu.");
      } else {
        return left("Error ${response.statusCode}: $body");
      }
    } catch (e) {
      return left("Upload error: $e");
    }
  }

  /// ✅ GET categories dengan token
  Future<Either<String, CategoryResponseModel>> getCategories() async {
    try {
      final token = await AuthLocalDatasource().getToken();
      final response = await http.get(
        Uri.parse('https://cashwave.my.id/api/products'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return right(CategoryResponseModel.fromJson(response.body));
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