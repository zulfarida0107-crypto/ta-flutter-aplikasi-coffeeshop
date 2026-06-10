import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_entity.dart';
import '../models/menu_produk_entity.dart';
import '../models/pesanan_entity.dart';
import '../models/desain_pesanan_entity.dart';
import '../models/pesan_kontak_entity.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  late Database _database;

  static const String _DATABASE_NAME = "db_kantin";
  static const int _DATABASE_VERSION = 1;
  static DatabaseHelper? _instance;

  static DatabaseHelper getInstance() {
    _instance ??= DatabaseHelper._privateConstructor();
    return _instance!;
  }

  // --- INISIALISASI DATABASE ---
  static Future<void> initDatabase() async {
    String path = join(await getDatabasesPath(), _DATABASE_NAME);
    getInstance()._database = await openDatabase(
      path,
      version: _DATABASE_VERSION,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${UserEntity.TABLE_NAME} (
            ${UserEntity.COL_ID_KEY} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${UserEntity.COL_USERNAME_KEY} TEXT NOT NULL,
            ${UserEntity.COL_PASSWORD_KEY} TEXT NOT NULL,
            ${UserEntity.COL_NAMA_LENGKAP_KEY} TEXT NOT NULL,
            ${UserEntity.COL_ROLE_KEY} TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ${MenuProdukEntity.TABLE_NAME} (
            ${MenuProdukEntity.COL_ID_KEY} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${MenuProdukEntity.COL_NAMA_PRODUK_KEY} TEXT NOT NULL,
            ${MenuProdukEntity.COL_HARGA_KEY} REAL NOT NULL,
            ${MenuProdukEntity.COL_DESKRIPSI_KEY} TEXT,
            ${MenuProdukEntity.COL_KATEGORI_KEY} TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ${PesananEntity.TABLE_NAME} (
            ${PesananEntity.COL_ID_KEY} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${PesananEntity.COL_NAMA_PELANGGAN_KEY} TEXT NOT NULL,
            ${PesananEntity.COL_ID_PRODUK_KEY} INTEGER NOT NULL,
            ${PesananEntity.COL_JUMLAH_KEY} INTEGER NOT NULL,
            ${PesananEntity.COL_TOTAL_HARGA_KEY} REAL NOT NULL,
            ${PesananEntity.COL_STATUS_PESANAN_KEY} TEXT NOT NULL,
            ${PesananEntity.COL_TANGGAL_PESANAN_KEY} TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE ${DesainPesananEntity.TABLE_NAME} (
            ${DesainPesananEntity.COL_ID_KEY} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DesainPesananEntity.COL_ID_PESANAN_KEY} INTEGER NOT NULL,
            ${DesainPesananEntity.COL_FILE_DESAIN_URL_KEY} TEXT,
            ${DesainPesananEntity.COL_KETERANGAN_KEY} TEXT,
            ${DesainPesananEntity.COL_TANGGAL_UPLOAD_KEY} TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE ${PesanKontakEntity.TABLE_NAME} (
            ${PesanKontakEntity.COL_ID_KEY} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${PesanKontakEntity.COL_NAMA_KEY} TEXT NOT NULL,
            ${PesanKontakEntity.COL_EMAIL_KEY} TEXT NOT NULL,
            ${PesanKontakEntity.COL_SUBJEK_KEY} TEXT NOT NULL,
            ${PesanKontakEntity.COL_PESAN_KEY} TEXT NOT NULL,
            ${PesanKontakEntity.COL_TANGGAL_DIKIRIM_KEY} TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  // ==========================================
  // 1. MANAJEMEN USER (Tambah, Edit, Delete, View All)
  // ==========================================
  Future<bool> createUser(UserEntity entity) async {
    var mapData = entity.toMap();
    if (mapData[UserEntity.COL_ID_KEY] == 0) {
      mapData[UserEntity.COL_ID_KEY] = null;
    }
    try {
      await _database.insert(UserEntity.TABLE_NAME, mapData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserEntity>> getAllUser() async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${UserEntity.TABLE_NAME}",
      );
      return queryResult.map((e) => UserEntity.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateUser(UserEntity entity) async {
    try {
      int rowAffected = await _database.update(
        UserEntity.TABLE_NAME,
        entity.toMap(),
        where: "${UserEntity.COL_ID_KEY} = ?",
        whereArgs: [entity.id],
      );
      return rowAffected > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _database.delete(
        UserEntity.TABLE_NAME,
        where: "${UserEntity.COL_ID_KEY} = ?",
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 2. DAFTAR MENU PRODUK (Tambah, Edit, Delete, View Detail)
  // ==========================================
  Future<bool> createMenuProduk(MenuProdukEntity entity) async {
    var mapData = entity.toMap();
    if (mapData[MenuProdukEntity.COL_ID_KEY] == 0) {
      mapData[MenuProdukEntity.COL_ID_KEY] = null;
    }
    try {
      await _database.insert(MenuProdukEntity.TABLE_NAME, mapData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<MenuProdukEntity>> getAllMenuProduk() async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${MenuProdukEntity.TABLE_NAME}",
      );
      return queryResult.map((e) => MenuProdukEntity.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<MenuProdukEntity?> getMenuProdukDetail(int id) async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${MenuProdukEntity.TABLE_NAME} WHERE ${MenuProdukEntity.COL_ID_KEY} = ?",
        [id],
      );
      if (queryResult.isNotEmpty) {
        return MenuProdukEntity.fromMap(queryResult.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateMenuProduk(MenuProdukEntity entity) async {
    try {
      int rowAffected = await _database.update(
        MenuProdukEntity.TABLE_NAME,
        entity.toMap(),
        where: "${MenuProdukEntity.COL_ID_KEY} = ?",
        whereArgs: [entity.id],
      );
      return rowAffected > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMenuProduk(int id) async {
    try {
      await _database.delete(
        MenuProdukEntity.TABLE_NAME,
        where: "${MenuProdukEntity.COL_ID_KEY} = ?",
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 3. DAFTAR PESANAN (Tambah, Edit, Delete, View Detail)
  // ==========================================
  Future<bool> createPesanan(PesananEntity entity) async {
    var mapData = entity.toMap();
    if (mapData[PesananEntity.COL_ID_KEY] == 0) {
      mapData[PesananEntity.COL_ID_KEY] = null;
    }
    try {
      await _database.insert(PesananEntity.TABLE_NAME, mapData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PesananEntity>> getAllPesanan() async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${PesananEntity.TABLE_NAME}",
      );
      return queryResult.map((e) => PesananEntity.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PesananEntity?> getPesananDetail(int id) async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${PesananEntity.TABLE_NAME} WHERE ${PesananEntity.COL_ID_KEY} = ?",
        [id],
      );
      if (queryResult.isNotEmpty) {
        return PesananEntity.fromMap(queryResult.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePesanan(PesananEntity entity) async {
    try {
      int rowAffected = await _database.update(
        PesananEntity.TABLE_NAME,
        entity.toMap(),
        where: "${PesananEntity.COL_ID_KEY} = ?",
        whereArgs: [entity.id],
      );
      return rowAffected > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePesanan(int id) async {
    try {
      await _database.delete(
        PesananEntity.TABLE_NAME,
        where: "${PesananEntity.COL_ID_KEY} = ?",
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 4. DAFTAR DESAIN PESANAN (Tambah, Edit, Delete, View Detail)
  // ==========================================
  Future<bool> createDesainPesanan(DesainPesananEntity entity) async {
    var mapData = entity.toMap();
    if (mapData[DesainPesananEntity.COL_ID_KEY] == 0) {
      mapData[DesainPesananEntity.COL_ID_KEY] = null;
    }
    try {
      await _database.insert(DesainPesananEntity.TABLE_NAME, mapData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<DesainPesananEntity>> getAllDesainPesanan() async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${DesainPesananEntity.TABLE_NAME}",
      );
      return queryResult.map((e) => DesainPesananEntity.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<DesainPesananEntity?> getDesainPesananDetail(int id) async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${DesainPesananEntity.TABLE_NAME} WHERE ${DesainPesananEntity.COL_ID_KEY} = ?",
        [id],
      );
      if (queryResult.isNotEmpty) {
        return DesainPesananEntity.fromMap(queryResult.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateDesainPesanan(DesainPesananEntity entity) async {
    try {
      int rowAffected = await _database.update(
        DesainPesananEntity.TABLE_NAME,
        entity.toMap(),
        where: "${DesainPesananEntity.COL_ID_KEY} = ?",
        whereArgs: [entity.id],
      );
      return rowAffected > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDesainPesanan(int id) async {
    try {
      await _database.delete(
        DesainPesananEntity.TABLE_NAME,
        where: "${DesainPesananEntity.COL_ID_KEY} = ?",
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 5. DAFTAR PESAN MASUK / KONTAK (Tambah, Delete & View Detail)
  // ==========================================

  Future<bool> createPesanKontak(PesanKontakEntity entity) async {
    var mapData = entity.toMap();
    if (mapData[PesanKontakEntity.COL_ID_KEY] == 0 || mapData[PesanKontakEntity.COL_ID_KEY] == null) {
      mapData[PesanKontakEntity.COL_ID_KEY] = null;
    }
    try {
      await _database.insert(PesanKontakEntity.TABLE_NAME, mapData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PesanKontakEntity>> getAllPesanKontak() async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${PesanKontakEntity.TABLE_NAME}",
      );
      return queryResult.map((e) => PesanKontakEntity.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PesanKontakEntity?> getPesanKontakDetail(int id) async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${PesanKontakEntity.TABLE_NAME} WHERE ${PesanKontakEntity.COL_ID_KEY} = ?",
        [id],
      );
      if (queryResult.isNotEmpty) {
        return PesanKontakEntity.fromMap(queryResult.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deletePesanKontak(int id) async {
    try {
      await _database.delete(
        PesanKontakEntity.TABLE_NAME,
        where: "${PesanKontakEntity.COL_ID_KEY} = ?",
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- ADDED METHODS FROM API TO MATCH EXISTING CODEBASE ---
  Future<UserEntity?> loginUser(String username, String password) async {
    try {
      var queryResult = await _database.rawQuery(
        "SELECT * FROM ${UserEntity.TABLE_NAME} WHERE ${UserEntity.COL_USERNAME_KEY} = ? AND ${UserEntity.COL_PASSWORD_KEY} = ?",
        [username, password],
      );
      if (queryResult.isNotEmpty) {
        return UserEntity.fromMap(queryResult.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateDesainPesananWithOldId(int oldId, DesainPesananEntity entity) async {
    try {
      int rowAffected = await _database.update(
        DesainPesananEntity.TABLE_NAME,
        entity.toMap(),
        where: "${DesainPesananEntity.COL_ID_KEY} = ?",
        whereArgs: [oldId],
      );
      return rowAffected > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAllPesanKontak() async {
    try {
      await _database.delete(PesanKontakEntity.TABLE_NAME);
      return true;
    } catch (e) {
      return false;
    }
  }
}
