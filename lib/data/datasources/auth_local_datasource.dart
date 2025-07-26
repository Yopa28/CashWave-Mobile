import 'dart:convert';
import 'package:cashwave_mobile/data/models/response/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDatasource {
  // 🔑 Simpan full auth-data (opsional)
  Future<void> saveAuthData(AuthResponseModel authResponseModel) async {
    final prefs = await SharedPreferences.getInstance();

    // simpan json
    await prefs.setString('auth_data', jsonEncode(authResponseModel.toJson()));

    // simpan token terpisah biar gampang
    if (authResponseModel.token != null) {
      await prefs.setString('token', authResponseModel.token!);
    }
  }

  // 🔑 Ambil full AuthResponseModel
  Future<AuthResponseModel?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('auth_data');
    if (authData == null) return null;

    return AuthResponseModel.fromJson(jsonDecode(authData));
  }

  // 🔑 Ambil hanya token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // bisa null
  }

  // cek sudah login?
  Future<bool> isAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // 🔥 Hapus data login
  Future<void> removeAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
    await prefs.remove('token');
  }

  // 📌 simpan midtrans server key
  Future<void> saveMidtransServerKey(String serverKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_key', serverKey);
  }

  // 📌 simpan printer
  Future<void> savePrinter(String printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer', printer);
  }

  Future<String> getPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('printer') ?? '';
  }

  // 📌 simpan ukuran printer
  Future<void> saveSizePrinter(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('size', size);
  }

  Future<String> getSizePrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('size') ?? '58mm';
  }
}
