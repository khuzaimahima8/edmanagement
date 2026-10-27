
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/pesanan_provider.dart';

class PesananSayaScreen extends StatefulWidget {
  const PesananSayaScreen({super.key});

  @override
  State<PesananSayaScreen> createState() => _PesananSayaScreenState();
}

class _PesananSayaScreenState extends State<PesananSayaScreen> {
  final Color warnaUtama = const Color(0xFF006B42);

  String filterAktif = 'Semua';

  final List<String> daftarFilter = [
    'Semua',
    'Baru',
    'Diproses',
    'Dikirim',
    'Selesai',
  ];

  bool cocokFilter(Pesanan pesanan) {
    switch (filterAktif) {
      case 'Baru':
        return pesanan.status == StatusPesanan.baru;
      case 'Diproses':
        return pesanan.status == StatusPesanan.diproses;
      case 'Dikirim':
        return pesanan.status == StatusPesanan.dikirim;
      case 'Selesai':
        return pesanan.status == StatusPesanan.sampai;
      default:
        return true;
    }
  }

  String teksStatus(StatusPesanan status) {
    switch (status) {
      case StatusPesanan.baru:
        return 'Pesanan Baru';
      case StatusPesanan.diproses:
        return 'Sedang Diproses';
      case StatusPesanan.dikirim:
        return 'Sudah Dikirim';
      case StatusPesanan.sampai:
        return 'Pesanan Selesai';
    }
  }

  IconData ikonProduk(String namaProduk) {
    final nama = namaProduk.toLowerCase();

    if (nama.contains('tas') || nama.contains('kerajinan')) {
      return Icons.shopping_bag_outlined;
    } else if (nama.contains('kopi') ||
        nama.contains('minuman')) {
      return Icons.local_cafe_outlined;
    } else if (nama.contains('keripik') ||
        nama.contains('makanan') ||
        nama.contains('stik')) {
      return Icons.fastfood_outlined;
    } else if (nama.contains('baju') ||
        nama.contains('fashion')) {
      return Icons.checkroom_outlined;
    }

    return Icons.inventory_2_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<PesananProvider>(
        builder: (context, provider, child) {
          final semuaPesanan = provider.daftarPesanan;
          final pesananTampil =
              semuaPesanan.where(cocokFilter).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Pantau pesanan kamu di sini',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),

              // TAB FILTER STATUS
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: daftarFilter.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = daftarFilter[index];
                    final aktif = filterAktif == filter;

                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          filterAktif = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: aktif
                              ? warnaUtama
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: aktif
                                ? warnaUtama
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: aktif
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: aktif
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              Divider(color: Colors.grey.shade200, height: 1),

              // DAFTAR PESANAN
              Expanded(
                child: pesananTampil.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
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
                                'Belum Ada Pesanan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pesanan dengan status "$filterAktif" '
                                'akan muncul di sini.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: pesananTampil.length,
                        separatorBuilder: (_, __) =>
                            Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                            ),
                        itemBuilder: (context, index) {
                          final pesanan = pesananTampil[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // IKON PRODUK
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: warnaUtama.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    ikonProduk(pesanan.namaProduk),
                                    color: warnaUtama,
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // INFORMASI PRODUK
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pesanan.namaProduk,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Jumlah: ${pesanan.jumlah}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        teksStatus(pesanan.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: warnaUtama,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // HARGA DAN ID PESANAN
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rp${pesanan.total}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      pesanan.id,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: warnaUtama.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        'Detail',
                                        style: TextStyle(
                                          color: warnaUtama,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
