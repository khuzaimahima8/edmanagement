import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screens.dart';
import 'providers/user_provider.dart';
import 'providers/pesanan_provider.dart';

Future<void> main() async {
  // Memastikan Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://cqzzrxeukcxkstdxfeiy.supabase.co',
    publishableKey: 'sb_publishable_forJiulthVcRmNGHfQUO1g_1DkiL3pq',
  );

  // Jalankan aplikasi dengan beberapa provider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PesananProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ED Management',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'sans-serif',
        primaryColor: const Color(0xFF006B42),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B42),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
