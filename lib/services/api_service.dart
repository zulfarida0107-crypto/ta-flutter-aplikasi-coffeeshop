import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti IP ini sesuai perangkat (10.0.2.2 untuk Emulator)
  static const String baseUrl = 'http://10.0.2.2:8082/api';
  
  // Variabel untuk menyimpan token login
  static String? token;

  // Fungsi Login API
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Simpan token untuk request selanjutnya
          token = data['data']['token'];
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error Login: $e");
      return false;
    }
  }

  // Fungsi Ambil Menu Produk API
  static Future<List<dynamic>> getMenuProduk() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu-produk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']; // Kembalikan array (list) data produk
        }
      }
      return [];
    } catch (e) {
      print("Error Fetch Menu: $e");
      return [];
    }
  }
}
