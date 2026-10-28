import 'package:flutter/material.dart';

import 'informasi_toko_screens.dart';
import 'laporan_penjualan_screens.dart';
import 'pengaturan_akun_screens.dart';

class TokoSayaScreen extends StatelessWidget {
  const TokoSayaScreen({super.key});

  static const Color hijau = Color(0xFF006B42);
  static const Color hijauMuda = Color(0xFFE0F2E9);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // =========================
        // HEADER TOKO
        // =========================
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7ECE8)),
          ),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: hijauMuda,
                child: Icon(
                  Icons.storefront,
                  size: 40,
                  color: hijau,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Toko UMKM Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: hijau,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Kelola informasi dan aktivitas tokomu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // =========================
        // JUDUL MENU
        // =========================
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Pengelolaan Toko',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // =========================
        // INFORMASI TOKO
        // =========================
        _kartuMenu(
          context: context,
          ikon: Icons.store_outlined,
          judul: 'Informasi Toko',
          deskripsi: 'Nama, deskripsi, kategori, dan alamat toko',
          aksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InformasiTokoScreen(),
              ),
            );
          },
        ),

        // =========================
        // NOMOR WHATSAPP
        // =========================
        _kartuMenu(
          context: context,
          ikon: Icons.chat_outlined,
          judul: 'Nomor WhatsApp',
          deskripsi: 'Atur kontak yang dapat dihubungi pembeli',
          aksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NomorWhatsAppScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // =========================
        // JUDUL MENU LAINNYA
        // =========================
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Aktivitas dan Pengaturan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // =========================
        // LAPORAN PENJUALAN
        // =========================
        _kartuMenu(
          context: context,
          ikon: Icons.bar_chart_outlined,
          judul: 'Laporan Penjualan',
          deskripsi: 'Lihat ringkasan hasil penjualan',
          aksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LaporanPenjualanScreen(),
              ),
            );
          },
        ),

        // =========================
        // PENGATURAN AKUN
        // =========================
        _kartuMenu(
          context: context,
          ikon: Icons.settings_outlined,
          judul: 'Pengaturan Akun',
          deskripsi: 'Atur informasi dan keamanan akun',
          aksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PengaturanAkunScreen(),
              ),
            );
          },
        ),

        // =========================
        // KELUAR
        // =========================
        _kartuMenu(
          context: context,
          ikon: Icons.logout,
          judul: 'Keluar',
          deskripsi: 'Keluar dari akun penjual',
          aksi: () {
            _konfirmasiKeluar(context);
          },
        ),

        const SizedBox(height: 12),

        const Center(
          child: Text(
            'ED Management',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // WIDGET KARTU MENU
  // =========================
  static Widget _kartuMenu({
    required BuildContext context,
    required IconData ikon,
    required String judul,
    required String deskripsi,
    required VoidCallback aksi,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE7ECE8),
        ),
      ),
      child: ListTile(
        onTap: aksi,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: CircleAvatar(
          backgroundColor: hijauMuda,
          child: Icon(
            ikon,
            color: hijau,
          ),
        ),
        title: Text(
          judul,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          deskripsi,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }

  // =========================
  // KONFIRMASI KELUAR
  // =========================
  static void _konfirmasiKeluar(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun penjual?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hijau,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logout belum dihubungkan ke autentikasi.',
                    ),
                  ),
                );
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

// ======================================================
// HALAMAN NOMOR WHATSAPP
// ======================================================

class NomorWhatsAppScreen extends StatefulWidget {
  const NomorWhatsAppScreen({super.key});

  @override
  State<NomorWhatsAppScreen> createState() =>
      _NomorWhatsAppScreenState();
}

class _NomorWhatsAppScreenState
    extends State<NomorWhatsAppScreen> {
  static const Color hijau = Color(0xFF006B42);

  final TextEditingController _nomorController =
      TextEditingController();

  @override
  void dispose() {
    _nomorController.dispose();
    super.dispose();
  }

  void _simpanNomor() {
    final nomor = _nomorController.text.trim();

    if (nomor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nomor WhatsApp.'),
        ),
      );
      return;
    }

    if (!RegExp(r'^[0-9+\-\s()]{8,20}$').hasMatch(nomor)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format nomor WhatsApp tidak valid.'),
        ),
      );
      return;
    }

    // Penyimpanan saat ini masih sementara.
    // Hubungkan ke penyimpanan lokal atau database jika diperlukan.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Nomor berhasil diperiksa. Penyimpanan permanen belum diaktifkan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text('Nomor WhatsApp'),
        backgroundColor: hijau,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFE0F2E9),
                    child: Icon(
                      Icons.chat,
                      size: 36,
                      color: hijau,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Kontak WhatsApp Toko',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Masukkan nomor WhatsApp agar pembeli '
                    'dapat mengetahui kontak tokomu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Nomor WhatsApp',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nomorController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Contoh: 081234567890',
                prefixIcon: const Icon(
                  Icons.phone_android,
                  color: hijau,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E5E1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: hijau,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _simpanNomor,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Nomor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hijau,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
