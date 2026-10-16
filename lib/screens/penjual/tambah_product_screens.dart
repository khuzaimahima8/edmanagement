import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class TambahProdukScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const TambahProdukScreen({super.key, this.product});

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _kategori;
  String? _fotoUrlLama;

  Uint8List? _fotoBytes;

  bool _menyimpan = false;

  final List<String> _kategoriList = [
    'Makanan',
    'Minuman',
    'Kerajinan',
    'Fashion',
    'Lainnya',
  ];

  bool get _modeEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    final item = widget.product;

    if (item != null) {
      _namaController.text = item['nama_produk']?.toString() ?? '';
      _hargaController.text = item['harga']?.toString() ?? '';
      _stokController.text = item['stok']?.toString() ?? '';
      _deskripsiController.text = item['deskripsi']?.toString() ?? '';
      _fotoUrlLama = item['foto_url']?.toString();

      final kategoriLama = item['kategori']?.toString();
      _kategori = _kategoriList.contains(kategoriLama)
          ? kategoriLama
          : 'Lainnya';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // ==========================================
  // MEMILIH FOTO DARI GALERI
  // ==========================================

  Future<void> _pilihFoto() async {
    try {
      final foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (foto == null) return;

      final bytes = await foto.readAsBytes();

      if (!mounted) return;

      setState(() {
        _fotoBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          duration: const Duration(seconds: 7),
        ),
      );
    }
  }

  // ==========================================
  // SIMPAN ATAU EDIT PRODUK (SIMULASI LOKAL)
  // ==========================================

  Future<void> _simpanProduk() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _menyimpan = true;
    });

    // Simulasi proses jaringan/penyimpanan lokal
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _menyimpan = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _modeEdit
              ? 'Simulasi: Produk berhasil diperbarui.'
              : 'Simulasi: Produk berhasil ditambahkan.',
        ),
      ),
    );

    // Kembali ke halaman sebelumnya dengan membawa status true
    Navigator.pop(context, true);
  }

  // ==========================================
  // VALIDASI FORM
  // ==========================================

  String? _validasiWajib(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  // ==========================================
  // TAMPILAN FORM TAMBAH PRODUK
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: hijau,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Informasi Produk',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),

              // FOTO PRODUK
              GestureDetector(
                onTap: _menyimpan ? null : _pilihFoto,
                child: Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _fotoBytes != null
                      ? Image.memory(_fotoBytes!, fit: BoxFit.contain)
                      : (_fotoUrlLama != null && _fotoUrlLama!.isNotEmpty)
                      ? Image.network(
                          _fotoUrlLama!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => _placeholderFoto(),
                        )
                      : _placeholderFoto(),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: _menyimpan ? null : _pilihFoto,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _fotoBytes != null || (_fotoUrlLama?.isNotEmpty ?? false)
                      ? 'Ganti Foto Produk'
                      : 'Pilih Foto dari Galeri',
                ),
              ),

              const SizedBox(height: 20),

              _label('Nama Produk'),

              TextFormField(
                controller: _namaController,
                textCapitalization: TextCapitalization.words,
                decoration: _dekorasi('Contoh: Keripik Pisang'),
                validator: (v) => _validasiWajib(v, 'Nama produk'),
              ),

              const SizedBox(height: 16),

              _label('Kategori'),

              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: _dekorasi('Pilih kategori'),
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: _menyimpan
                    ? null
                    : (value) {
                        setState(() {
                          _kategori = value;
                        });
                      },
                validator: (value) =>
                    value == null ? 'Kategori wajib dipilih' : null,
              ),

              const SizedBox(height: 16),

              _label('Harga (Rp)'),

              TextFormField(
                controller: _hargaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: _dekorasi('Contoh: 17000'),
                validator: (value) {
                  final error = _validasiWajib(value, 'Harga');
                  if (error != null) return error;

                  final harga = double.tryParse(value!.trim());
                  if (harga == null || harga <= 0) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Stok'),

              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _dekorasi('Contoh: 20'),
                validator: (value) {
                  final error = _validasiWajib(value, 'Stok');
                  if (error != null) return error;

                  final stok = int.tryParse(value!.trim());
                  if (stok == null || stok < 0) {
                    return 'Stok tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Deskripsi Produk'),

              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: _dekorasi('Tuliskan detail produk kamu'),
                validator: (v) => _validasiWajib(v, 'Deskripsi'),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _menyimpan ? null : _simpanProduk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hijau,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan Produk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PLACEHOLDER FOTO
  // ==========================================

  Widget _placeholderFoto() {
    return Container(
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
          const Text('Pilih foto produk'),
        ],
      ),
    );
  }

  // ==========================================
  // LABEL FORM
  // ==========================================

  Widget _label(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        teks,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ==========================================
  // DEKORASI INPUT
  // ==========================================

  InputDecoration _dekorasi(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: hijau, width: 1.5),
      ),
    );
  }
}