import 'package:flutter/material.dart';

import 'edit_akun_screens.dart';
import 'pesanan_saya_screens.dart';
import 'alamat_saya_screens.dart';

class AkunScreen extends StatelessWidget {
  final String nama;
  final String email;
  final bool showScaffold;
  final VoidCallback? onProfileUpdated;
  final ValueChanged<int>? onNavigateTab;

  const AkunScreen({
    super.key,
    this.nama = 'khuzai',
    this.email = 'khuzaimahimae8@gmail.com',
    this.showScaffold = true,
    this.onProfileUpdated,
    this.onNavigateTab,
  });

  static const Color warnaUtama = Color(0xFF008F68);

  // ==========================================
  // NAVIGASI
  // ==========================================

  void _bukaEditProfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAkunScreen(),
      ),
    ).then((_) {
      onProfileUpdated?.call();
    });
  }

  void _bukaPesanan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PesananSayaScreen(),
      ),
    );
  }

  void _bukaAlamat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlamatSayaScreen(),
      ),
    );
  }

  void _bukaKeranjang(BuildContext context) {
    if (onNavigateTab != null) {
      onNavigateTab!(2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Keranjang belum terhubung ke navigasi utama.',
          ),
        ),
      );
    }
  }

  // ==========================================
  // KONFIRMASI KELUAR
  // ==========================================

  void _konfirmasiKeluar(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari aplikasi?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: warnaUtama,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logout belum dihubungkan dengan sistem login.',
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

  // ==========================================
  // TAMPILAN AKUN
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final isi = Container(
      color: const Color(0xFFF7F7F7),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFIL PENGGUNA
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _bukaEditProfil(context),
                    borderRadius: BorderRadius.circular(40),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFE5E5E5),
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _bukaEditProfil(context),
                          child: Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _bukaEditProfil(context),
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            _bukaEditProfil(context);
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 15,
                          ),
                          label: const Text('Edit Profil'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: warnaUtama,
                            side: const BorderSide(
                              color: warnaUtama,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================
            // PESANAN, KERANJANG, ALAMAT
            // BAGIAN INI HANYA DITULIS SEKALI
            // ==================================

            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _itemAktivitas(
                      icon: Icons.shopping_bag_outlined,
                      jumlah: '4',
                      judul: 'Pesanan',
                      onTap: () {
                        _bukaPesanan(context);
                      },
                    ),
                  ),
                  _pembatas(),
                  Expanded(
                    child: _itemAktivitas(
                      icon: Icons.favorite_border,
                      jumlah: '2',
                      judul: 'Keranjang',
                      onTap: () {
                        _bukaKeranjang(context);
                      },
                    ),
                  ),
                  _pembatas(),
                  Expanded(
                    child: _itemAktivitas(
                      icon: Icons.location_on_outlined,
                      jumlah: '',
                      judul: 'Alamat',
                      onTap: () {
                        _bukaAlamat(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // MENU PENGATURAN
            _judulBagian('Pengaturan'),

            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _menuItem(
                    icon: Icons.person_outline,
                    judul: 'Edit Profil',
                    deskripsi: 'Ubah nama, email, dan foto profil',
                    onTap: () {
                      _bukaEditProfil(context);
                    },
                  ),
                  _garis(),
                  _menuItem(
                    icon: Icons.settings_outlined,
                    judul: 'Pengaturan Akun',
                    deskripsi: 'Atur preferensi akun',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PengaturanAkunScreen(),
                        ),
                      );
                    },
                  ),
                  _garis(),
                  _menuItem(
                    icon: Icons.info_outline,
                    judul: 'Tentang Aplikasi',
                    deskripsi: 'Informasi aplikasi ED Management',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TentangAplikasiScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TOMBOL KELUAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _konfirmasiKeluar(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'ED Management',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (!showScaffold) {
      return isi;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Akun Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: isi,
    );
  }

  // ==========================================
  // WIDGET PESANAN, KERANJANG, ALAMAT
  // ==========================================

  Widget _itemAktivitas({
    required IconData icon,
    required String jumlah,
    required String judul,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: warnaUtama,
                      size: 22,
                    ),
                    if (jumlah.isNotEmpty) ...[
                      const SizedBox(width: 7),
                      Text(
                        jumlah,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PEMBATAS ANTARIKON
  Widget _pembatas() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.grey.shade300,
    );
  }

  // JUDUL BAGIAN
  Widget _judulBagian(String judul) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        10,
      ),
      child: Text(
        judul,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // WIDGET MENU YANG BISA DIKLIK
  Widget _menuItem({
    required IconData icon,
    required String judul,
    required String deskripsi,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: warnaUtama.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: warnaUtama,
          size: 23,
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
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 15,
        color: Colors.grey,
      ),
    );
  }

  // GARIS PEMISAH MENU
  Widget _garis() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.shade300,
      indent: 70,
    );
  }
}

// ==========================================
// HALAMAN PENGATURAN AKUN
// ==========================================

class PengaturanAkunScreen extends StatelessWidget {
  const PengaturanAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: AkunScreen.warnaUtama,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Informasi Profil'),
            subtitle: const Text('Ubah informasi pribadi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAkunScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Alamat Pengiriman'),
            subtitle: const Text('Kelola alamat pengiriman'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlamatSayaScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifikasi'),
            subtitle: const Text('Pengaturan notifikasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Pengaturan notifikasi belum tersedia.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HALAMAN TENTANG APLIKASI
// ==========================================

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: AkunScreen.warnaUtama,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront,
                size: 80,
                color: AkunScreen.warnaUtama,
              ),
              const SizedBox(height: 16),
              const Text(
                'ED Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplikasi untuk melihat produk, mengelola '
                'keranjang, alamat, dan pesanan.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Versi 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
