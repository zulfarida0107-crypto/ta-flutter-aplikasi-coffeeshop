import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/desain_pesanan_entity.dart';
import '../models/pesanan_entity.dart';
import '../models/menu_produk_entity.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'home_page.dart';

class DesainPesananPage extends StatefulWidget {
  const DesainPesananPage({super.key});

  @override
  State<DesainPesananPage> createState() => _DesainPesananPageState();
}

class _DesainPesananPageState extends State<DesainPesananPage> {
  List<DesainPesananEntity> listDesain = [];
  List<PesananEntity> listPesanan = [];
  List<MenuProdukEntity> listMenu = [];
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
    var dataDesain = await ApiService.getAllDesainPesanan();
    var dataPesanan = await ApiService.getAllPesanan();
    var dataMenu = await ApiService.getAllMenuProduk();

    setState(() {
      listPesanan = dataPesanan;
      listMenu = dataMenu;
      listDesain = dataDesain.where((d) => d.statusPesanan.toLowerCase() == 'baru').toList();
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          },
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
                    // Extract Nama Produk and Deskripsi from keterangan
                    String rawKeterangan = desain.keterangan ?? "";
                    String extNama = "Kue Custom";
                    String extDeskripsi = rawKeterangan;

                    if (rawKeterangan.contains("Nama Produk:")) {
                      var lines = rawKeterangan.split('\n');
                      for (var line in lines) {
                        if (line.startsWith("Nama Produk:")) extNama = line.replaceAll("Nama Produk:", "").trim();
                        if (line.startsWith("Deskripsi:")) extDeskripsi = line.replaceAll("Deskripsi:", "").trim();
                      }
                    } else if (rawKeterangan.contains("Template Kue Custom:")) {
                      var parts = rawKeterangan.split("Template Kue Custom:")[1].split(".");
                      if (parts.isNotEmpty) {
                        extNama = parts[0].trim();
                        if (parts.length > 1) extDeskripsi = parts.sublist(1).join(".").trim();
                      }
                    }

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
                          "ID Pesanan: ${desain.id} - $extNama",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (extDeskripsi.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(extDeskripsi, style: TextStyle(color: Colors.brown.shade700)),
                            ],
                            const SizedBox(height: 4),
                            _buildStatusBadge(desain.statusPesanan),
                          ],
                        ),
                        onTap: () {
                          _showDetailDialog(desain, extNama);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showFormDialog(desain: desain, namaProduk: extNama);
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

  Widget _buildSubtitleDescription(String? keterangan) {
    if (keterangan == null || keterangan.isEmpty) {
      return const Text("Tidak ada deskripsi");
    }

    if (keterangan.startsWith("Template Kue Custom:")) {
      String rest = keterangan.substring("Template Kue Custom:".length).trim();
      List<String> parts = [];
      if (rest.contains(" . ")) {
        parts = rest.split(" . ");
      } else if (rest.contains("\n")) {
        parts = rest.split("\n");
      }

      if (parts.length >= 2) {
        String templateName = parts[0].trim();
        String desc = parts.sublist(1).join(" . ").trim();
        if (desc.startsWith("Deskripsi:")) {
          desc = desc.substring("Deskripsi:".length).trim();
        }
        return Text(
          "$templateName - $desc",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
      return Text(
        rest,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (keterangan.contains("Kategori: Kue Custom")) {
      List<String> lines = keterangan.split("\n");
      String templateName = "";
      String desc = "";
      for (var line in lines) {
        if (line.startsWith("Nama Produk:")) {
          templateName = line.substring("Nama Produk:".length).trim();
        } else if (line.startsWith("Deskripsi:")) {
          desc = line.substring("Deskripsi:".length).trim();
        }
      }
      if (templateName.isNotEmpty && desc.isNotEmpty) {
        return Text(
          "$templateName - $desc",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      } else if (templateName.isNotEmpty) {
        return Text(
          templateName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    }

    return Text(
      keterangan,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescriptionDetails(String? keterangan) {
    if (keterangan == null || keterangan.isEmpty) {
      return const Text("Deskripsi: -", style: TextStyle(fontSize: 16));
    }

    if (keterangan.startsWith("Template Kue Custom:")) {
      String rest = keterangan.substring("Template Kue Custom:".length).trim();
      List<String> parts = [];
      if (rest.contains(" . ")) {
        parts = rest.split(" . ");
      } else if (rest.contains("\n")) {
        parts = rest.split("\n");
      }

      if (parts.length >= 2) {
        String templateName = parts[0].trim();
        String desc = parts.sublist(1).join(" . ").trim();
        if (desc.startsWith("Deskripsi:")) {
          desc = desc.substring("Deskripsi:".length).trim();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Template Kue Custom: $templateName",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Deskripsi: $desc",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Template Kue Custom: $rest",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }
    } else if (keterangan.contains("Kategori: Kue Custom")) {
      List<String> lines = keterangan.split("\n");
      String templateName = "";
      String desc = "";
      for (var line in lines) {
        if (line.startsWith("Nama Produk:")) {
          templateName = line.substring("Nama Produk:".length).trim();
        } else if (line.startsWith("Deskripsi:")) {
          desc = line.substring("Deskripsi:".length).trim();
        }
      }

      if (templateName.isNotEmpty || desc.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (templateName.isNotEmpty) ...[
              Text(
                "Template Kue Custom: $templateName",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              "Deskripsi: ${desc.isNotEmpty ? desc : '-'}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );
      }
    }

    return Text(
      "Deskripsi: $keterangan",
      style: const TextStyle(fontSize: 16),
    );
  }

  // --- POP-UP UNTUK VIEW DETAIL ---
  void _showDetailDialog(DesainPesananEntity desain, String namaProduk) {
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
              "ID Pesanan: ${desain.id}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Nama Produk: $namaProduk",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                String extHarga = "-";
                if (desain.keterangan != null && desain.keterangan!.contains("Harga:")) {
                  for (var line in desain.keterangan!.split('\n')) {
                    if (line.startsWith("Harga:")) {
                      extHarga = line.replaceAll("Harga:", "").trim();
                    }
                  }
                }
                return Text(
                  "Harga: Rp $extHarga",
                  style: const TextStyle(fontSize: 16),
                );
              }
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
                      child: Text(
                        url,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              const Text("-", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text("Gambar Desain:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (desain.fileDesainUrl != null &&
                desain.fileDesainUrl!.isNotEmpty)
              Builder(
                builder: (context) {
                  String url = desain.fileDesainUrl!;
                  bool isHttp = url.startsWith('http');
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Center(
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isHttp
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 50),
                              )
                            : Image.file(
                                File(url),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                      ),
                    ),
                  );
                },
              )
            else
              const Text("-", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildDescriptionDetails(desain.keterangan),
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
  void _showFormDialog({DesainPesananEntity? desain, String namaProduk = "Kue Custom"}) async {
    bool isEdit = desain != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.brown)),
    );

    List<MenuProdukEntity> listMenu = [];
    try {
      listMenu = await ApiService.getAllMenuProduk();
    } catch (_) {}

    if (context.mounted) Navigator.pop(context); // close loading

    List<MenuProdukEntity> kueCustomMenu = listMenu.where((m) => m.kategori.toLowerCase() == 'kue custom').toList();
    int? selectedIdPesanan;

    TextEditingController idPesananController = TextEditingController(
      text: isEdit ? desain.idPesanan.toString() : "",
    );

    TextEditingController urlController = TextEditingController(
      text: isEdit ? desain.fileDesainUrl : "",
    );
    TextEditingController keteranganController = TextEditingController(
      text: isEdit ? desain.keterangan : "",
    );

    String extHarga = "";
    if (isEdit && desain.keterangan != null && desain.keterangan!.contains("Harga:")) {
      for (var line in desain.keterangan!.split('\n')) {
        if (line.startsWith("Harga:")) {
          extHarga = line.replaceAll("Harga:", "").trim();
        }
      }
    }
    TextEditingController hargaController = TextEditingController(text: extHarga);

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
              if (isEdit)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.transparent, 
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.brown.shade300, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.brown.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "ID Pesanan: ${desain.id} - $namaProduk",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.brown.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.brown.shade300, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.brown.shade400),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "ID Pesanan: Otomatis",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.brown.shade400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
                  labelText: "Deskripsi (Misal: Tulisan HBD Budi)",
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga (Misal: 150000)",
                ),
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
              String finalKeterangan = keteranganController.text;
              if (hargaController.text.isNotEmpty) {
                if (finalKeterangan.contains("Harga:")) {
                  var lines = finalKeterangan.split('\n');
                  for (int i = 0; i < lines.length; i++) {
                    if (lines[i].startsWith("Harga:")) {
                      lines[i] = "Harga: ${hargaController.text}";
                    }
                  }
                  finalKeterangan = lines.join('\n');
                } else {
                  finalKeterangan += "\nHarga: ${hargaController.text}";
                }
              }

              String tanggalSekarang =
                  DateTime.now().toString().substring(0, 16);

              int finalIdPesanan = isEdit ? desain.idPesanan : 1;
              if (!isEdit) {
                try {
                  var pesananList = await ApiService.getAllPesanan();
                  if (pesananList.isNotEmpty) {
                    finalIdPesanan = pesananList.first.id;
                  }
                } catch (_) {}
              }

              DesainPesananEntity data = DesainPesananEntity(
                id: isEdit ? desain.id : 0,
                idPesanan: finalIdPesanan,
                fileDesainUrl: urlController.text,
                keterangan: finalKeterangan,
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
