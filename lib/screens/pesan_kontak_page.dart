// ISI KODE FILE C:\Dokumen\flutter-coffeeshop-1 (DONE)\lib\screens\pesan_kontak_page.dart

import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/pesan_kontak_entity.dart';

class PesanKontakPage extends StatefulWidget {
  const PesanKontakPage({super.key});

  @override
  State<PesanKontakPage> createState() => _PesanKontakPageState();
}

class _PesanKontakPageState extends State<PesanKontakPage> {
  List<PesanKontakEntity> listPesan = [];

  @override
  void initState() {
    super.initState();
    _forceInjectOnce();
  }

  void _forceInjectOnce() async {
    var existing = await DatabaseHelper.getInstance().getAllPesanKontak();
    if (existing.isEmpty) {
      await _injectDummyData();
    }
    _refreshData();
  }

  void _refreshData() async {
    var data = await DatabaseHelper.getInstance().getAllPesanKontak();
    if (!mounted) return;
    setState(() {
      listPesan = data;
    });
  }

  String formatWaktu(String? waktuUtc) {
    if (waktuUtc == null || waktuUtc.isEmpty) return '-';
    try {
      String formattedUtc = waktuUtc.replaceFirst(' ', 'T');
      if (!formattedUtc.endsWith('Z')) {
        formattedUtc += 'Z';
      }
      DateTime parsedDate = DateTime.parse(formattedUtc).toLocal();
      String duaDigit(int n) => n.toString().padLeft(2, '0');
      return "${duaDigit(parsedDate.day)}/${duaDigit(parsedDate.month)}/${parsedDate.year} ${duaDigit(parsedDate.hour)}:${duaDigit(parsedDate.minute)}";
    } catch (e) {
      return waktuUtc;
    }
  }

  Future<void> _injectDummyData() async {
    final dummyData = [
      PesanKontakEntity(
        id: null,
        nama: "Andi",
        email: "andi@email.com",
        subjek: "Komplain Pelayanan",
        pesan:
            "Barista di cabang Sudirman kurang ramah saat melayani antrean pagi ini.",
        tanggalDikirim: DateTime.parse(
          "2026-02-28 09:15:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Budi",
        email: "budi@email.com",
        subjek: "Tanya Promo",
        pesan:
            "Apakah promo buy 1 get 1 untuk pengguna kartu debit masih berlaku minggu ini?",
        tanggalDikirim: DateTime.parse(
          "2026-02-28 11:30:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Citra",
        email: "citra@email.com",
        subjek: "Saran Menu",
        pesan:
            "Tolong hadirkan menu kopi dengan susu oat atau almond untuk opsi vegan.",
        tanggalDikirim: DateTime.parse(
          "2026-02-28 14:45:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Dewa",
        email: "dewa@email.com",
        subjek: "Sewa Tempat",
        pesan:
            "Apakah cafe ini bisa di-booking untuk acara workshop kecil kapasitas 15 orang?",
        tanggalDikirim: DateTime.parse(
          "2026-03-01 08:00:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Eka",
        email: "eka@email.com",
        subjek: "Kualitas Produk",
        pesan:
            "Biji kopi yang saya beli kemarin aromanya kurang segar, apakah bisa ditukar baru?",
        tanggalDikirim: DateTime.parse(
          "2026-03-01 10:20:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Faisal",
        email: "faisal@email.com",
        subjek: "Jam Operasional",
        pesan:
            "Selama bulan Ramadhan nanti, jam operasional toko buka dari jam berapa sampai jam berapa?",
        tanggalDikirim: DateTime.parse(
          "2026-03-01 16:10:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Gita",
        email: "gita@email.com",
        subjek: "Lowongan Kerja",
        pesan:
            "Halo admin, apakah sedang ada lowongan untuk part-time barista di cabang Bandung?",
        tanggalDikirim: DateTime.parse(
          "2026-03-02 09:05:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Hasan",
        email: "hasan@email.com",
        subjek: "Konfirmasi Pembayaran",
        pesan:
            "Saya sudah transfer via QRIS tapi status di sistem masih tertulis menunggu pembayaran.",
        tanggalDikirim: DateTime.parse(
          "2026-03-02 13:50:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Nisa",
        email: "nisa@email.com",
        subjek: "Kemitraan",
        pesan:
            "Bagaimana prosedur untuk menjadi supplier biji kopi mentah (green beans) ke kedai ini?",
        tanggalDikirim: DateTime.parse(
          "2026-03-03 10:00:00",
        ).toUtc().toIso8601String(),
      ),
      PesanKontakEntity(
        id: null,
        nama: "Reno",
        email: "reno@email.com",
        subjek: "Varian Biji Kopi",
        pesan:
            "Apakah tersedia stok biji kopi Arabica Flores dalam kemasan 500 gram?",
        tanggalDikirim: DateTime.parse(
          "2026-03-03 14:00:00",
        ).toUtc().toIso8601String(),
      ),
    ];

    for (var entity in dummyData) {
      await DatabaseHelper.getInstance().createPesanKontak(entity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesan Masuk',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Data",
            onPressed: () {
              _refreshData();
            },
          ),
        ],
      ),
      body: listPesan.isEmpty
          ? const Center(
              child: Text("Belum ada pesan masuk. Kotak masuk kosong!"),
            )
          : ListView.builder(
              itemCount: listPesan.length,
              itemBuilder: (context, index) {
                var kotakPesan = listPesan[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown[100],
                      child: const Icon(Icons.mail, color: Colors.brown),
                    ),
                    title: Text(
                      "ID: ${kotakPesan.id} - ${kotakPesan.nama}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          kotakPesan.subjek,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatWaktu(kotakPesan.tanggalDikirim),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF795548),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showDetailDialog(kotakPesan);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text(
                              "Konfirmasi Hapus",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              "Apakah anda yakin menghapus data ini?",
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text(
                                  "Tidak",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () async {
                                  if (kotakPesan.id != null) {
                                      await DatabaseHelper.getInstance()
                                          .deletePesanKontak(kotakPesan.id!);
                                  }
                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Data berhasil dihapus permanen",
                                      ),
                                      backgroundColor: Colors.brown,
                                    ),
                                  );
                                  _refreshData();
                                },
                                child: const Text(
                                  "Ya",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDetailDialog(PesanKontakEntity pesanKontak) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Detail Pesan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ID Pesan: ${pesanKontak.id}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Pengirim: ${pesanKontak.nama}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Email: ${pesanKontak.email}",
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
              const Divider(),
              Text(
                "Subjek: ${pesanKontak.subjek}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(pesanKontak.pesan, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text(
                "Tanggal Dikirim: ${formatWaktu(pesanKontak.tanggalDikirim)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF795548),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            onPressed: () {
              Navigator.pop(ctx);
              _showReplyDialog(pesanKontak);
            },
            child: const Text("Balas", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(PesanKontakEntity pesanKontak) {
    TextEditingController balasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Kirim Balasan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kepada: ${pesanKontak.email}",
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: balasanController,
                decoration: const InputDecoration(
                  labelText: "Tulis balasan",
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(121, 85, 72, 1),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    "Balasan berhasil dikirim ke ${pesanKontak.email}",
                  ),
                  backgroundColor: Colors.brown,
                ),
              );
            },
            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
