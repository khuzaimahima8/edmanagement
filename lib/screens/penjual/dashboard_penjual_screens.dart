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

class _DashboardPenjualScreenState
    extends State<DashboardPenjualScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  late Future<Map<String, int>> _ringkasanFuture;

  bool _tokoBuka = true;
  bool _sedangMenyimpanStatus = false;

  // ==========================================
  // MENGAMBIL STATUS TOKO
  // ==========================================
  Future<void> _ambilStatusToko() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final data = await supabase
          .from('seller_store_status')
          .select('is_open')
          .eq('seller_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _tokoBuka = data?['is_open'] as bool? ?? true;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil status toko: $e'),
        ),
      );
    }
  }

  // ==========================================
  // MENGUBAH STATUS TOKO
  // ==========================================
  Future<void> _ubahStatusToko(bool nilai) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login kembali.'),
        ),
      );
      return;
    }

    final statusSebelumnya = _tokoBuka;

    setState(() {
      _tokoBuka = nilai;
      _sedangMenyimpanStatus = true;
    });

    try {
      await Supabase.instance.client
          .from('seller_store_status')
          .upsert({
        'seller_id': user.id,
        'is_open': nilai,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'seller_id');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nilai
                ? 'Toko berhasil dibuka.'
                : 'Toko berhasil ditutup.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _tokoBuka = statusSebelumnya;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status toko gagal disimpan: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sedangMenyimpanStatus = false;
        });
      }
    }
  }

  // ==========================================
  // INIT STATE
  // ==========================================
  @override
  void initState() {
    super.initState();

    _ringkasanFuture = _ambilRingkasanProduk();

    _ambilStatusToko();
  }

  // ==========================================
  // MENGAMBIL DATA PRODUK DAN STOK
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
  // MEMUAT ULANG DATA DASHBOARD
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
        builder: (_) => const LaporanPenjualanScreen(),
      ),
    );
  }

  // ==========================================
  // TAMPILAN DASHBOARD
  // ==========================================
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

            // ==========================================
            // STATUS BUKA / TUTUP TOKO
            // ==========================================
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _tokoBuka
                      ? const Color(0xFFB7DEC9)
                      : const Color(0xFFF0C2C2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _tokoBuka
                          ? const Color(0xFFE0F2E9)
                          : const Color(0xFFFFE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _tokoBuka
                          ? Icons.storefront
                          : Icons.store_outlined,
                      color: _tokoBuka ? hijau : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Toko',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _tokoBuka
                              ? 'Toko sedang buka'
                              : 'Toko sedang tutup',
                          style: TextStyle(
                            fontSize: 12,
                            color: _tokoBuka ? hijau : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_sedangMenyimpanStatus)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: hijau,
                      ),
                    )
                  else
                    Switch(
                      value: _tokoBuka,
                      activeThumbColor: hijau,
                      onChanged: _ubahStatusToko,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _judulBagian('Ringkasan Toko'),

            const SizedBox(height: 12),

            // ==========================================
            // RINGKASAN PRODUK, STOK, PESANAN, PENJUALAN
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
                          'Periksa koneksi, sesi login, dan '
                          'izin akses tabel products di Supabase.',
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

                            // KLIK PRODUK -> HALAMAN KELOLA PRODUK
                            aksi: widget.onKelolaProduk,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.inventory_outlined,
                            judul: 'Total Stok',
                            nilai: '${data['totalStok']}',

                            // KLIK STOK -> HALAMAN KELOLA PRODUK
                            aksi: widget.onKelolaProduk,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // BARIS KEDUA
                    Row(
                      children: [
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.shopping_bag_outlined,
                            judul: 'Pesanan Baru',
                            nilai: '—',

                            // KLIK PESANAN -> HALAMAN PESANAN MASUK
                            aksi: widget.onPesananMasuk,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kartuRingkasan(
                            ikon: Icons.payments_outlined,
                            judul: 'Penjualan',
                            nilai: '—',

                            // KLIK PENJUALAN -> LAPORAN PENJUALAN
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
            // MENU KELOLA PRODUK
            // ==========================================
            _kartuMenu(
              ikon: Icons.add_box_outlined,
              judul: 'Kelola Produk',
              deskripsi: 'Tambah dan atur produk UMKM',
              aksi: widget.onKelolaProduk,
            ),

            // ==========================================
            // MENU PESANAN MASUK
            // ==========================================
            _kartuMenu(
              ikon: Icons.receipt_long_outlined,
              judul: 'Pesanan Masuk',
              deskripsi: 'Lihat pesanan dari pembeli',
              aksi: widget.onPesananMasuk,
            ),

            // ==========================================
            // MENU LAPORAN PENJUALAN
            // ==========================================
            _kartuMenu(
              ikon: Icons.bar_chart_outlined,
              judul: 'Laporan Penjualan',
              deskripsi: 'Lihat rekap transaksi dan produk terjual',
              aksi: _bukaLaporanPenjualan,
            ),

            
            // ==========================================
            // MENU PENGATURAN AKUN
            // ==========================================
            _kartuMenu(
              ikon: Icons.settings_outlined,
              judul: 'Pengaturan Akun',
              deskripsi: 'Kelola akun dan keamanan',
              aksi: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
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
  // KARTU RINGKASAN YANG BISA DIKLIK
  // ==========================================
  Widget _kartuRingkasan({
    required IconData ikon,
    required String judul,
    required String nilai,
    required VoidCallback aksi,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE7ECE8),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aksi,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                ikon,
                color: hijau,
                size: 26,
              ),
              const SizedBox(height: 12),
              Text(
                nilai,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
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
              const SizedBox(height: 2),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
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