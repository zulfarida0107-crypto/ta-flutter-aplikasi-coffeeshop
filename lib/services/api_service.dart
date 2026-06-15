import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_entity.dart';
import '../models/menu_produk_entity.dart';
import '../models/pesanan_entity.dart';
import '../models/desain_pesanan_entity.dart';
import '../models/pesan_kontak_entity.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8083/api';
  static String? token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ============================================================
  // AUTH
  // ============================================================

  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
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

  // ============================================================
  // USER
  // ============================================================

  static Future<List<UserEntity>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((e) => UserEntity(
                    id: e['id'],
                    username: e['username'] ?? '',
                    password: e['password'] ?? '',
                    namaLengkap: e['namaLengkap'] ?? '',
                    role: e['role'] ?? '',
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error getAllUsers: $e");
      return [];
    }
  }

  static Future<bool> createUser(UserEntity user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: _headers,
        body: jsonEncode({
          'username': user.username,
          'password': user.password,
          'namaLengkap': user.namaLengkap,
          'role': user.role,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error createUser: $e");
      return false;
    }
  }

  static Future<bool> updateUser(UserEntity user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/${user.id}'),
        headers: _headers,
        body: jsonEncode({
          'username': user.username,
          'password': user.password,
          'namaLengkap': user.namaLengkap,
          'role': user.role,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error updateUser: $e");
      return false;
    }
  }

  static Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/user/$id'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error deleteUser: $e");
      return false;
    }
  }

  // ============================================================
  // MENU PRODUK
  // ============================================================

  static Future<List<MenuProdukEntity>> getAllMenuProduk() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menu-produk'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((e) => MenuProdukEntity(
                    id: e['id'],
                    namaProduk: e['namaProduk'] ?? '',
                    harga: (e['harga'] as num).toDouble(),
                    deskripsi: e['deskripsi'],
                    kategori: e['kategori'] ?? '',
                    gambar: e['gambar'],
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error getAllMenuProduk: $e");
      return [];
    }
  }

  static Future<bool> createMenuProduk(MenuProdukEntity menu) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu-produk'),
        headers: _headers,
        body: jsonEncode({
          'namaProduk': menu.namaProduk,
          'harga': menu.harga.toInt(),
          'deskripsi': menu.deskripsi ?? '',
          'kategori': menu.kategori,
          'gambar': menu.gambar ?? '',
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error createMenuProduk: $e");
      return false;
    }
  }

  static Future<bool> updateMenuProduk(MenuProdukEntity menu) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/menu-produk/${menu.id}'),
        headers: _headers,
        body: jsonEncode({
          'namaProduk': menu.namaProduk,
          'harga': menu.harga.toInt(),
          'deskripsi': menu.deskripsi ?? '',
          'kategori': menu.kategori,
          'gambar': menu.gambar ?? '',
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error updateMenuProduk: $e");
      return false;
    }
  }

  static Future<bool> deleteMenuProduk(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/menu-produk/$id'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error deleteMenuProduk: $e");
      return false;
    }
  }

  // ============================================================
  // PESANAN
  // ============================================================

  static Future<List<PesananEntity>> getAllPesanan() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pesanan'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((e) => PesananEntity(
                    id: e['id'],
                    namaPelanggan: e['namaPelanggan'] ?? '',
                    idProduk: e['idProduk'] ?? 0,
                    jumlah: e['jumlah'] ?? 0,
                    totalHarga: (e['totalHarga'] as num).toDouble(),
                    statusPesanan: e['statusPesanan'] ?? '',
                    tanggalPesanan: e['tanggalPesanan'],
                    detailPesanan: e['detailPesanan'] ?? '[]',
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error getAllPesanan: $e");
      return [];
    }
  }

  static Future<bool> createPesanan(PesananEntity pesanan) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pesanan'),
        headers: _headers,
        body: jsonEncode({
          'namaPelanggan': pesanan.namaPelanggan,
          'idProduk': pesanan.idProduk,
          'jumlah': pesanan.jumlah,
          'totalHarga': pesanan.totalHarga,
          'statusPesanan': pesanan.statusPesanan,
          'tanggalPesanan': pesanan.tanggalPesanan,
          'detailPesanan': pesanan.detailPesanan,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error createPesanan: $e");
      return false;
    }
  }

  static Future<bool> updatePesanan(PesananEntity pesanan) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pesanan/${pesanan.id}'),
        headers: _headers,
        body: jsonEncode({
          'namaPelanggan': pesanan.namaPelanggan,
          'idProduk': pesanan.idProduk,
          'jumlah': pesanan.jumlah,
          'totalHarga': pesanan.totalHarga,
          'statusPesanan': pesanan.statusPesanan,
          'tanggalPesanan': pesanan.tanggalPesanan,
          'detailPesanan': pesanan.detailPesanan,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error updatePesanan: $e");
      return false;
    }
  }

  static Future<bool> deletePesanan(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/pesanan/$id'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error deletePesanan: $e");
      return false;
    }
  }

  // ============================================================
  // DESAIN PESANAN
  // ============================================================

  static Future<List<DesainPesananEntity>> getAllDesainPesanan() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/desain-pesanan'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((e) => DesainPesananEntity(
                    id: e['id'],
                    idPesanan: e['idPesanan'] ?? 0,
                    fileDesainUrl: e['fileDesainUrl'],
                    keterangan: e['keterangan'],
                    tanggalUpload: e['tanggalUpload'],
                    statusPesanan: e['statusPesanan'] ?? 'Baru',
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error getAllDesainPesanan: $e");
      return [];
    }
  }

  static Future<bool> createDesainPesanan(DesainPesananEntity desain) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/desain-pesanan'),
        headers: _headers,
        body: jsonEncode({
          'idPesanan': desain.idPesanan,
          'fileDesainUrl': desain.fileDesainUrl ?? '',
          'keterangan': desain.keterangan ?? '',
          'tanggalUpload': desain.tanggalUpload,
          'statusPesanan': desain.statusPesanan,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error createDesainPesanan: $e");
      return false;
    }
  }

  static Future<bool> updateDesainPesanan(DesainPesananEntity desain) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/desain-pesanan/${desain.id}'),
        headers: _headers,
        body: jsonEncode({
          'idPesanan': desain.idPesanan,
          'fileDesainUrl': desain.fileDesainUrl ?? '',
          'keterangan': desain.keterangan ?? '',
          'tanggalUpload': desain.tanggalUpload,
          'statusPesanan': desain.statusPesanan,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error updateDesainPesanan: $e");
      return false;
    }
  }

  static Future<bool> deleteDesainPesanan(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/desain-pesanan/$id'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error deleteDesainPesanan: $e");
      return false;
    }
  }

  // ============================================================
  // PESAN KONTAK
  // ============================================================

  static Future<List<PesanKontakEntity>> getAllPesanKontak() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pesan-kontak'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((e) => PesanKontakEntity(
                    id: e['id'],
                    nama: e['nama'] ?? '',
                    email: e['email'] ?? '',
                    subjek: e['subjek'] ?? '',
                    pesan: e['pesan'] ?? '',
                    tanggalDikirim: e['tanggalDikirim'],
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error getAllPesanKontak: $e");
      return [];
    }
  }

  static Future<bool> deletePesanKontak(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/pesan-kontak/$id'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print("Error deletePesanKontak: $e");
      return false;
    }
  }
}
