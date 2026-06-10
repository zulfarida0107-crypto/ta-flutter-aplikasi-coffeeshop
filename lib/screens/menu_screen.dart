import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _menuList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Menarik data dari API saat halaman pertama kali dibuka
  Future<void> _fetchData() async {
    final data = await ApiService.getMenuProduk();
    setState(() {
      _menuList = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Katalog Produk")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _menuList.length,
              itemBuilder: (context, index) {
                final menu = _menuList[index];
                return ListTile(
                  title: Text(menu['namaProduk']), // Sesuai field JSON API
                  subtitle: Text("Rp. ${menu['harga']}"),
                  trailing: Text(menu['kategori']),
                );
              },
            ),
    );
  }
}
