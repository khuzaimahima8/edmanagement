import 'package:flutter/material.dart';
import 'register_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password wajib diisi'),
        ),
      );
      return;
    }

    // Untuk sementara hanya menampilkan pesan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login berhasil'),
      ),
    );
void login() {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email dan password wajib diisi'),
      ),
    );
    return;
  }

  // Login berhasil → masuk ke halaman Home
  Navigator.pushReplacementNamed(context, '/home');
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =========================
              // TOMBOL BACK
              // =========================
              const SizedBox(height: 15),

              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 50),

              // =========================
              // LOGO
              // =========================
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 5),

              // =========================
              // SELAMAT DATANG
              // =========================
              const Center(
                child: Text(
                  'Selamat Datang !',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 3),

              const Center(
                child: Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 42),

              // =========================
              // EMAIL
              // =========================
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: Color(0xFF287A4B),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =========================
              // PASSWORD
              // =========================
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: Color(0xFF287A4B),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // =========================
              // LUPA PASSWORD
              // =========================
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Halaman lupa password
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Lupa password ?',
                    style: TextStyle(
                      color: Color(0xFF287A4B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 62),

              // =========================
              // BUTTON MASUK
              // =========================
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF287A4B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'MASUK',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

                           // =========================
              // DAFTAR
              // =========================
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Menggunakan named route yang sudah didaftarkan di main.dart
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: const Text(
                        'Daftar di sini',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF287548),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),


              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}