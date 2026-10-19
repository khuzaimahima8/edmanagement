
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TambahProdukScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const TambahProdukScreen({
    super.key,
    this.product,
  });

  @override
  State<TambahProdukScreen> createState() =>
      _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _namaController =
      TextEditingController();
  final TextEditingController _hargaController =
      TextEditingController();
  final TextEditingController _stokController =
      TextEditingController();
  final TextEditingController _deskripsiController =
      TextEditingController();
  final TextEditingController _varianController =
      TextEditingController();

  final List<String> _kategoriList = [
    'Makanan',
    'Minuman',
    'Kerajinan',
    'Fashion',
    'Lainnya',
  ];

  String? _kategori;
  Uint8List? _fotoBytes;
  String? _fotoLama;
  bool _loading = false;

  bool get _modeEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    if (p != null) {
      _namaController.text =
          p['nama_produk']?.toString() ?? '';

      _hargaController.text =
          p['harga']?.toString() ?? '';

      _stokController.text =
          p['stok']?.toString() ?? '';

      _deskripsiController.text =
          p['deskripsi']?.toString() ?? '';

      final kategoriLama = p['kategori']?.toString();

      if (_kategoriList.contains(kategoriLama)) {
        _kategori = kategoriLama;
      }

      _fotoLama = p['foto_url']?.toString();

      // Mendukung foto lokal dari data produk sebelumnya.
      final fotoLokal = p['foto_bytes'];
      if (fotoLokal is Uint8List) {
        _fotoBytes = fotoLokal;
      }

      final dataVarian = p['varian'];

      if (dataVarian is List) {
        _varianController.text =
            dataVarian.map((v) => v.toString()).join(', ');
      } else if (dataVarian is String) {
        _varianController.text = dataVarian;
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    _varianController.dispose();
    super.dispose();
  }

  void _pesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(pesan)),
      );
  }

  // PILIH FOTO DARI GALERI TANPA UPLOAD KE SERVER
  Future<void> _pilihFoto() async {
    try {
      final hasil = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (hasil == null) return;

      final bytes = await hasil.readAsBytes();

      if (!mounted) return;

      setState(() {
        _fotoBytes = bytes;
        _fotoLama = null;
      });
    } catch (e) {
      _pesan('Gagal memilih foto: $e');
    }
  }

  // FORMAT VARIAN PRODUK
  List<String> _ambilVarian() {
    return _varianController.text
        .split(',')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
  }

  // SIMPAN KE DATA LOKAL MELALUI HALAMAN SEBELUMNYA
  Future<void> _simpanProduk() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_kategori == null) {
      _pesan('Silakan pilih kategori produk.');
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      final harga = double.parse(
        _hargaController.text.trim().replaceAll(',', '.'),
      );

      final stok = int.parse(
        _stokController.text.trim(),
      );

      final Map<String, dynamic> data = {
        'nama_produk': _namaController.text.trim(),
        'kategori': _kategori,
        'harga': harga,
        'stok': stok,
        'deskripsi': _deskripsiController.text.trim(),
        'varian': _ambilVarian(),
        'foto_url': _fotoBytes == null ? _fotoLama : '',
        'foto_bytes': _fotoBytes,
      };

      if (_modeEdit) {
        data['id'] = widget.product!['id'];
      }

      if (!mounted) return;

      // Mengirim data ke halaman sebelumnya.
      // Tidak ada database atau upload server.
      Navigator.pop(context, data);
    } catch (e) {
      _pesan('Gagal memproses data produk: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: hijau),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderFoto() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan foto produk',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _tampilanFoto() {
    if (_fotoBytes != null) {
      return Image.memory(
        _fotoBytes!,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    if (_fotoLama != null && _fotoLama!.isNotEmpty) {
      return Image.network(
        _fotoLama!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderFoto();
        },
      );
    }

    return _placeholderFoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        title: Text(
          _modeEdit ? 'Edit Produk' : 'Tambah Produk',
        ),
        backgroundColor: hijau,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Foto Produk',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: _loading ? null : _pilihFoto,
              child: Container(
                height: 190,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: _tampilanFoto(),
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _loading ? null : _pilihFoto,
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
              ),
              label: const Text('Pilih Foto dari Galeri'),
              style: OutlinedButton.styleFrom(
                foregroundColor: hijau,
                padding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 22),

            _field(
              label: 'Nama Produk',
              controller: _namaController,
              hint: 'Contoh: Keripik Pisang',
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nama produk wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            const Text(
              'Kategori',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: InputDecoration(
                hintText: 'Pilih kategori produk',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() {
                        _kategori = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return 'Pilih kategori produk';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _field(
              label: 'Harga (Rp)',
              controller: _hargaController,
              hint: 'Contoh: 17000',
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final harga = double.tryParse(
                  (v ?? '').trim().replaceAll(',', '.'),
                );

                if (harga == null || harga <= 0) {
                  return 'Masukkan harga yang valid';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            _field(
              label: 'Stok Produk',
              controller: _stokController,
              hint: 'Contoh: 50',
              keyboardType: TextInputType.number,
              validator: (v) {
                final stok = int.tryParse((v ?? '').trim());

                if (stok == null || stok < 0) {
                  return 'Stok harus 0 atau lebih';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            _field(
              label: 'Varian Produk (Opsional)',
              controller: _varianController,
              hint: 'Contoh: 250 gram, 500 gram, 1 kg',
              maxLines: 2,
            ),

            const SizedBox(height: 6),

            const Text(
              'Pisahkan setiap varian dengan tanda koma.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            _field(
              label: 'Deskripsi Produk',
              controller: _deskripsiController,
              hint: 'Jelaskan detail produk...',
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Deskripsi produk wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _simpanProduk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hijau,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _modeEdit
                            ? 'Simpan Perubahan'
                            : 'Simpan Produk',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
