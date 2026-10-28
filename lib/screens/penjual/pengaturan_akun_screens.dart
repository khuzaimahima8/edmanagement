import 'package:flutter/material.dart';

const Color warnaUtama = Color(0xFF006B42);
const Color warnaLatar = Color(0xFFF5F7F6);

class PengaturanAkunScreen extends StatelessWidget {
  const PengaturanAkunScreen({super.key});

  // Membuka halaman yang dipilih
  void _bukaHalaman(BuildContext context, Widget halaman) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => halaman,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: warnaUtama,
            ),
            title: const Text('Data Diri'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _bukaHalaman(context, const DataDiriScreen());
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(
              Icons.lock_outline,
              color: warnaUtama,
            ),
            title: const Text('Keamanan Akun'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _bukaHalaman(context, const KeamananAkunScreen());
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(
              Icons.notifications_outlined,
              color: warnaUtama,
            ),
            title: const Text('Notifikasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _bukaHalaman(context, const NotifikasiScreen());
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// =====================================================
// HALAMAN DATA DIRI
// =====================================================

class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  final TextEditingController _namaController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _teleponController =
      TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  void _simpanData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Data berhasil disimpan sementara.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: AppBar(
        title: const Text('Data Diri'),
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFDCEFE5),
              child: Icon(
                Icons.person,
                size: 50,
                color: warnaUtama,
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buatInput(
            label: 'Nama Lengkap',
            controller: _namaController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          _buatInput(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          _buatInput(
            label: 'Nomor Telepon',
            controller: _teleponController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _simpanData,
              style: ElevatedButton.styleFrom(
                backgroundColor: warnaUtama,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan Perubahan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buatInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: warnaUtama),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// =====================================================
// HALAMAN KEAMANAN AKUN
// =====================================================

class KeamananAkunScreen extends StatefulWidget {
  const KeamananAkunScreen({super.key});

  @override
  State<KeamananAkunScreen> createState() =>
      _KeamananAkunScreenState();
}

class _KeamananAkunScreenState
    extends State<KeamananAkunScreen> {
  final TextEditingController _passwordLamaController =
      TextEditingController();

  final TextEditingController _passwordBaruController =
      TextEditingController();

  final TextEditingController _konfirmasiController =
      TextEditingController();

  bool _sembunyikanLama = true;
  bool _sembunyikanBaru = true;
  bool _sembunyikanKonfirmasi = true;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _ubahPassword() {
    if (_passwordLamaController.text.isEmpty ||
        _passwordBaruController.text.isEmpty ||
        _konfirmasiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom wajib diisi.'),
        ),
      );
      return;
    }

    if (_passwordBaruController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kata sandi baru minimal 8 karakter.',
          ),
        ),
      );
      return;
    }

    if (_passwordBaruController.text !=
        _konfirmasiController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Konfirmasi kata sandi tidak cocok.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tampilan berhasil diuji. Perubahan kata sandi '
          'belum diterapkan ke akun.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: AppBar(
        title: const Text('Keamanan Akun'),
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 70,
            color: warnaUtama,
          ),
          const SizedBox(height: 12),
          const Text(
            'Ubah Kata Sandi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buatPassword(
            label: 'Kata Sandi Lama',
            controller: _passwordLamaController,
            tersembunyi: _sembunyikanLama,
            onToggle: () {
              setState(() {
                _sembunyikanLama = !_sembunyikanLama;
              });
            },
          ),
          const SizedBox(height: 16),

          _buatPassword(
            label: 'Kata Sandi Baru',
            controller: _passwordBaruController,
            tersembunyi: _sembunyikanBaru,
            onToggle: () {
              setState(() {
                _sembunyikanBaru = !_sembunyikanBaru;
              });
            },
          ),
          const SizedBox(height: 16),

          _buatPassword(
            label: 'Konfirmasi Kata Sandi Baru',
            controller: _konfirmasiController,
            tersembunyi: _sembunyikanKonfirmasi,
            onToggle: () {
              setState(() {
                _sembunyikanKonfirmasi =
                    !_sembunyikanKonfirmasi;
              });
            },
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _ubahPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: warnaUtama,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ubah Kata Sandi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buatPassword({
    required String label,
    required TextEditingController controller,
    required bool tersembunyi,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: tersembunyi,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: warnaUtama,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            tersembunyi
                ? Icons.visibility_off
                : Icons.visibility,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// =====================================================
// HALAMAN NOTIFIKASI
// =====================================================

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() =>
      _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _notifikasiPesanan = true;
  bool _notifikasiPromosi = true;
  bool _notifikasiAkun = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Pengaturan Notifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SwitchListTile(
            secondary: const Icon(
              Icons.shopping_bag_outlined,
              color: warnaUtama,
            ),
            title: const Text('Notifikasi Pesanan'),
            subtitle: const Text(
              'Informasi perkembangan pesanan.',
            ),
            value: _notifikasiPesanan,
            activeThumbColor: warnaUtama,
            onChanged: (value) {
              setState(() {
                _notifikasiPesanan = value;
              });
            },
          ),
          const Divider(height: 1),

          SwitchListTile(
            secondary: const Icon(
              Icons.local_offer_outlined,
              color: warnaUtama,
            ),
            title: const Text('Promosi'),
            subtitle: const Text(
              'Informasi diskon dan penawaran.',
            ),
            value: _notifikasiPromosi,
            activeThumbColor: warnaUtama,
            onChanged: (value) {
              setState(() {
                _notifikasiPromosi = value;
              });
            },
          ),
          const Divider(height: 1),

          SwitchListTile(
            secondary: const Icon(
              Icons.person_outline,
              color: warnaUtama,
            ),
            title: const Text('Informasi Akun'),
            subtitle: const Text(
              'Informasi penting terkait akun.',
            ),
            value: _notifikasiAkun,
            activeThumbColor: warnaUtama,
            onChanged: (value) {
              setState(() {
                _notifikasiAkun = value;
              });
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
