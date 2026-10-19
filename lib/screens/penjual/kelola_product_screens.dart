
import 'package:flutter/material.dart';

class KelolaProdukScreen extends StatefulWidget {
  const KelolaProdukScreen({super.key});

  @override
  State<KelolaProdukScreen> createState() => _KelolaProdukScreenState();
}

class _KelolaProdukScreenState extends State<KelolaProdukScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  final List<Map<String, dynamic>> produk = [];
  int _nextId = 1;

  String _formatHarga(dynamic harga) {
    final nilai = double.tryParse(harga.toString()) ?? 0;
    return 'Rp ${nilai.toStringAsFixed(0)}';
  }

  String _formatVarian(dynamic varian) {
    if (varian == null) return '';
    if (varian is List) {
      return varian.join(', ');
    }
    return varian.toString().trim();
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  // FORM TAMBAH DAN EDIT PRODUK TANPA DATABASE
  Future<void> _bukaForm({Map<String, dynamic>? item}) async {
    final namaController = TextEditingController(
      text: item?['nama_produk']?.toString() ?? '',
    );
    final kategoriController = TextEditingController(
      text: item?['kategori']?.toString() ?? '',
    );
    final hargaController = TextEditingController(
      text: item?['harga']?.toString() ?? '',
    );
    final stokController = TextEditingController(
      text: item?['stok']?.toString() ?? '',
    );
    final varianController = TextEditingController(
      text: _formatVarian(item?['varian']),
    );
    final fotoController = TextEditingController(
      text: item?['foto_url']?.toString() ?? '',
    );
    final deskripsiController = TextEditingController(
      text: item?['deskripsi']?.toString() ?? '',
    );

    final hasil = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            item == null ? 'Tambah Produk' : 'Edit Produk',
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(namaController, 'Nama Produk'),
                  _field(kategoriController, 'Kategori'),
                  _field(
                    hargaController,
                    'Harga',
                    keyboardType: TextInputType.number,
                  ),
                  _field(
                    stokController,
                    'Stok',
                    keyboardType: TextInputType.number,
                  ),
                  _field(
                    varianController,
                    'Varian (pisahkan dengan koma)',
                  ),
                  _field(fotoController, 'URL Foto Produk'),
                  _field(
                    deskripsiController,
                    'Deskripsi Produk',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hijau,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final nama = namaController.text.trim();
                final harga = double.tryParse(
                  hargaController.text.trim(),
                );
                final stok = int.tryParse(
                  stokController.text.trim(),
                );

                if (nama.isEmpty) {
                  _tampilkanPesan('Nama produk harus diisi.');
                  return;
                }

                if (harga == null || harga < 0) {
                  _tampilkanPesan('Masukkan harga yang valid.');
                  return;
                }

                if (stok == null || stok < 0) {
                  _tampilkanPesan('Masukkan stok yang valid.');
                  return;
                }

                final varian = varianController.text
                    .split(',')
                    .map((v) => v.trim())
                    .where((v) => v.isNotEmpty)
                    .toList();

                Navigator.pop(dialogContext, {
                  'nama_produk': nama,
                  'kategori': kategoriController.text.trim(),
                  'harga': harga,
                  'stok': stok,
                  'varian': varian,
                  'foto_url': fotoController.text.trim(),
                  'deskripsi': deskripsiController.text.trim(),
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    namaController.dispose();
    kategoriController.dispose();
    hargaController.dispose();
    stokController.dispose();
    varianController.dispose();
    fotoController.dispose();
    deskripsiController.dispose();

    if (!mounted || hasil == null) return;

    setState(() {
      if (item == null) {
        hasil['id'] = _nextId++;
        produk.insert(0, hasil);
      } else {
        final index = produk.indexWhere(
          (p) => p['id'] == item['id'],
        );
        if (index != -1) {
          hasil['id'] = item['id'];
          produk[index] = hasil;
        }
      }
    });

    _tampilkanPesan(
      item == null
          ? 'Produk berhasil ditambahkan.'
          : 'Produk berhasil diperbarui.',
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // HAPUS PRODUK DARI DATA LOKAL
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

    if (setuju != true || !mounted) return;

    setState(() {
      produk.removeWhere((p) => p['id'] == item['id']);
    });

    _tampilkanPesan('Produk berhasil dihapus.');
  }

  Widget _placeholderFoto() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _fotoProduk(String foto) {
    if (foto.isEmpty) return _placeholderFoto();

    return Image.network(
      foto,
      width: 82,
      height: 82,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _placeholderFoto();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Produk Saya',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
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

          if (produk.isEmpty)
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
                    'Tambahkan produk agar dapat '
                    'ditampilkan di katalog pembeli.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ...produk.map((item) {
              final foto = item['foto_url']?.toString() ?? '';
              final stok = item['stok'] ?? 0;
              final varian = _formatVarian(item['varian']);

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
                        child: _fotoProduk(foto),
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
                          const SizedBox(height: 4),
                          Text(
                            'Stok: $stok',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (varian.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Varian: $varian',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          if ((item['deskripsi']?.toString() ?? '')
                              .trim()
                              .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                item['deskripsi'].toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
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
    );
  }
}
