import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/pesanan_provider.dart';

class PesananMasukScreen extends StatelessWidget {
  const PesananMasukScreen({super.key});

  static const Color hijau = Color(0xFF006B42);

  String formatRupiah(int angka) {
    return 'Rp${angka.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PesananProvider>(
      builder: (context, provider, child) {
        final pesanan = provider.daftarPesanan;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Pesanan Pembeli',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kelola pesanan dan perbarui statusnya.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            if (pesanan.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Belum ada pesanan.'),
                ),
              ),

            ...pesanan.map((item) {
              final status = item.status;
              final sudahSampai =
                  status == StatusPesanan.sampai;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: hijau,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _badge(status),
                        ],
                      ),
                      const Divider(height: 24),

                      Text('Pembeli: ${item.namaPembeli}'),
                      const SizedBox(height: 8),
                      Text('Produk: ${item.namaProduk}'),
                      const SizedBox(height: 8),
                      Text('Jumlah: ${item.jumlah}'),
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${formatRupiah(item.total)}',
                        style: const TextStyle(
                          color: hijau,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (!sudahSampai)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final berikutnya =
                                  StatusPesanan.values[
                                status.index + 1
                              ];

                              _konfirmasiUbahStatus(
                                context,
                                provider,
                                item,
                                berikutnya,
                              );
                            },
                            icon: const Icon(
                              Icons.update,
                              color: Colors.white,
                            ),
                            label: Text(
                              _teksTombol(status),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hijau,
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Pesanan telah selesai.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: hijau,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _teksTombol(StatusPesanan status) {
    switch (status) {
      case StatusPesanan.baru:
        return 'Mulai Proses Pesanan';
      case StatusPesanan.diproses:
        return 'Tandai Sudah Dikirim';
      case StatusPesanan.dikirim:
        return 'Tandai Barang Sudah Sampai';
      case StatusPesanan.sampai:
        return 'Pesanan Selesai';
    }
  }

  Widget _badge(StatusPesanan status) {
    final Color warna;

    switch (status) {
      case StatusPesanan.baru:
        warna = Colors.orange;
        break;
      case StatusPesanan.diproses:
        warna = Colors.blue;
        break;
      case StatusPesanan.dikirim:
        warna = Colors.indigo;
        break;
      case StatusPesanan.sampai:
        warna = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        namaStatus(status),
        style: TextStyle(
          color: warna,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _konfirmasiUbahStatus(
    BuildContext context,
    PesananProvider provider,
    Pesanan pesanan,
    StatusPesanan statusBaru,
  ) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ubah Status Pesanan'),
          content: Text(
            'Ubah status pesanan ${pesanan.id} menjadi '
            '"${namaStatus(statusBaru)}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hijau,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Ubah'),
            ),
          ],
        );
      },
    );

    if (setuju == true) {
      provider.ubahStatus(pesanan.id, statusBaru);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status pesanan ${pesanan.id} diperbarui '
            'menjadi ${namaStatus(statusBaru)}.',
          ),
        ),
      );
    }
  }
}