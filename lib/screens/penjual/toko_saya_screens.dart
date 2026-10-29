import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'informasi_toko_screens.dart';
import 'laporan_penjualan_screens.dart';
import 'pengaturan_akun_screens.dart';

const Color warnaHijauToko = Color(0xFF006B42);
const Color warnaHijauMudaToko = Color(0xFFE0F2E9);
const Color warnaLatarToko = Color(0xFFF5F7F6);

// ======================================================
// HALAMAN TOKO SAYA
// ======================================================

class TokoSayaScreen extends StatefulWidget {
  const TokoSayaScreen({super.key});

  @override
  State<TokoSayaScreen> createState() => _TokoSayaScreenState();
}

class _TokoSayaScreenState extends State<TokoSayaScreen> {
  Uint8List? fotoToko;
    final ImagePicker _imagePicker = ImagePicker();
  String namaToko = 'Toko UMKM Saya';
  String deskripsiToko = 'Kelola informasi dan aktivitas tokomu.';

  Future<void> _pilihFotoToko() async {
    try {
      final XFile? gambar = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (gambar == null) return;

      final Uint8List bytes = await gambar.readAsBytes();

      if (!mounted) return;

      setState(() {
        fotoToko = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
        ),
      );
    }
  }

  Future<void> _bukaEditProfil() async {
    final hasil = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilTokoScreen(
          namaAwal: namaToko,
          deskripsiAwal: deskripsiToko,
        ),
      ),
    );

    if (!mounted || hasil == null) return;

    setState(() {
      namaToko = hasil['nama'] ?? namaToko;
      deskripsiToko = hasil['deskripsi'] ?? deskripsiToko;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ==================================================
        // HEADER TOKO
        // ==================================================

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE7ECE8),
            ),
          ),
          child: Column(
            children: [
              // LOGO TOKO DENGAN IKON EDIT
              GestureDetector(
                onTap: _pilihFotoToko,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: warnaHijauMudaToko,
                    backgroundImage: fotoToko != null
                        ? MemoryImage(fotoToko!)
                        : null,
                    child: fotoToko == null
                        ? const Icon(
                            Icons.storefront,
                            size: 42,
                            color: warnaHijauToko,
                          )
                        : null,
                  ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          color: warnaHijauToko,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Text(
                namaToko,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: warnaHijauToko,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                deskripsiToko,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _bukaEditProfil,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profil Toko'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: warnaHijauToko,
                  side: const BorderSide(
                    color: warnaHijauToko,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ==================================================
        // PENGELOLAAN TOKO
        // ==================================================

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

        _kartuMenu(
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

        _kartuMenu(
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

        // ==================================================
        // AKTIVITAS DAN PENGATURAN
        // ==================================================

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

        _kartuMenu(
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

        _kartuMenu(
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

        _kartuMenu(
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

  // ======================================================
  // WIDGET KARTU MENU
  // ======================================================

  Widget _kartuMenu({
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
          backgroundColor: warnaHijauMudaToko,
          child: Icon(
            ikon,
            color: warnaHijauToko,
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

  // ======================================================
  // KONFIRMASI KELUAR
  // ======================================================

  void _konfirmasiKeluar(BuildContext context) {
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
                backgroundColor: warnaHijauToko,
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
// HALAMAN EDIT PROFIL TOKO
// ======================================================

class EditProfilTokoScreen extends StatefulWidget {
  final String namaAwal;
  final String deskripsiAwal;

  const EditProfilTokoScreen({
    super.key,
    required this.namaAwal,
    required this.deskripsiAwal,
  });

  @override
  State<EditProfilTokoScreen> createState() =>
      _EditProfilTokoScreenState();
}

class _EditProfilTokoScreenState extends State<EditProfilTokoScreen> {
  late final TextEditingController _namaController;
  late final TextEditingController _deskripsiController;

  @override
  void initState() {
    super.initState();

    _namaController = TextEditingController(
      text: widget.namaAwal,
    );

    _deskripsiController = TextEditingController(
      text: widget.deskripsiAwal,
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _simpanProfil() {
    final nama = _namaController.text.trim();
    final deskripsi = _deskripsiController.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama toko tidak boleh kosong.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      <String, String>{
        'nama': nama,
        'deskripsi': deskripsi,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaLatarToko,
      appBar: AppBar(
        title: const Text('Edit Profil Toko'),
        backgroundColor: warnaHijauToko,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // LOGO TOKO
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: warnaHijauMudaToko,
                  child: Icon(
                    Icons.storefront,
                    size: 50,
                    color: warnaHijauToko,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: warnaHijauToko,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Profil Toko',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Nama Toko',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _namaController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Masukkan nama toko',
              prefixIcon: const Icon(
                Icons.store_outlined,
                color: warnaHijauToko,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: warnaHijauToko,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Deskripsi Toko',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _deskripsiController,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Ceritakan tentang tokomu',
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: warnaHijauToko,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _simpanProfil,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan Perubahan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: warnaHijauToko,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
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
        backgroundColor: warnaHijauToko,
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
                    backgroundColor: warnaHijauMudaToko,
                    child: Icon(
                      Icons.chat,
                      size: 36,
                      color: warnaHijauToko,
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
                  color: warnaHijauToko,
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
                    color: warnaHijauToko,
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
                  backgroundColor: warnaHijauToko,
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
