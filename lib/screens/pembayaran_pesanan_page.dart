import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pesanan_entity.dart';
import '../models/desain_pesanan_entity.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentItem {
  final bool isDesain;
  final PesananEntity pesanan;
  final DesainPesananEntity? desain;

  PaymentItem({
    required this.isDesain,
    required this.pesanan,
    this.desain,
  });
}

class PembayaranPesananPage extends StatefulWidget {
  const PembayaranPesananPage({super.key});

  @override
  State<PembayaranPesananPage> createState() => _PembayaranPesananPageState();
}

class _PembayaranPesananPageState extends State<PembayaranPesananPage> {
  List<PaymentItem> listPembayaran = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    var pesananData = await ApiService.getAllPesanan();
    var desainData = await ApiService.getAllDesainPesanan();

    List<PaymentItem> temp = [];

    // 1. Tambahkan pesanan reguler yang berstatus 'proses' atau 'selesai'
    for (var p in pesananData) {
      if (p.statusPesanan.toLowerCase() == 'proses' ||
          p.statusPesanan.toLowerCase() == 'selesai') {
        temp.add(PaymentItem(isDesain: false, pesanan: p));
      }
    }

    // 2. Tambahkan pesanan desain kue custom yang berstatus 'proses' atau 'selesai'
    for (var d in desainData) {
      if (d.statusPesanan.toLowerCase() == 'proses' ||
          d.statusPesanan.toLowerCase() == 'selesai') {
        var parent = pesananData.firstWhere(
          (p) => p.id == d.idPesanan,
          orElse: () => PesananEntity(
            id: d.idPesanan,
            namaPelanggan: 'Pelanggan #${d.idPesanan}',
            idProduk: 0,
            jumlah: 0,
            totalHarga: 0.0,
            statusPesanan: d.statusPesanan,
            detailPesanan: '[]',
          ),
        );
        temp.add(PaymentItem(isDesain: true, pesanan: parent, desain: d));
      }
    }

    setState(() {
      listPembayaran = temp;
      isLoading = false;
    });
  }

  // --- POP-UP DETAIL ONLY ---
  void _showDetailOnlyDialog(PesananEntity pesanan) {
    List<dynamic> items = [];
    try {
      if (pesanan.detailPesanan.isNotEmpty && pesanan.detailPesanan != '[]') {
        items = jsonDecode(pesanan.detailPesanan);
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFDF1E9),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail Pembayaran",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Pelanggan: ${pesanan.namaPelanggan}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Builder(builder: (context) {
                List<dynamic> menuItems = items.where((it) => it['bagian'] == 'Menu Kami').toList();
                List<dynamic> produkItems = items.where((it) => it['bagian'] == 'Produk Unggulan').toList();
                List<Widget> widgets = [];
                if (menuItems.isNotEmpty) {
                  widgets.add(Text("Daftar Item Menu:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.brown.shade700)));
                  widgets.add(const SizedBox(height: 8));
                  for (var item in menuItems) {
                    final name = item['namaProduk'] ?? item['name'] ?? '-';
                    final qty = item['qty'] ?? item['quantity'] ?? 1;
                    final subtotal = item['subtotal'] ?? (((item['harga'] ?? item['price'] ?? 0) as num) * (qty as num));
                    widgets.add(Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text("- $name x$qty (Rp ${formatRupiah(subtotal)})", style: const TextStyle(fontSize: 14)),
                    ));
                  }
                  widgets.add(const SizedBox(height: 12));
                }
                if (produkItems.isNotEmpty) {
                  widgets.add(Text("Daftar Item Produk:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.brown.shade700)));
                  widgets.add(const SizedBox(height: 8));
                  for (var item in produkItems) {
                    final name = item['namaProduk'] ?? item['name'] ?? '-';
                    final qty = item['qty'] ?? item['quantity'] ?? 1;
                    final subtotal = item['subtotal'] ?? (((item['harga'] ?? item['price'] ?? 0) as num) * (qty as num));
                    widgets.add(Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text("- $name x$qty (Rp ${formatRupiah(subtotal)})", style: const TextStyle(fontSize: 14)),
                    ));
                  }
                  widgets.add(const SizedBox(height: 12));
                }
                // Fallback for legacy items without 'bagian'
                List<dynamic> legacyItems = items.where((it) => it['bagian'] == null || (it['bagian'] != 'Menu Kami' && it['bagian'] != 'Produk Unggulan')).toList();
                if (legacyItems.isNotEmpty) {
                  widgets.add(Text("Daftar Item Menu:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.brown.shade700)));
                  widgets.add(const SizedBox(height: 8));
                  for (var item in legacyItems) {
                    final name = item['namaProduk'] ?? item['name'] ?? '-';
                    final qty = item['qty'] ?? item['quantity'] ?? 1;
                    final subtotal = item['subtotal'] ?? (((item['harga'] ?? item['price'] ?? 0) as num) * (qty as num));
                    widgets.add(Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text("- $name x$qty (Rp ${formatRupiah(subtotal)})", style: const TextStyle(fontSize: 14)),
                    ));
                  }
                }
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
              }),

              const Divider(height: 30, thickness: 1),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Status:",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pesanan.statusPesanan.toLowerCase() == 'selesai'
                          ? Colors.green
                          : pesanan.statusPesanan.toLowerCase() == 'proses'
                          ? Colors.orange
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pesanan.statusPesanan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                "Total Bayar: Rp ${formatRupiah(pesanan.totalHarga)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "TUTUP",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDesainDetailOnlyDialog(PaymentItem item) {
    String extNama = "Kue Custom";
    String extDeskripsi = item.desain!.keterangan ?? "";
    String extHarga = "0";

    String raw = item.desain!.keterangan ?? "";
    if (raw.contains("Nama Produk:")) {
      for (var line in raw.split('\n')) {
        if (line.startsWith("Nama Produk:")) extNama = line.replaceAll("Nama Produk:", "").trim();
        if (line.startsWith("Deskripsi:")) extDeskripsi = line.replaceAll("Deskripsi:", "").trim();
        if (line.startsWith("Harga:")) extHarga = line.replaceAll("Harga:", "").trim();
      }
    } else if (raw.contains("Template Kue Custom:")) {
      var parts = raw.split("Template Kue Custom:")[1].split(".");
      if (parts.isNotEmpty) {
        extNama = parts[0].trim();
        if (parts.length > 1) extDeskripsi = parts.sublist(1).join(".").trim();
      }
    }

    num valHarga = num.tryParse(extHarga) ?? 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFDF1E9),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detail Pembayaran (Kue Custom)",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "ID Pesanan: ${item.desain!.id}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Nama Produk: $extNama",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Kategori: Kue Custom",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Deskripsi: $extDeskripsi",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if (item.desain!.fileDesainUrl != null && item.desain!.fileDesainUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    "Gambar Desain:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: item.desain!.fileDesainUrl!.startsWith('http')
                          ? Image.network(
                              item.desain!.fileDesainUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => const Icon(Icons.broken_image, size: 50),
                            )
                          : Image.file(
                              File(item.desain!.fileDesainUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => const Icon(Icons.broken_image, size: 50),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Link/URL Desain:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      String url = item.desain!.fileDesainUrl!;
                      bool isFile = url.startsWith('/') ||
                          url.startsWith('file://') ||
                          url.startsWith('content://') ||
                          url.startsWith('C:');
                      if (!isFile) {
                        String launchUriStr = url.startsWith('http') ? url : 'https://$url';
                        final uri = Uri.parse(launchUriStr);
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          debugPrint("Tidak dapat membuka URL: $e");
                        }
                      }
                    },
                    child: Text(
                      item.desain!.fileDesainUrl!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(height: 30, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Status:",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.desain!.statusPesanan.toLowerCase() == 'selesai'
                            ? Colors.green
                            : item.desain!.statusPesanan.toLowerCase() == 'proses'
                            ? Colors.orange
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.desain!.statusPesanan,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  "Total Bayar: Rp ${formatRupiah(valHarga)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D4C41),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "TUTUP",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- POP-UP EDIT STATUS ---
  void _showEditStatusDialog(PaymentItem item) {
    List<String> statusOptions = ["Proses", "Selesai"];

    String currentStatus = item.isDesain ? item.desain!.statusPesanan : item.pesanan.statusPesanan;
    String selectedStatus = statusOptions.contains(currentStatus)
        ? currentStatus
        : statusOptions[0];

    List<dynamic> items = [];
    try {
      if (item.pesanan.detailPesanan.isNotEmpty && item.pesanan.detailPesanan != '[]') {
        items = jsonDecode(item.pesanan.detailPesanan);
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF1E9),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.isDesain ? "Detail Pembayaran (Kue Custom)" : "Detail Pembayaran",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (item.isDesain) ...[
                    Builder(
                      builder: (context) {
                        String extNama = "Kue Custom";
                        String raw = item.desain!.keterangan ?? "";
                        if (raw.contains("Nama Produk:")) {
                          for (var line in raw.split('\n')) {
                            if (line.startsWith("Nama Produk:")) extNama = line.replaceAll("Nama Produk:", "").trim();
                          }
                        } else if (raw.contains("Template Kue Custom:")) {
                          var parts = raw.split("Template Kue Custom:")[1].split(".");
                          if (parts.isNotEmpty) extNama = parts[0].trim();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ID Pesanan: ${item.desain!.id}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Nama Produk: $extNama",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      }
                    ),
                  ] else ...[
                    Text(
                      "Pelanggan: ${item.pesanan.namaPelanggan}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (item.isDesain && item.desain!.keterangan != null && item.desain!.keterangan!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Deskripsi: ${item.desain!.keterangan}",
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                  if (!item.isDesain) ...[
                    const SizedBox(height: 12),
                    Builder(builder: (context) {
                      List<dynamic> menuItems = items.where((it) => it['bagian'] == 'Menu Kami').toList();
                      List<dynamic> produkItems = items.where((it) => it['bagian'] == 'Produk Unggulan').toList();
                      List<Widget> widgets = [];
                      if (menuItems.isNotEmpty) {
                        widgets.add(Text("Daftar Item Menu:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.brown.shade700)));
                        widgets.add(const SizedBox(height: 8));
                        for (var it in menuItems) {
                          final name = it['namaProduk'] ?? it['name'] ?? '-';
                          final qty = it['qty'] ?? it['quantity'] ?? 1;
                          final subtotal = it['subtotal'] ?? (((it['harga'] ?? it['price'] ?? 0) as num) * (qty as num));
                          widgets.add(Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text("- $name x$qty (Rp ${formatRupiah(subtotal)})", style: const TextStyle(fontSize: 14)),
                          ));
                        }
                        widgets.add(const SizedBox(height: 12));
                      }
                      if (produkItems.isNotEmpty) {
                        widgets.add(Text("Daftar Item Produk:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.brown.shade700)));
                        widgets.add(const SizedBox(height: 8));
                        for (var it in produkItems) {
                          final name = it['namaProduk'] ?? it['name'] ?? '-';
                          final qty = it['qty'] ?? it['quantity'] ?? 1;
                          final subtotal = it['subtotal'] ?? (((it['harga'] ?? it['price'] ?? 0) as num) * (qty as num));
                          widgets.add(Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text("- $name x$qty (Rp ${formatRupiah(subtotal)})", style: const TextStyle(fontSize: 14)),
                          ));
                        }
                        widgets.add(const SizedBox(height: 12));
                      }
                      // Fallback for legacy items without 'bagian'
                      List<dynamic> legacyItems = items.where((it) => it['bagian'] == null || (it['bagian'] != 'Menu Kami' && it['bagian'] != 'Produk Unggulan')).toList();
                      if (legacyItems.isNotEmpty) {
                        widgets.add(Text("Daftar Item Menu:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.brown.shade700)));
                        widgets.add(const SizedBox(height: 8));
                        for (var it in legacyItems) {
                          final name = it['namaProduk'] ?? it['name'] ?? '-';
                          final qty = it['qty'] ?? it['quantity'] ?? 1;
                          final subtotal = it['subtotal'] ?? (((it['harga'] ?? it['price'] ?? 0) as num) * (qty as num));
                          widgets.add(Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text("- $name x$qty (Rp ${formatRupiah(subtotal)})", style: const TextStyle(fontSize: 14)),
                          ));
                        }
                      }
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
                    }),
                  ],
                  const Divider(height: 30, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Status:", style: TextStyle(fontSize: 15)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedStatus,
                          dropdownColor: const Color(0xFFFDF1E9),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          items: statusOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setDialogState(() {
                              selectedStatus = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Total Bayar: Rp ${formatRupiah(item.pesanan.totalHarga)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C41),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "BATAL",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6E63),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          if (item.isDesain) {
                            DesainPesananEntity desainBaru = DesainPesananEntity(
                              id: item.desain!.id,
                              idPesanan: item.desain!.idPesanan,
                              fileDesainUrl: item.desain!.fileDesainUrl,
                              keterangan: item.desain!.keterangan,
                              tanggalUpload: item.desain!.tanggalUpload,
                              statusPesanan: selectedStatus,
                            );
                            await ApiService.updateDesainPesanan(desainBaru);
                          } else {
                            PesananEntity pesananBaru = PesananEntity(
                              id: item.pesanan.id,
                              namaPelanggan: item.pesanan.namaPelanggan,
                              idProduk: item.pesanan.idProduk,
                              jumlah: item.pesanan.jumlah,
                              totalHarga: item.pesanan.totalHarga,
                              statusPesanan: selectedStatus,
                              tanggalPesanan: item.pesanan.tanggalPesanan,
                              detailPesanan: item.pesanan.detailPesanan,
                            );
                            await ApiService.updatePesanan(pesananBaru);
                          }
                          if (context.mounted) Navigator.pop(context);
                          _fetchData();
                        },
                        child: const Text(
                          "SIMPAN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color bgColor = Colors.orange;
    String cleanStatus = status.toLowerCase();

    if (cleanStatus == 'selesai') {
      bgColor = Colors.green;
    } else {
      bgColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String formatRupiah(num value) {
    String str = value.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i > 0) {
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
          'Konfirmasi Pembayaran',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : listPembayaran.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listPembayaran.length,
              itemBuilder: (context, index) {
                var item = listPembayaran[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFD7D1CE),
                      child: Icon(
                        Icons.monetization_on,
                        color: Colors.brown[700],
                      ),
                    ),
                    title: Builder(
                      builder: (context) {
                        if (item.isDesain) {
                          return Text(
                            "ID Pesanan: ${item.desain!.id} - Kategori: Kue Custom",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        } else {
                          return Text(
                            item.pesanan.namaPelanggan,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        }
                      }
                    ),
                    subtitle: Builder(
                      builder: (context) {
                        if (item.isDesain) {
                          String extNama = "Kue Custom";
                          String raw = item.desain!.keterangan ?? "";
                          if (raw.contains("Nama Produk:")) {
                            for (var line in raw.split('\n')) {
                              if (line.startsWith("Nama Produk:")) extNama = line.replaceAll("Nama Produk:", "").trim();
                            }
                          } else if (raw.contains("Template Kue Custom:")) {
                            var parts = raw.split("Template Kue Custom:")[1].split(".");
                            if (parts.isNotEmpty) extNama = parts[0].trim();
                          }

                          String extHarga = "0";
                          if (raw.contains("Harga:")) {
                            for (var line in raw.split('\n')) {
                              if (line.startsWith("Harga:")) extHarga = line.replaceAll("Harga:", "").trim();
                            }
                          }
                          num val = num.tryParse(extHarga) ?? 0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "Nama Produk: $extNama",
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text("Total Bayar: Rp ${formatRupiah(val)}"),
                              const SizedBox(height: 4),
                              _buildStatusTag(item.desain!.statusPesanan),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Total Bayar: Rp ${formatRupiah(item.pesanan.totalHarga)}"),
                              const SizedBox(height: 4),
                              _buildStatusTag(item.pesanan.statusPesanan),
                            ],
                          );
                        }
                      }
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditStatusDialog(item),
                        ),
                      ],
                    ),
                    onTap: () => _showPaymentDetail(item),
                  ),
                );
              },
            ),
    );
  }

  void _showPaymentDetail(PaymentItem item) {
    if (item.isDesain) {
      _showDesainDetailOnlyDialog(item);
    } else {
      _showDetailOnlyDialog(item.pesanan);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada tagihan aktif",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
