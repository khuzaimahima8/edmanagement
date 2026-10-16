import 'package:flutter/material.dart';

import 'laporan_penjualan_screens.dart';
import 'pengaturan_akun_screens.dart';

class DashboardPenjualScreen extends StatefulWidget {
  final VoidCallback onKelolaProduk;
  final VoidCallback onPesananMasuk;

  const DashboardPenjualScreen({
    super.key,
    required this.onKelolaProduk,
    required this.onPesananMasuk,
  });

  @override
  State<DashboardPenjualScreen> createState() => _DashboardPenjualScreenState();
}

class _DashboardPenjualScreenState extends State<DashboardPenjualScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  // Simulasi data ringkasan toko untuk front-end
  late Future<Map<String, int>> _ringkasanFuture;

  @override
  void initState() {
    super.initState();
    _ringkasanFuture = _ambilRingkasanProdukMock();
  }

  // Simulasi pengambilan data (mock data) tanpa database
  Future<Map<String, int>> _ambilRingkasanProdukMock() async {
    // Simulasi delay jaringan (opsional, bisa dihapus jika ingin instan)
    await Future.delayed(const Duration(milliseconds: 500));

    // Kembalikan data dummy
    return {
      'totalProduk': 12,
      'totalStok': 158,
    };
  }

  // Memuat ulang data dashboard (versi mock)
  Future<void> _muatUlang() async {
    setState(() {
      _ringkasanFuture = _ambilRingkasanProdukMock();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: latar,
      child: RefreshIndicator(
        color: hijau,
        onRefresh: _muatUlang,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // ==========================================
            // SAMBUTAN PENJUAL
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: hijau,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Selamat Datang, Penjual!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kelola produk dan pesanan UMKM kamu '
                    'dalam satu tempat.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _judulBagian('Ringkasan Toko'),

            const SizedBox(height: 12),

            // ==========================================
            // RINGKASAN DATA UI
            // ==========================================
            FutureBuilder<Map<String, int>>(
              future: _ringkasanFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(color: hijau),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE7ECE8)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Data produk gagal dimuat.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _muatUlang,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final data =
                    snapshot.data ?? {'totalProduk': 0, 'totalStok': 0};

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.inventory_2_outlined,
                            judul: 'Total Produk',
                            nilai: '${data['totalProduk']}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.inventory_outlined,
                            judul: 'Total Stok',
                            nilai: '${data['totalStok']}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.shopping_bag_outlined,
                            judul: 'Pesanan Baru',
                            nilai: '3',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.payments_outlined,
                            judul: 'Penjualan',
                            nilai: 'Rp 450rb',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            _judulBagian('Menu Pengelolaan'),

            const SizedBox(height: 12),

            // ==========================================
            // KELOLA PRODUK
            // ==========================================
            _kartuMenu(
              ikon: Icons.add_box_outlined,
              judul: 'Kelola Produk',
              deskripsi: 'Tambah dan atur produk UMKM',
              aksi: widget.onKelolaProduk,
            ),

            // ==========================================
            // PESANAN MASUK
            // ==========================================
            _kartuMenu(
              ikon: Icons.receipt_long_outlined,
              judul: 'Pesanan Masuk',
              deskripsi: 'Lihat pesanan dari pembeli',
              aksi: widget.onPesananMasuk,
            ),

            // ==========================================
            // LAPORAN PENJUALAN
            // ==========================================
            _kartuMenu(
              ikon: Icons.bar_chart_outlined,
              judul: 'Laporan Penjualan',
              deskripsi: 'Lihat rekap transaksi dan produk terjual',
              aksi: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LaporanPenjualanScreen(),
                  ),
                );
              },
            ),

            // ==========================================
            // PROFIL TOKO
            // ==========================================
            _kartuMenu(
              ikon: Icons.store_outlined,
              judul: 'Profil Toko',
              deskripsi: 'Atur informasi usaha kamu',
              aksi: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih menu Toko Saya di navigasi bawah.'),
                  ),
                );
              },
            ),

            // ==========================================
            // PENGATURAN AKUN
            // ==========================================
            _kartuMenu(
              ikon: Icons.settings_outlined,
              judul: 'Pengaturan Akun',
              deskripsi: 'Kelola akun dan keamanan',
              aksi: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PengaturanAkunScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // JUDUL BAGIAN
  // ==========================================
  Widget _judulBagian(String judul) {
    return Text(
      judul,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
    );
  }

  // ==========================================
  // KARTU RINGKASAN
  // ==========================================
  Widget _kartuRingkasan({
    required IconData ikon,
    required String judul,
    required String nilai,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: hijau, size: 26),
          const SizedBox(height: 12),
          Text(
            nilai,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(judul, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==========================================
  // KARTU MENU
  // ==========================================
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
        side: const BorderSide(color: Color(0xFFE7ECE8)),
      ),
      child: ListTile(
        onTap: aksi,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F2E9),
          child: Icon(ikon, color: hijau),
        ),
        title: Text(
          judul,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(deskripsi, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}