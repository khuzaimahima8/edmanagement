
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesananSayaScreen extends StatefulWidget {
  const PesananSayaScreen({super.key});

  @override
  State<PesananSayaScreen> createState() => _PesananSayaScreenState();
}

class _PesananSayaScreenState extends State<PesananSayaScreen> {
  static const Color hijau = Color(0xFF006B42);

  static const String _storageKey = 'ed_management_pesanan_saya_v1';

  List<Map<String, dynamic>> pesanan = [];
  String tabAktif = 'Semua';
  bool loading = true;


  @override
  void initState() {
    super.initState();
    _muatPesanan();
  }

  // =========================
  // MEMUAT PESANAN
  // =========================
  Future<void> _muatPesanan() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    List<Map<String, dynamic>> hasil = [];

    if (data != null) {
      try {
        final decoded = jsonDecode(data) as List;
        hasil = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (e) {
        debugPrint('Gagal membaca pesanan: $e');
      }
    }

    // Data contoh hanya dibuat jika belum ada riwayat.
    if (hasil.isEmpty && data == null) {
      final sekarang = DateTime.now();

      hasil = [
        {
          'id': 'ORD-${sekarang.millisecondsSinceEpoch}',
          'nama': 'Tas Rajut',
          'harga': 17000,
          'jumlah': 1,
          'varian': 'Hitam',
          'gambar': 'assets/tas rajut.jpeg',
          'status': 'Diproses',
          'dibuat': sekarang.subtract(
            const Duration(seconds: 10),
          ).millisecondsSinceEpoch,
        },
        {
          'id': 'ORD-${sekarang.millisecondsSinceEpoch + 1}',
          'nama': 'Keripik Pisang',
          'harga': 10000,
          'jumlah': 2,
          'varian': '250gr',
          'gambar': 'assets/rojomolo.jpeg',
          'status': 'Diproses',
          'dibuat': sekarang.subtract(
            const Duration(seconds: 5),
          ).millisecondsSinceEpoch,
        },
      ];

      await prefs.setString(_storageKey, jsonEncode(hasil));
    }

    if (!mounted) return;

    setState(() {
      pesanan = hasil;
      loading = false;
    });
  }

  Future<void> _simpanPesanan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(pesanan));
  }


  // =========================
  // HAPUS PESANAN
  // =========================
  Future<void> _hapusPesanan(Map<String, dynamic> item) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: Text(
          'Hapus pesanan ${item['nama']} dari riwayat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju != true || !mounted) return;

    setState(() {
      pesanan.removeWhere((p) => p['id'] == item['id']);
    });

    await _simpanPesanan();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan dihapus dari riwayat.')),
    );
  }

  // =========================
  // PESAN LAGI
  // =========================
  Future<void> _pesanLagi(Map<String, dynamic> item) async {
    final sekarang = DateTime.now();

    final pesananBaru = <String, dynamic>{
      'id': 'ORD-${sekarang.microsecondsSinceEpoch}',
      'nama': item['nama'],
      'harga': item['harga'],
      'jumlah': item['jumlah'],
      'varian': item['varian'] ?? '',
      'gambar': item['gambar'] ?? '',
      'status': 'Diproses',
      'dibuat': sekarang.millisecondsSinceEpoch,
    };

    setState(() {
      pesanan.insert(0, pesananBaru);
      tabAktif = 'Semua';
    });

    await _simpanPesanan();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item['nama']} berhasil dipesan ulang (simulasi).',
        ),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  // =========================
  // STATUS DAN WARNA
  // =========================
  Color _warnaStatus(String status) {
    switch (status) {
      case 'Diproses':
        return Colors.orange;
      case 'Dikirim':
        return Colors.blue;
      case 'Selesai':
        return hijau;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get pesananTerfilter {
    if (tabAktif == 'Semua') return pesanan;

    return pesanan
        .where((p) => p['status'] == tabAktif)
        .toList();
  }

  String _formatTanggal(int timestamp) {
    final t = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final tanggal = t.day.toString().padLeft(2, '0');
    final bulan = t.month.toString().padLeft(2, '0');

    return '$tanggal/$bulan/${t.year} '
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  String _rupiah(dynamic nilai) {
    final angka = (nilai as num?)?.toInt() ?? 0;
    final teks = angka.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < teks.length; i++) {
      buffer.write(teks[i]);

      final sisa = teks.length - i - 1;
      if (sisa > 0 && sisa % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'Rp$buffer';
  }

  // =========================
  // DETAIL PESANAN
  // =========================
  void _lihatDetail(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? 'Diproses';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Detail Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No. Pesanan: ${item['id']}'),
            const SizedBox(height: 8),
            Text('Produk: ${item['nama']}'),
            Text('Varian: ${item['varian'] ?? '-'}'),
            Text('Jumlah: ${item['jumlah']}'),
            Text(
              'Total: ${_rupiah(
                (item['harga'] as num) * (item['jumlah'] as num),
              )}',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Status: '),
                Text(
                  status,
                  style: TextStyle(
                    color: _warnaStatus(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Status pengiriman pada halaman ini '
              'masih menggunakan simulasi.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // =========================
  // KARTU PESANAN
  // =========================
  Widget _kartuPesanan(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? 'Diproses';
    final jumlah = (item['jumlah'] as num?)?.toInt() ?? 1;
    final harga = (item['harga'] as num?)?.toInt() ?? 0;
    final total = harga * jumlah;
    final gambar = item['gambar']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'No. Pesanan: ${item['id']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _warnaStatus(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _warnaStatus(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatTanggal(item['dibuat'] as int? ?? 0),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: gambar.isNotEmpty
                    ? Image.asset(
                        gambar,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _gambarKosong(),
                      )
                    : _gambarKosong(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama']?.toString() ?? 'Produk',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['varian'] ?? '-'} · ${jumlah}x',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _rupiah(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _rupiah(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Pilihan pesanan',
                onSelected: (pilihan) {
                  if (pilihan == 'detail') {
                    _lihatDetail(item);
                  } else if (pilihan == 'hapus') {
                    _hapusPesanan(item);
                  } else if (pilihan == 'ulang') {
                    _pesanLagi(item);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Text('Lihat Detail'),
                  ),
                  const PopupMenuItem(
                    value: 'ulang',
                    child: Text('Pesan Lagi'),
                  ),
                  const PopupMenuItem(
                    value: 'hapus',
                    child: Text('Hapus dari Riwayat'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gambarKosong() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }

  // =========================
  // TAMPILAN
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: ['Semua', 'Diproses', 'Dikirim', 'Selesai']
                        .map((tab) {
                      final aktif = tabAktif == tab;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tab),
                          selected: aktif,
                          selectedColor: hijau,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: aktif ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setState(() {
                              tabAktif = tab;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: pesananTerfilter.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada pesanan di kategori ini.',
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    tabAktif = 'Semua';
                                  });
                                },
                                child: const Text('Lihat Semua Pesanan'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: pesananTerfilter.length,
                          itemBuilder: (context, index) {
                            return _kartuPesanan(pesananTerfilter[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
