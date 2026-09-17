import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/home_page.dart';
import 'views/category_page.dart';
import 'views/detail_page.dart';

/// [Modul 01 - Struktur Aplikasi Flutter]: Entry point program Flutter
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Mengatur status bar transparan untuk tampilan immersive (Modul 08 & 10)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const LokaNusantaraApp());
}

/// [Modul 01 & 07 - MaterialApp & Named Routes Configuration]:
/// Root widget yang mengatur konfigurasi tema global dan peta routing aplikasi.
class LokaNusantaraApp extends StatelessWidget {
  const LokaNusantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisata & Kuliner Lokal',
      debugShowCheckedModeBanner: false,

      // [Stitch Design System Tokens]
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0D9488), // Emerald Teal
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFFF59E0B), // Warm Amber
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),

      // [Modul 07 & 08 - Sistem Named Routes]:
      // initialRoute menentukan rute awal yang dibuka (HomePage)
      initialRoute: HomePage.routeName,

      // routes mendefinisikan kamus navigasi antar halaman
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        CategoryPage.routeName: (context) => const CategoryPage(),
        DetailPage.routeName: (context) => const DetailPage(),
      },
    );
  }
}
