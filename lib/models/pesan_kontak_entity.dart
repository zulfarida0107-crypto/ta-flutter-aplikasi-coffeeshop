class PesanKontakEntity {
  final int? id;
  final String nama;
  final String email;
  final String subjek;
  final String pesan;
  final String? tanggalDikirim;
  final bool sudahDibalas;

  PesanKontakEntity({
    this.id,
    required this.nama,
    required this.email,
    required this.subjek,
    required this.pesan,
    this.tanggalDikirim,
    this.sudahDibalas = false,
  });

  factory PesanKontakEntity.fromMap(Map<String, dynamic> map) {
    return PesanKontakEntity(
      id: map[COL_ID_KEY],
      nama: map[COL_NAMA_KEY] ?? '',
      email: map[COL_EMAIL_KEY] ?? '',
      subjek: map[COL_SUBJEK_KEY] ?? '',
      pesan: map[COL_PESAN_KEY] ?? '',
      tanggalDikirim: map[COL_TANGGAL_DIKIRIM_KEY],
      sudahDibalas: map[COL_SUDAH_DIBALAS_KEY] == true || map[COL_SUDAH_DIBALAS_KEY] == 1 || map[COL_SUDAH_DIBALAS_KEY] == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      COL_ID_KEY: id,
      COL_NAMA_KEY: nama,
      COL_EMAIL_KEY: email,
      COL_SUBJEK_KEY: subjek,
      COL_PESAN_KEY: pesan,
      COL_TANGGAL_DIKIRIM_KEY: tanggalDikirim,
      COL_SUDAH_DIBALAS_KEY: sudahDibalas ? 1 : 0,
    };
  }

  static String TABLE_NAME = "pesan_kontak";
  static String COL_ID_KEY = "id";
  static String COL_NAMA_KEY = "nama";
  static String COL_EMAIL_KEY = "email";
  static String COL_SUBJEK_KEY = "subjek";
  static String COL_PESAN_KEY = "pesan";
  static String COL_TANGGAL_DIKIRIM_KEY = "tanggal_dikirim";
  static String COL_SUDAH_DIBALAS_KEY = "sudah_dibalas";
}
