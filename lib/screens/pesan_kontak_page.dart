import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pesan_kontak_entity.dart';
import '../services/api_service.dart';

class PesanKontakPage extends StatefulWidget {
  const PesanKontakPage({super.key});

  @override
  State<PesanKontakPage> createState() => _PesanKontakPageState();
}

class _PesanKontakPageState extends State<PesanKontakPage> {
  List<PesanKontakEntity> listPesan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    setState(() => isLoading = true);
    var data = await ApiService.getAllPesanKontak();
    if (!mounted) return;

    data.sort((a, b) {
      if (a.sudahDibalas == b.sudahDibalas) {
        int idA = a.id ?? 0;
        int idB = b.id ?? 0;
        return idB.compareTo(idA);
      }
      return a.sudahDibalas ? 1 : -1;
    });

    setState(() {
      listPesan = data;
      isLoading = false;
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : listPesan.isEmpty
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
                            const SizedBox(height: 6),
                            _buildReplyStatusBadge(kotakPesan.sudahDibalas),
                          ],
                        ),
                        onTap: () {
                          _showDetailDialog(kotakPesan);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: "Balas Pesan",
                              onPressed: () {
                                _showReplyDialog(kotakPesan);
                              },
                            ),
                            IconButton(
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
                                            await ApiService.deletePesanKontak(kotakPesan.id!);
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildReplyStatusBadge(bool sudahDibalas) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: sudahDibalas ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sudahDibalas ? Colors.green : Colors.orange,
          width: 1.5,
        ),
      ),
      child: Text(
        sudahDibalas ? "Sudah Membalas" : "Belum Membalas",
        style: TextStyle(
          color: sudahDibalas ? Colors.green[800] : Colors.orange[800],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
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
              const SizedBox(height: 8),
              _buildReplyStatusBadge(pesanKontak.sudahDibalas),
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
            onPressed: () async {
              // Tampilkan dialog loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.brown),
                  );
                },
              );

              bool success = await ApiService.replyPesanKontak(pesanKontak.id ?? 0, balasanController.text);
              
              // Tutup dialog loading
              if (context.mounted) {
                Navigator.pop(context); // Tutup loading
              }

              if (success) {
                if (context.mounted) {
                  Navigator.pop(ctx); // Tutup form dialog jika sukses
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Balasan email berhasil terkirim langsung!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _refreshData();
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal mengirim email balasan. Pastikan App Password Gmail admin sudah dikonfigurasi di backend."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
