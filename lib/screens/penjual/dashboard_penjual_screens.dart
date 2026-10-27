import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  State<DashboardPenjualScreen> createState() =>
      _DashboardPenjualScreenState();
}

class _DashboardPenjualScreenState extends State<DashboardPenjualScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  late Future<Map<String, int>> _ringkasanFuture;

  @override
  void initState() {
    super.initState();
    _ringkasanFuture = _ambilRingkasanProduk();
  }

  // ==========================================
  // MENGAMBIL DATA PRODUK DARI SUPABASE
  // ==========================================
  Future<Map<String, int>> _ambilRingkasanProduk() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Sesi login tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await supabase
        .from('products')
        .select('id, stok')
        .eq('seller_id', user.id);

    final List<Map<String, dynamic>> produk =
        List<Map<String, dynamic>>.from(response);

    int totalStok = 0;

    for (final item in produk) {
      totalStok += (item['stok'] as num?)?.toInt() ?? 0;
    }

    return {
      'totalProduk': produk.length,
      'totalStok': totalStok,
    };
  }

  // ==========================================
  // MUAT ULANG DATA
  // ==========================================
  Future<void> _muatUlang() async {
    setState(() {
      _ringkasanFuture = _ambilRingkasanProduk();
    });

    try {
      await _ringkasanFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  // ==========================================
  // MEMBUKA LAPORAN PENJUALAN
  // ==========================================
  void _bukaLaporanPenjualan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LaporanPenjualanScreen(),
      ),
    );
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _judulBagian('Ringkasan Toko'),

            const SizedBox(height: 12),

            // ==========================================
            // RINGKASAN PRODUK DAN MENU YANG BISA DIKLIK
            // ==========================================
            FutureBuilder<Map<String, int>>(
              future: _ringkasanFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: hijau,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE7ECE8),
                      ),
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
                        const SizedBox(height: 6),
                        const Text(
                          'Periksa koneksi, sesi login, dan izin '
                          'akses tabel products di Supabase.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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

                final data = snapshot.data ??
                    {
                      'totalProduk': 0,
                      'totalStok': 0,
                    };

                return Column(
                  children: [
                    // BARIS PERTAMA
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

                    // BARIS KEDUA
                    Row(
                      children: [
                        // PESANAN BARU
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.shopping_bag_outlined,
                            judul: 'Pesanan Baru',
                            nilai: '5',
                            aksi: widget.onPesananMasuk,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // PENJUALAN
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.payments_outlined,
                            judul: 'Penjualan',
                            nilai: 'Rp150.000',
                            aksi: _bukaLaporanPenjualan,
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
              aksi: _bukaLaporanPenjualan,
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
                    content: Text(
                      'Pilih menu Toko Saya di navigasi bawah.',
                    ),
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
                    builder: (context) =>
                        const PengaturanAkunScreen(),
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
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ==========================================
  // KARTU RINGKASAN
  // BISA DIKLIK JIKA AKSI DIISI
  // ==========================================
  Widget _kartuRingkasan({
    required IconData ikon,
    required String judul,
    required String nilai,
    VoidCallback? aksi,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE7ECE8),
        ),
      ),
      child: InkWell(
        onTap: aksi,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    ikon,
                    color: hijau,
                    size: 26,
                  ),
                  const Spacer(),
                  if (aksi != null)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Mencegah teks nilai terlalu panjang
              // sehingga melampaui lebar kartu.
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nilai,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                judul,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // KARTU MENU PENGELOLAAN
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
        side: const BorderSide(
          color: Color(0xFFE7ECE8),
        ),
      ),
      child: ListTile(
        onTap: aksi,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F2E9),
          child: Icon(
            ikon,
            color: hijau,
          ),
        ),
        title: Text(
          judul,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
}