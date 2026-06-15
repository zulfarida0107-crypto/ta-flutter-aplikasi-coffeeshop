class MenuProdukEntity {
  final int id;
  final String namaProduk;
  final double harga;
  final String? deskripsi;
  final String kategori;
  final String? gambar;

  MenuProdukEntity({
    required this.id,
    required this.namaProduk,
    required this.harga,
    this.deskripsi,
    required this.kategori,
    this.gambar,
  });

  factory MenuProdukEntity.fromMap(Map<String, dynamic> map) {
    return MenuProdukEntity(
      id: map[COL_ID_KEY] is int ? map[COL_ID_KEY] : (int.tryParse(map[COL_ID_KEY].toString()) ?? 0),
      namaProduk: map[COL_NAMA_PRODUK_KEY] ?? '',
      harga: double.tryParse(map[COL_HARGA_KEY].toString()) ?? 0.0,
      deskripsi: map[COL_DESKRIPSI_KEY],
      kategori: map[COL_KATEGORI_KEY] ?? '',
      gambar: map[COL_GAMBAR_KEY],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      COL_ID_KEY: id,
      COL_NAMA_PRODUK_KEY: namaProduk,
      COL_HARGA_KEY: harga,
      COL_DESKRIPSI_KEY: deskripsi,
      COL_KATEGORI_KEY: kategori,
      COL_GAMBAR_KEY: gambar,
    };
  }

  static String TABLE_NAME = "menu_produk";
  static String COL_ID_KEY = "id";
  static String COL_NAMA_PRODUK_KEY = "nama_produk";
  static String COL_HARGA_KEY = "harga";
  static String COL_DESKRIPSI_KEY = "deskripsi";
  static String COL_KATEGORI_KEY = "kategori";
  static String COL_GAMBAR_KEY = "gambar";
}
