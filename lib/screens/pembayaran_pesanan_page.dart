import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/pesanan_entity.dart';
import '../services/api_service.dart';

class PembayaranPesananPage extends StatefulWidget {
  const PembayaranPesananPage({super.key});

  @override
  State<PembayaranPesananPage> createState() => _PembayaranPesananPageState();
}

class _PembayaranPesananPageState extends State<PembayaranPesananPage> {
  List<PesananEntity> listPembayaran = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    var data = await ApiService.getAllPesanan();
    setState(() {
      listPembayaran = data
          .where(
            (p) =>
                p.statusPesanan.toLowerCase() == 'proses' ||
                p.statusPesanan.toLowerCase() == 'selesai',
          )
          .toList();
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

              const Text(
                "Daftar Item Menu:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 8),

              ...items.map((item) {
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
                "TOTAL BAYAR: Rp ${formatRupiah(pesanan.totalHarga)}",
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

  // --- POP-UP EDIT STATUS ---
  void _showEditStatusDialog(PesananEntity pesanan) {
    List<String> statusOptions = ["Proses", "Selesai"];

    String selectedStatus = statusOptions.contains(pesanan.statusPesanan)
        ? pesanan.statusPesanan
        : statusOptions[0];

    List<dynamic> items = [];
    try {
      if (pesanan.detailPesanan.isNotEmpty && pesanan.detailPesanan != '[]') {
        items = jsonDecode(pesanan.detailPesanan);
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
                const Text(
                  "Daftar Item Menu:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
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
                const Divider(height: 30, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Status:", style: TextStyle(fontSize: 15)),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: statusOptions.contains(selectedStatus)
                            ? selectedStatus
                            : statusOptions[0],
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
                  "TOTAL BAYAR: Rp ${formatRupiah(pesanan.totalHarga)}",
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
                        PesananEntity pesananBaru = PesananEntity(
                          id: pesanan.id,
                          namaPelanggan: pesanan.namaPelanggan,
                          idProduk: pesanan.idProduk,
                          jumlah: pesanan.jumlah,
                          totalHarga: pesanan.totalHarga,
                          statusPesanan: selectedStatus,
                          tanggalPesanan: pesanan.tanggalPesanan,
                          detailPesanan: pesanan.detailPesanan,
                        );

                        await ApiService.updatePesanan(pesananBaru);
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
                    title: Text(
                      item.namaPelanggan,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Tagihan: Rp ${formatRupiah(item.totalHarga)}",
                        ),
                        const SizedBox(height: 4),
                        _buildStatusTag(item.statusPesanan),
                      ],
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

  void _showPaymentDetail(PesananEntity pesanan) {
    _showDetailOnlyDialog(pesanan);
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
