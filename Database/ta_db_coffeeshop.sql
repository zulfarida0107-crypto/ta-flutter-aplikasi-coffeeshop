-- =========================================================
-- Database: ta_db_coffeeshop
-- =========================================================

-- 1. Tabel User (Standalone)
CREATE TABLE `user` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `nama_lengkap` VARCHAR(255) NOT NULL,
  `role` VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- 2. Tabel Pesan Kontak (Standalone)
CREATE TABLE `pesan_kontak` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `nama` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `subjek` VARCHAR(255) NOT NULL,
  `pesan` TEXT NOT NULL,
  `tanggal_dikirim` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `sudah_dibalas` TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- 3. Tabel Menu Produk (Master Data)
CREATE TABLE `menu_produk` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `nama_produk` VARCHAR(255) NOT NULL,
  `harga` DECIMAL(10,2) NOT NULL,
  `deskripsi` TEXT,
  `kategori` VARCHAR(100) NOT NULL,
  `gambar` TEXT,
  `bagian` VARCHAR(100) NOT NULL DEFAULT 'Menu Kami'
) ENGINE=InnoDB;

-- 4. Tabel Pesanan (Berelasi dengan Menu Produk)
CREATE TABLE `pesanan` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `nama_pelanggan` VARCHAR(255) NOT NULL,
  `id_produk` INT NOT NULL,
  `jumlah` INT NOT NULL,
  `total_harga` DECIMAL(10,2) NOT NULL,
  `status_pesanan` VARCHAR(50) NOT NULL,
  `tanggal_pesanan` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `detail_pesanan` TEXT DEFAULT '[]',
  CONSTRAINT `fk_pesanan_produk` FOREIGN KEY (`id_produk`) REFERENCES `menu_produk`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. Tabel Desain Pesanan (Berelasi dengan Pesanan)
CREATE TABLE `desain_pesanan` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `id_pesanan` INT NOT NULL,
  `file_desain_url` TEXT,
  `keterangan` TEXT,
  `tanggal_upload` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `status_pesanan` VARCHAR(50) NOT NULL DEFAULT 'Baru',
  CONSTRAINT `fk_desain_pesanan` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
