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
            onPressed: () async {
              Navigator.pop(ctx);
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: pesanKontak.email,
                queryParameters: {
                  'subject': 'Balasan: ${pesanKontak.subjek}',
                  'body': balasanController.text,
                },
              );
              try {
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
                } else {
                  await launchUrl(emailLaunchUri);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Tidak dapat membuka aplikasi Gmail/email: $e"),
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
