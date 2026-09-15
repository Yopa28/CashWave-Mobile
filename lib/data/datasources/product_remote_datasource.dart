import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:cashwave_mobile/core/constants/variables.dart';
import 'package:cashwave_mobile/data/models/request/product_request_model.dart';
import 'package:cashwave_mobile/data/models/response/add_product_response_model.dart';
import 'package:cashwave_mobile/data/models/response/product_response_model.dart';
import 'package:cashwave_mobile/data/models/response/category_response_model.dart';
import 'auth_local_datasource.dart';

class ProductRemoteDatasource {
  Future<Either<String, ProductResponseModel>> getProducts() async {
    try {
      final token = await AuthLocalDatasource().getToken();

      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/products'),
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

  Future<Either<String, AddProductResponseModel>> addProduct(
    ProductRequestModel productRequestModel,
  ) async {
    try {
      final token = await AuthLocalDatasource().getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Variables.baseUrl}/products'),
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

      final response = await request.send();
      final body = await response.stream.bytesToString();

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

  Future<Either<String, AddProductResponseModel>> updateProduct(
    ProductRequestModel productRequestModel,
    int productId,
  ) async {
    try {
      final token = await AuthLocalDatasource().getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Variables.baseUrl}/products/$productId'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({...productRequestModel.toMap(), '_method': 'PUT'});

      if (productRequestModel.image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            productRequestModel.image!.path,
          ),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return right(AddProductResponseModel.fromJson(body));
      } else if (response.statusCode == 401) {
        return left("Unauthenticated, login dulu.");
      } else {
        return left("Error ${response.statusCode}: $body");
      }
    } catch (e) {
      return left("Update error: $e");
    }
  }

  Future<Either<String, CategoryResponseModel>> getCategories() async {
    try {
      final token = await AuthLocalDatasource().getToken();

      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/list-categories'),
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
