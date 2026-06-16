import 'package:flutter/material.dart';
import 'menu_produk_page.dart';
import 'manajemen_user_page.dart';
import 'daftar_pesanan_page.dart';
import 'desain_pesanan_page.dart';
import 'pesan_kontak_page.dart';
import 'pembayaran_pesanan_page.dart';
import 'login_page.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin Coffeeshop',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    "Konfirmasi Keluar Akun",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    "Apakah Anda Yakin ingin Keluar?",
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
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
                        Navigator.pop(context); // tutup dialog
                        ApiService.token = null; // hapus token
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('is_in_desain_page', false); // reset desain page flag
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false, // hapus semua stack
                        );
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
      body: GridView.count(
        padding: const EdgeInsets.all(18),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
        children: [
          _buildMenuCard(
            context,
            'Manajemen User',
            Icons.people,
            Colors.brown,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManajemenUserPage(),
              ),
            ),
          ),
          _buildMenuCard(
            context,
            'Daftar Menu Produk',
            Icons.coffee,
            Colors.brown,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuProdukPage()),
            ),
          ),
          _buildMenuCard(
            context,
            'Daftar Pesanan',
            Icons.shopping_cart,
            Colors.brown,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DaftarPesananPage(),
              ),
            ),
          ),
          _buildMenuCard(
            context,
            'Daftar Desain Pesanan (Kue Custom)',
            Icons.cake,
            Colors.brown,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DesainPesananPage(),
              ),
            ),
          ),
          _buildMenuCard(
            context,
            'Daftar Pesan Masuk',
            Icons.mail,
            Colors.brown,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PesanKontakPage()),
            ),
          ),
          _buildMenuCard(
            context,
            'Pembayaran Pesanan',
            Icons.payment,
            Colors.brown,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PembayaranPesananPage(),
              ),
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTapAction,
  ) {
    return Card(
      elevation: 4,
      color: const Color(0xFFFFF3F0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTapAction,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
