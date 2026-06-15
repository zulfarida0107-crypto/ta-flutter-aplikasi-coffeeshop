import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/desain_pesanan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cek sesi terakhir di SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  bool isInDesainPage = prefs.getBool('is_in_desain_page') ?? false;

  // Jalankan aplikasi dengan menentukan halaman awal
  runApp(
    MyApp(
      initialPage: isInDesainPage
          ? const DesainPesananPage()
          : const LoginPage(),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget initialPage;
  const MyApp({super.key, required this.initialPage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Coffee Shop Zulfa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: widget.initialPage,
    );
  }
}
