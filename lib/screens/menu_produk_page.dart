import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_produk_entity.dart';
import '../models/desain_pesanan_entity.dart';
import '../services/api_service.dart';

class MenuProdukPage extends StatefulWidget {
  const MenuProdukPage({super.key});

  @override
  State<MenuProdukPage> createState() => _MenuProdukPageState();
}

class _MenuProdukPageState extends State<MenuProdukPage> {
  List<MenuProdukEntity> listMenu = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    setState(() => isLoading = true);
    var data = await ApiService.getAllMenuProduk();
    setState(() {
      listMenu = data.where((m) => m.kategori.toLowerCase() != 'kue custom').toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Menu Produk',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown[800],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : listMenu.isEmpty
              ? const Center(child: Text("Belum ada menu. Klik + untuk tambah!"))
              : ListView.builder(
                  itemCount: listMenu.length,
                  itemBuilder: (context, index) {
                    var menu = listMenu[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown[100],
                          child: const Icon(Icons.coffee, color: Colors.brown),
                        ),
                        title: Text(
                          "ID: ${menu.id} - ${menu.namaProduk}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildKategoriBadge(menu.kategori),
                                _buildBagianBadge(menu.bagian),
                                Text(
                                  "Rp ${menu.harga.toInt()}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (menu.deskripsi != null &&
                                menu.deskripsi!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                menu.deskripsi!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        onTap: () => _showDetailDialog(menu),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFormDialog(menu: menu),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(menu),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- LOGIK KONFIRMASI HAPUS ---
  void _confirmDelete(MenuProdukEntity menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Konfirmasi Hapus",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Apakah anda yakin menghapus menu?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("tidak", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService.deleteMenuProduk(menu.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data berhasil dihapus permanen"),
                    backgroundColor: Colors.brown,
                  ),
                );
              }
              _refreshData();
            },
            child: const Text("ya", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- POP-UP UNTUK VIEW DETAIL ---
  void _showDetailDialog(MenuProdukEntity menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Detail Produk",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.brown[100],
                child: const Icon(Icons.coffee, size: 40, color: Colors.brown),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "ID: ${menu.id}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Nama: ${menu.namaProduk}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Harga: Rp ${menu.harga.toInt()}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (menu.deskripsi != null && menu.deskripsi!.isNotEmpty) ...[
              Text(
                "Deskripsi: ${menu.deskripsi}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Text("Kategori: ", style: TextStyle(fontSize: 16)),
                _buildKategoriBadge(menu.kategori),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Bagian Tampilan: ", style: TextStyle(fontSize: 16)),
                _buildBagianBadge(menu.bagian),
              ],
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

  Widget _buildBagianBadge(String bagian) {
    Color bgColor = Colors.brown[500]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bagian,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildKategoriBadge(String kategori) {
    Color bgColor;
    String lowerKategori = kategori.toLowerCase();
    if (lowerKategori == 'kopi') {
      bgColor = Colors.brown[400]!;
    } else if (lowerKategori == 'non-kopi') {
      bgColor = const Color(0xFF6DA4DE);
    } else if (lowerKategori == 'pastry') {
      bgColor = const Color(0xFFE692CF);
    } else if (lowerKategori == 'kue custom') {
      bgColor = const Color(0xFFAC92ED);
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
        kategori,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- POP-UP FORM UNTUK TAMBAH & EDIT ---
  void _showFormDialog({MenuProdukEntity? menu}) {
    bool isEdit = menu != null;

    TextEditingController namaController = TextEditingController(
      text: isEdit ? menu.namaProduk : "",
    );
    TextEditingController hargaController = TextEditingController(
      text: isEdit ? menu.harga.toInt().toString() : "",
    );
    TextEditingController deskripsiController = TextEditingController(
      text: isEdit ? (menu.deskripsi ?? "") : "",
    );
    TextEditingController gambarController = TextEditingController(
      text: isEdit ? (menu.gambar ?? "") : "",
    );

    List<String> kategoriList = ['Kopi', 'Non-Kopi', 'Pastry', 'Kue Custom'];
    String selectedKategori = (isEdit && kategoriList.contains(menu.kategori))
        ? menu.kategori
        : 'Kopi';

    List<String> bagianList = ['Menu Kami', 'Produk Unggulan'];
    String dbBagian = isEdit ? (menu.bagian) : 'Menu Kami';
    if (dbBagian == 'Produk Unggulan Kami') {
      dbBagian = 'Produk Unggulan';
    }
    String selectedBagian = (isEdit && bagianList.contains(dbBagian))
        ? dbBagian
        : 'Menu Kami';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? "Edit Menu Produk" : "Tambah Menu Baru"),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (dialogContext, setStateSB) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: "Nama Produk"),
                  ),
                  TextField(
                    controller: deskripsiController,
                    decoration: InputDecoration(
                      labelText: "Deskripsi",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste, size: 20, color: Colors.blue),
                        tooltip: "Tempel Deskripsi",
                        onPressed: () async {
                          ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data != null && data.text != null) {
                            setStateSB(() {
                              deskripsiController.text = data.text!;
                            });
                          }
                        },
                      ),
                    ),
                    maxLines: 2,
                  ),
                  TextField(
                    controller: hargaController,
                    decoration: const InputDecoration(
                      labelText: "Harga (Contoh: 15000)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: gambarController,
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
                            setStateSB(() {
                              gambarController.text = data.text!;
                            });
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
                            setStateSB(() {
                              gambarController.text = image.path;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedKategori,
                    decoration: const InputDecoration(
                      labelText: "Kategori",
                      border: OutlineInputBorder(),
                    ),
                    items: kategoriList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateSB(() {
                          selectedKategori = value;
                          if (selectedKategori == 'Kue Custom') {
                            selectedBagian = 'Menu Kami';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  if (selectedKategori != 'Kue Custom') ...[
                    DropdownButtonFormField<String>(
                      value: selectedBagian,
                      decoration: const InputDecoration(
                        labelText: "Bagian Tampilan",
                        border: OutlineInputBorder(),
                      ),
                      items: bagianList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateSB(() {
                            selectedBagian = value;
                          });
                        }
                      },
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        "Bagian Tampilan: Tidak Aktif (Kue Custom)",
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ),
                  ],
                ],
              );
            },
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
              double parsedHarga = double.tryParse(hargaController.text) ?? 0.0;

              MenuProdukEntity data = MenuProdukEntity(
                id: isEdit ? menu.id : 0,
                namaProduk: namaController.text,
                harga: parsedHarga,
                deskripsi: deskripsiController.text,
                kategori: selectedKategori,
                gambar: gambarController.text,
                bagian: selectedBagian,
              );

              bool success;
              if (isEdit) {
                success = await ApiService.updateMenuProduk(data);
              } else {
                success = await ApiService.createMenuProduk(data);
              }

              bool shouldCreateDesain = false;
              if (success) {
                if (isEdit) {
                  if (menu.kategori != 'Kue Custom' && selectedKategori == 'Kue Custom') {
                    shouldCreateDesain = true;
                  }
                } else {
                  if (selectedKategori == 'Kue Custom') {
                    shouldCreateDesain = true;
                  }
                }
              }

               if (shouldCreateDesain) {
                int fallbackPesananId = 1;
                try {
                  var pesananList = await ApiService.getAllPesanan();
                  if (pesananList.isNotEmpty) {
                    fallbackPesananId = pesananList.first.id;
                  }
                } catch (_) {}

                DesainPesananEntity desain = DesainPesananEntity(
                  id: 0,
                  idPesanan: fallbackPesananId,
                  fileDesainUrl: data.gambar ?? '1.jpg',
                  keterangan: "Kategori: Kue Custom\nNama Produk: ${data.namaProduk}\nDeskripsi: ${data.deskripsi ?? ''}\nHarga: ${data.harga.toInt()}",
                  tanggalUpload: DateTime.now().toIso8601String(),
                  statusPesanan: "Baru",
                );
                await ApiService.createDesainPesanan(desain);
              }

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "Berhasil disimpan" : "Gagal menyimpan data"),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                _refreshData();
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
