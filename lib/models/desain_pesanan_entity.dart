class DesainPesananEntity {
  final int id;
  final int idPesanan;
  final String? fileDesainUrl;
  final String? keterangan;
  final String? tanggalUpload;
  final String statusPesanan;

  DesainPesananEntity({
    required this.id,
    required this.idPesanan,
    this.fileDesainUrl,
    this.keterangan,
    this.tanggalUpload,
    required this.statusPesanan,
  });

  factory DesainPesananEntity.fromMap(Map<String, dynamic> map) {
    return DesainPesananEntity(
      id: map[COL_ID_KEY] is int ? map[COL_ID_KEY] : (int.tryParse(map[COL_ID_KEY].toString()) ?? 0),
      idPesanan: map[COL_ID_PESANAN_KEY] is int ? map[COL_ID_PESANAN_KEY] : (int.tryParse(map[COL_ID_PESANAN_KEY].toString()) ?? 0),
      fileDesainUrl: map[COL_FILE_DESAIN_URL_KEY],
      keterangan: map[COL_KETERANGAN_KEY],
      tanggalUpload: map[COL_TANGGAL_UPLOAD_KEY],
      statusPesanan: map[COL_STATUS_PESANAN_KEY] ?? 'Baru',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      COL_ID_KEY: id,
      COL_ID_PESANAN_KEY: idPesanan,
      COL_FILE_DESAIN_URL_KEY: fileDesainUrl,
      COL_KETERANGAN_KEY: keterangan,
      COL_TANGGAL_UPLOAD_KEY: tanggalUpload,
      COL_STATUS_PESANAN_KEY: statusPesanan,
    };
  }

  static String TABLE_NAME = "desain_pesanan";
  static String COL_ID_KEY = "id";
  static String COL_ID_PESANAN_KEY = "id_pesanan";
  static String COL_FILE_DESAIN_URL_KEY = "file_desain_url";
  static String COL_KETERANGAN_KEY = "keterangan";
  static String COL_TANGGAL_UPLOAD_KEY = "tanggal_upload";
  static String COL_STATUS_PESANAN_KEY = "status_pesanan";
}
