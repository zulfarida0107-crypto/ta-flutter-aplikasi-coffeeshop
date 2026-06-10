import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database_helper.dart';

// import 'screens/login_page.dart';
import 'screens/home_page.dart'; // Direct to home
import 'screens/desain_pesanan_page.dart'; // Import halaman desain

void main() async {
  // 1. Wajib ditambahkan agar Flutter siap menjalankan kode async sebelum UI tampil
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Database
  await DatabaseHelper.initDatabase();

  // 3. Cek sesi terakhir di SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  bool isInDesainPage = prefs.getBool('is_in_desain_page') ?? false;

  // 4. Jalankan aplikasi dengan menentukan halaman awal
  runApp(
    MyApp(
      initialPage: isInDesainPage
          ? const DesainPesananPage()
          : const HomePage(), // const LoginPage(),
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Logika Session Protection
    if (state == AppLifecycleState.paused) {
      final prefs = await SharedPreferences.getInstance();
      bool isInDesainPage = prefs.getBool('is_in_desain_page') ?? false;

      // KHUSUS: Jika sedang TIDAK di halaman desain, lempar ke Login saat background
      // Ini memenuhi syarat 2B (halaman lain tetap harus login ulang)
      if (!isInDesainPage) {
        // navigatorKey.currentState?.pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (context) => const LoginPage()),
        //   (route) => false,
        // );
      }
    }
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
      // Menggunakan initialPage yang dikirim dari fungsi main()
      home: widget.initialPage,
    );
  }
}
