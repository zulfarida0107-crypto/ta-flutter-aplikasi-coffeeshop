-- =========================================================
-- Database: ta_db_coffeeshop
- =========================================================

-- 1. Tabel User
CREATE TABLE user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  nama_lengkap TEXT NOT NULL,
  role TEXT NOT NULL
);

-- 2. Tabel Menu Produk
CREATE TABLE menu_produk (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama_produk TEXT NOT NULL,
  harga REAL NOT NULL,
  deskripsi TEXT,
  kategori TEXT NOT NULL
);

-- 3. Tabel Pesanan
CREATE TABLE pesanan (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama_pelanggan TEXT NOT NULL,
  id_produk INTEGER NOT NULL,
  jumlah INTEGER NOT NULL,
  total_harga REAL NOT NULL,
  status_pesanan TEXT NOT NULL,
  tanggal_pesanan TEXT DEFAULT CURRENT_TIMESTAMP,
  detail_pesanan TEXT DEFAULT '[]'
);

-- 4. Tabel Desain Pesanan
CREATE TABLE desain_pesanan (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  id_pesanan INTEGER NOT NULL,
  file_desain_url TEXT,
  keterangan TEXT,
  tanggal_upload TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tabel Pesan Kontak
CREATE TABLE pesan_kontak (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama TEXT NOT NULL,
  email TEXT NOT NULL,
  subjek TEXT NOT NULL,
  pesan TEXT NOT NULL,
  tanggal_dikirim TEXT DEFAULT CURRENT_TIMESTAMP
);

