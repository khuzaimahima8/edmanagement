import 'package:flutter/material.dart';
import 'screens/login_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        primaryColor: const Color(0xFF006B42),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}