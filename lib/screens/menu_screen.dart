import 'package:flutter/material.dart';
import '../models/menu_produk_entity.dart';
import '../services/api_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuProdukEntity> _menuList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiService.getAllMenuProduk();
    setState(() {
      _menuList = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Katalog Produk"),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : _menuList.isEmpty
              ? const Center(child: Text("Belum ada produk tersedia."))
              : ListView.builder(
                  itemCount: _menuList.length,
                  itemBuilder: (context, index) {
                    final menu = _menuList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown[100],
                        child: const Icon(Icons.coffee, color: Colors.brown),
                      ),
                      title: Text(menu.namaProduk),
                      subtitle: Text("Rp. ${menu.harga.toInt()} • ${menu.kategori}"),
                    );
                  },
                ),
    );
  }
}
