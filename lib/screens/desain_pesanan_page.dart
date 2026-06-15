import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/desain_pesanan_entity.dart';
import '../services/api_service.dart';

class DesainPesananPage extends StatefulWidget {
  const DesainPesananPage({super.key});

  @override
  State<DesainPesananPage> createState() => _DesainPesananPageState();
}

class _DesainPesananPageState extends State<DesainPesananPage> {
  List<DesainPesananEntity> listDesain = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _saveSession();
  }

  void _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_in_desain_page', true);
  }

  @override
  void dispose() {
    _clearSession();
    super.dispose();
  }

  void _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_in_desain_page');
  }

  void _refreshData() async {
    setState(() => isLoading = true);
    var data = await ApiService.getAllDesainPesanan();
    setState(() {
      listDesain = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: const Color(0xFF674D43),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Daftar Desain Pesanan',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const Text(
              '(Kue Custom)',
              style: TextStyle(color: Colors.white, fontSize: 22, height: 1.4),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : listDesain.isEmpty
              ? const Center(
                  child: Text("Belum ada desain pesanan. Klik + untuk tambah!"),
                )
              : ListView.builder(
                  itemCount: listDesain.length,
                  itemBuilder: (context, index) {
                    var desain = listDesain[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown[100],
                          child: const Icon(Icons.cake, color: Colors.brown),
                        ),
                        title: Text(
                          "ID: ${desain.id} - ID Pesanan: ${desain.idPesanan}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(desain.keterangan ?? "Tidak ada keterangan"),
                            const SizedBox(height: 4),
                            _buildStatusBadge(desain.statusPesanan),
                          ],
                        ),
                        onTap: () {
                          _showDetailDialog(desain);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showFormDialog(desain: desain);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
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
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          "tidak",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await ApiService.deleteDesainPesanan(desain.id);
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Data berhasil dihapus permanen",
                                                ),
                                                backgroundColor: Colors.brown,
                                              ),
                                            );
                                          }
                                          _refreshData();
                                        },
                                        child: const Text(
                                          "ya",
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () {
          _showFormDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- POP-UP UNTUK VIEW DETAIL ---
  void _showDetailDialog(DesainPesananEntity desain) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Detail Desain Kue Custom",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID: ${desain.id} -  ID Pesanan Terkait: ${desain.idPesanan}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Status: ", style: TextStyle(fontSize: 16)),
                _buildStatusBadge(desain.statusPesanan),
              ],
            ),
            const SizedBox(height: 8),
            const Text("Link/URL Desain:", style: TextStyle(fontSize: 16)),
            if (desain.fileDesainUrl != null &&
                desain.fileDesainUrl!.isNotEmpty)
              Builder(
                builder: (context) {
                  String url = desain.fileDesainUrl!;
                  bool isFile =
                      url.startsWith('/') ||
                      url.startsWith('file://') ||
                      url.startsWith('content://') ||
                      url.startsWith('C:');

                  return InkWell(
                    onTap: () async {
                      if (!isFile) {
                        String launchUriStr = url.startsWith('http')
                            ? url
                            : 'https://$url';
                        final uri = Uri.parse(launchUriStr);
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          debugPrint("Tidak dapat membuka URL: $e");
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: !isFile
                          ? Text(
                              url,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            )
                          : Image.file(
                              File(url),
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text(
                                    "Gagal memuat gambar",
                                    style: TextStyle(color: Colors.red),
                                  ),
                            ),
                    ),
                  );
                },
              )
            else
              const Text("-", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              "Keterangan: ${desain.keterangan ?? '-'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Waktu Upload: ${desain.tanggalUpload ?? '-'}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.brown)),
          ),
        ],
      ),
    );
  }

  // --- POP-UP FORM UNTUK TAMBAH & EDIT ---
  void _showFormDialog({DesainPesananEntity? desain}) {
    bool isEdit = desain != null;

    TextEditingController idPesananController = TextEditingController(
      text: isEdit ? desain.idPesanan.toString() : "",
    );
    TextEditingController urlController = TextEditingController(
      text: isEdit ? desain.fileDesainUrl : "",
    );
    TextEditingController keteranganController = TextEditingController(
      text: isEdit ? desain.keterangan : "",
    );

    String selectedStatus = "Baru";
    if (isEdit) {
      if (desain.statusPesanan.toLowerCase() == 'baru') selectedStatus = 'Baru';
      else if (desain.statusPesanan.toLowerCase() == 'proses') selectedStatus = 'Proses';
      else if (desain.statusPesanan.toLowerCase() == 'selesai') selectedStatus = 'Selesai';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEdit ? "Edit Desain Kue Custom" : "Tambah Desain Kue Custom",
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idPesananController,
                decoration: const InputDecoration(labelText: "ID Pesanan"),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: "Upload / Link URL Gambar",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.paste, color: Colors.blue),
                    tooltip: "Paste Link",
                    onPressed: () async {
                      ClipboardData? data = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );
                      if (data != null && data.text != null) {
                        urlController.text = data.text!;
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.upload_file, color: Colors.brown),
                    tooltip: "Upload Gambar",
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        urlController.text = image.path;
                      }
                    },
                  ),
                ],
              ),
              TextField(
                controller: keteranganController,
                decoration: const InputDecoration(
                  labelText: "Keterangan (Misal: Tulisan HBD Budi)",
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (context, setStateSB) {
                  return DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Status Pesanan",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Baru', child: Text('Baru')),
                      DropdownMenuItem(value: 'Proses', child: Text('Proses')),
                      DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setStateSB(() => selectedStatus = value);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            onPressed: () async {
              String tanggalSekarang =
                  DateTime.now().toString().substring(0, 16);

              DesainPesananEntity data = DesainPesananEntity(
                id: isEdit ? desain.id : 0,
                idPesanan: int.tryParse(idPesananController.text) ?? 0,
                fileDesainUrl: urlController.text,
                keterangan: keteranganController.text,
                tanggalUpload: isEdit ? desain.tanggalUpload : tanggalSekarang,
                statusPesanan: selectedStatus,
              );

              bool success;
              if (isEdit) {
                success = await ApiService.updateDesainPesanan(data);
              } else {
                success = await ApiService.createDesainPesanan(data);
              }

              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "Berhasil disimpan" : "Gagal menyimpan data"),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
              _refreshData();
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    if (status.toLowerCase() == 'baru') {
      bgColor = Colors.blue;
    } else if (status.toLowerCase() == 'proses') {
      bgColor = Colors.yellow[700]!;
    } else if (status.toLowerCase() == 'selesai') {
      bgColor = Colors.green;
    } else {
      bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
