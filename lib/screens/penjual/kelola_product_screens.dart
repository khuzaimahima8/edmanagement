import 'package:flutter/material.dart';

import 'tambah_product_screens.dart';

class KelolaProdukScreen extends StatefulWidget {
  const KelolaProdukScreen({super.key});

  @override
  State<KelolaProdukScreen> createState() => _KelolaProdukScreenState();
}

class _KelolaProdukScreenState extends State<KelolaProdukScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  // Daftar produk mock untuk tampilan front-end
  List<Map<String, dynamic>> produk = [
    {
      'id': '1',
      'nama_produk': 'Kripik Singkong Balado',
      'kategori': 'Makanan Ringan',
      'harga': 15000,
      'stok': 45,
      'foto_url': '',
    },
    {
      'id': '2',
      'nama_produk': 'Sambal Roa Khas Manado',
      'kategori': 'Kuliner / Lauk',
      'harga': 35000,
      'stok': 20,
      'foto_url': '',
    },
    {
      'id': '3',
      'nama_produk': 'Kopi Robusta Lokal 250g',
      'kategori': 'Minuman',
      'harga': 60000,
      'stok': 12,
      'foto_url': '',
    },
  ];

  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Tidak perlu memanggil database di initState, langsung pakai data mock
  }

  // Simulasi pengambilan produk (Mock)
  Future<void> _ambilProduk() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> _bukaForm({Map<String, dynamic>? item}) async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TambahProdukScreen(product: item)),
    );

    // Simulasi penambahan/edit produk secara lokal jika form mengembalikan true
    if (hasil == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulasi: Perubahan produk berhasil disimpan.')),
      );
      await _ambilProduk();
    }
  }

  Future<void> _hapusProduk(Map<String, dynamic> item) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
          'Apakah kamu yakin ingin menghapus '
          '"${item['nama_produk']}"?',
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

    if (setuju != true) return;

    setState(() {
      produk.removeWhere((element) => element['id'] == item['id']);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dihapus (lokal).')),
    );
  }

  String _formatHarga(dynamic harga) {
    final nilai = double.tryParse(harga.toString()) ?? 0;
    return 'Rp ${nilai.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      body: RefreshIndicator(
        onRefresh: _ambilProduk,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Produk Saya',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _bukaForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hijau,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Kelola produk yang ditampilkan kepada pembeli.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: hijau)),
              )
            else if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 44,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _ambilProduk,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            else if (produk.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Produk',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan produk UMKM agar dapat '
                      'ditampilkan di katalog pembeli.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ...produk.map((item) {
                final foto = item['foto_url']?.toString() ?? '';
                final stok = item['stok'] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 82,
                          height: 82,
                          child: foto.isNotEmpty
                              ? Image.network(
                                  foto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _placeholderFoto(),
                                )
                              : _placeholderFoto(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama_produk']?.toString() ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['kategori']?.toString() ?? '-',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatHarga(item['harga']),
                              style: const TextStyle(
                                color: hijau,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Stok: $stok',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (pilihan) {
                          if (pilihan == 'edit') {
                            _bukaForm(item: item);
                          } else if (pilihan == 'hapus') {
                            _hapusProduk(item);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Produk'),
                          ),
                          PopupMenuItem(
                            value: 'hapus',
                            child: Text('Hapus Produk'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _placeholderFoto() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 32, color: Colors.grey.shade400),
    );
  }
}