import 'package:edmanagement/screens/home.dart';
import 'package:edmanagement/screens/login_page.dart';
import 'package:edmanagement/screens/register_page.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marketplace UMKM',

      // Halaman pertama yang dibuka
      home: const LoginScreen(),
      

      // Daftar halaman yang bisa digunakan
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
