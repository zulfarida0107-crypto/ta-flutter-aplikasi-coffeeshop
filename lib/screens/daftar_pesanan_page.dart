import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/pesanan_entity.dart';
import '../models/menu_produk_entity.dart';
import '../services/api_service.dart';

class DaftarPesananPage extends StatefulWidget {
  const DaftarPesananPage({super.key});

  @override
  State<DaftarPesananPage> createState() => _DaftarPesananPageState();
}

class _DaftarPesananPageState extends State<DaftarPesananPage> {
  List<PesananEntity> listPesanan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    setState(() => isLoading = true);
    var data = await ApiService.getAllPesanan();
    setState(() {
      listPesanan = data
          .where((p) => p.statusPesanan.toLowerCase() == 'baru')
          .toList();
      isLoading = false;
    });
  }

  // Helper function untuk format penulisan nominal Rupiah dengan ribuan (e.g. 15.000)
  String formatRupiah(num value) {
    String str = value.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i > 0 && str[i - 1] != '-') {
        result = '.$result';
        count = 0;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan Masuk',
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
          : listPesanan.isEmpty
              ? const Center(child: Text("Belum ada pesanan masuk."))
              : ListView.builder(
                  itemCount: listPesanan.length,
                  itemBuilder: (context, index) {
                    var pesanan = listPesanan[index];

                    // Menentukan item/qty preview
                    int totalItem = pesanan.jumlah;
                    try {
                      if (pesanan.detailPesanan.isNotEmpty &&
                          pesanan.detailPesanan != '[]') {
                        List<dynamic> items = jsonDecode(pesanan.detailPesanan);
                        totalItem = items.fold(
                          0,
                          (sum, it) => sum + ((it['qty'] ?? it['quantity'] ?? 1) as int),
                        );
                      }
                    } catch (_) {}

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown[100],
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.brown,
                          ),
                        ),
                        title: Text(
                          pesanan.namaPelanggan,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            _buildStatusBadge(pesanan.statusPesanan),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Rp ${formatRupiah(pesanan.totalHarga)} ($totalItem item)",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _showDetailDialog(pesanan);
                        },
                        trailing: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showFormDialog(pesanan: pesanan);
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
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                            await ApiService.deletePesanan(pesanan.id);
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

  // --- POP-UP UNTUK VIEW DETAIL ---
  void _showDetailDialog(PesananEntity pesanan) {
    List<dynamic> items = [];
    try {
      if (pesanan.detailPesanan.isNotEmpty && pesanan.detailPesanan != '[]') {
        items = jsonDecode(pesanan.detailPesanan);
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pelanggan: ${pesanan.namaPelanggan}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (items.isEmpty) ...[
                  // Compatibility Legacy
                  Text(
                    "ID Produk: ${pesanan.idProduk}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Jumlah Beli: ${pesanan.jumlah} item",
                    style: const TextStyle(fontSize: 16),
                  ),
                ] else ...[
                  const Text(
                    "Daftar Item Menu:",
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...items.map((item) {
                    // Support both CI4 format (qty/price) and Flutter format (qty/subtotal)
                    final name = item['namaProduk'] ?? item['name'] ?? '-';
                    final qty = item['qty'] ?? item['quantity'] ?? 1;
                    final subtotal = item['subtotal'] ?? (((item['harga'] ?? item['price'] ?? 0) as num) * (qty as num));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "- $name x$qty (Rp ${formatRupiah(subtotal)})",
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }),
                ],
                const Divider(),
                Text(
                  "Total Harga: Rp ${formatRupiah(pesanan.totalHarga)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Status: ", style: TextStyle(fontSize: 16)),
                    _buildStatusBadge(pesanan.statusPesanan),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Waktu: ${pesanan.tanggalPesanan ?? '-'}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
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

  // --- POP-UP FORM UNTUK TAMBAH & EDIT (DINAMIS CART SYSTEM) ---
  void _showFormDialog({PesananEntity? pesanan}) async {
    bool isEdit = pesanan != null;

    List<MenuProdukEntity> listMenu = await ApiService.getAllMenuProduk();
    if (listMenu.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Daftar Menu Produk masih kosong! Tambahkan menu terlebih dahulu.",
            ),
          ),
        );
      }
      return;
    }

    TextEditingController namaController = TextEditingController(
      text: isEdit ? pesanan.namaPelanggan : "",
    );
    String selectedStatus = "Baru";
    if (isEdit) {
      if (pesanan.statusPesanan.toLowerCase() == 'baru') selectedStatus = 'Baru';
      else if (pesanan.statusPesanan.toLowerCase() == 'proses') selectedStatus = 'Proses';
      else if (pesanan.statusPesanan.toLowerCase() == 'selesai') selectedStatus = 'Selesai';
    }

    // items merepresentasikan baris pesanan dinamis
    List<Map<String, dynamic>> menuItems = [];
    double grandTotal = 0.0;

    if (isEdit) {
      if (pesanan.detailPesanan.isNotEmpty && pesanan.detailPesanan != '[]') {
        try {
          List<dynamic> parsed = jsonDecode(pesanan.detailPesanan);
          for (var item in parsed) {
            int? idProd = item['idProduk'] != null
                ? (item['idProduk'] is int ? item['idProduk'] : int.tryParse(item['idProduk'].toString()))
                : (item['id'] != null ? (item['id'] is int ? item['id'] : int.tryParse(item['id'].toString())) : null);
            
            double harga = ((item['harga'] ?? item['price'] ?? 0) as num).toDouble();
            int qty = item['qty'] ?? item['quantity'] ?? 1;

            menuItems.add({
              "idProduk": idProd,
              "namaProduk": item['namaProduk'] ?? item['name'] ?? '',
              "harga": harga,
              "qty": qty,
              "subtotal": ((item['subtotal'] ?? (harga * qty)) as num).toDouble(),
            });
          }
          grandTotal = pesanan.totalHarga;
        } catch (e) {}
      }

      // Fallback jika kosong (data lama)
      if (menuItems.isEmpty) {
        menuItems.add({
          "idProduk": pesanan.idProduk,
          "namaProduk": "ID Produk: ${pesanan.idProduk}",
          "harga": pesanan.jumlah > 0 ? pesanan.totalHarga / pesanan.jumlah : 0.0,
          "qty": pesanan.jumlah,
          "subtotal": pesanan.totalHarga,
        });
        grandTotal = pesanan.totalHarga;
      }
    } else {
      menuItems.add({
        "idProduk": null,
        "namaProduk": "",
        "harga": 0.0,
        "qty": 1,
        "subtotal": 0.0,
      });
    }

    void hitungTotal(StateSetter setStateSB) {
      double total = 0.0;
      for (var item in menuItems) {
        if (item['idProduk'] != null) {
          item['subtotal'] = item['harga'] * item['qty'];
          total += item['subtotal'];
        }
      }
      setStateSB(() {
        grandTotal = total;
      });
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isEdit ? "Edit Pesanan" : "Tambah Pesanan Baru"),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setStateSB) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: "Nama Pelanggan",
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: "Status Pesanan",
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Baru', child: Text('Baru')),
                          DropdownMenuItem(
                            value: 'Proses',
                            child: Text('Proses'),
                          ),
                          DropdownMenuItem(
                            value: 'Selesai',
                            child: Text('Selesai'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setStateSB(() => selectedStatus = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Daftar Item Pesanan (Keranjang):",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Iterasi Baris Dinamis
                      ...menuItems.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;
                        bool menuValid = listMenu.any(
                          (m) => m.id == item['idProduk'],
                        );

                        return Card(
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Colors.brown,
                              width: 2,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        initialValue:
                                            menuValid ? item['idProduk'] : null,
                                        hint: const Text('Pilih Produk'),
                                        isExpanded: true,
                                        items: listMenu
                                            .map(
                                              (m) => DropdownMenuItem(
                                                value: m.id,
                                                child: Text(m.namaProduk),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            var sel = listMenu.firstWhere(
                                              (m) => m.id == val,
                                            );
                                            setStateSB(() {
                                              item['idProduk'] = val;
                                              item['namaProduk'] =
                                                  sel.namaProduk;
                                              item['harga'] = sel.harga;
                                              hitungTotal(setStateSB);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        if (menuItems.length > 1) {
                                          setStateSB(() {
                                            menuItems.removeAt(index);
                                            hitungTotal(setStateSB);
                                          });
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Pesanan wajib memiliki minimal 1 produk.",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          onPressed: () {
                                            if (item['qty'] > 1) {
                                              setStateSB(() {
                                                item['qty']--;
                                                hitungTotal(setStateSB);
                                              });
                                            }
                                          },
                                        ),
                                        Text(
                                          "${item['qty']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                          onPressed: () {
                                            setStateSB(() {
                                              item['qty']++;
                                              hitungTotal(setStateSB);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Rp ${formatRupiah(item['subtotal'])}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.brown,
                              width: 2,
                            ),
                            foregroundColor: Colors.brown,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text("Tambah Baris Menu"),
                          onPressed: () {
                            setStateSB(() {
                              menuItems.add({
                                "idProduk": null,
                                "namaProduk": "",
                                "harga": 0.0,
                                "qty": 1,
                                "subtotal": 0.0,
                              });
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Total Harga: Rp ${formatRupiah(grandTotal)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                bool isAllSelected = menuItems.every(
                  (it) => it['idProduk'] != null,
                );
                if (!isAllSelected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Tolong lengkapi pilihan produk di setiap baris!",
                      ),
                    ),
                  );
                  return;
                }

                String tanggalSekarang =
                    DateTime.now().toString().substring(0, 16);
                String detailJson = jsonEncode(menuItems);
                int totalQty = menuItems.fold(
                  0,
                  (sum, item) => sum + (item['qty'] as int),
                );

                PesananEntity pesananData = PesananEntity(
                  id: isEdit ? pesanan.id : 0,
                  namaPelanggan: namaController.text,
                  idProduk: menuItems.first['idProduk'],
                  jumlah: totalQty,
                  totalHarga: grandTotal,
                  statusPesanan: selectedStatus,
                  tanggalPesanan: isEdit ? pesanan.tanggalPesanan : tanggalSekarang,
                  detailPesanan: detailJson,
                );

                bool success;
                if (isEdit) {
                  success = await ApiService.updatePesanan(pesananData);
                } else {
                  success = await ApiService.createPesanan(pesananData);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? "Berhasil disimpan" : "Gagal menyimpan data"),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
                _refreshData();
              },
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }
}
