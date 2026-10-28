import 'package:edmanagement/providers/informasi_toko_provider.dart';
import 'package:flutter/material.dart';

class InformasiTokoScreen extends StatefulWidget {
  const InformasiTokoScreen({super.key});

  @override
  State<InformasiTokoScreen> createState() =>
      _InformasiTokoScreenState();
}

class _InformasiTokoScreenState
    extends State<InformasiTokoScreen> {
  static const Color primaryColor = Color(0xFF006B42);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaTokoController =
      TextEditingController(text: 'Toko UMKM Saya');

  final TextEditingController _deskripsiController =
      TextEditingController();

  final TextEditingController _kategoriController =
      TextEditingController();

  final TextEditingController _alamatController =
      TextEditingController();

  final TextEditingController _teleponController =
      TextEditingController();
  final InformasiTokoService _tokoService = InformasiTokoService();

  bool _sedangDisimpan = false;

  @override
  void dispose() {
    _namaTokoController.dispose();
    _deskripsiController.dispose();
    _kategoriController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

Future<void> _simpanInformasiToko() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _sedangDisimpan = true;
  });

  try {
    await _tokoService.simpanInformasiToko(
      namaToko: _namaTokoController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      kategori: _kategoriController.text.trim(),
      alamat: _alamatController.text.trim(),
      nomorTelepon: _teleponController.text.trim(),
      nomorWhatsApp: _teleponController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informasi toko berhasil disimpan.'),
        backgroundColor: primaryColor,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menyimpan informasi toko: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _sedangDisimpan = false;
      });
    }
  }
}

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
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
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            prefixIcon: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Informasi Toko',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER TOKO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDF4EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: primaryColor,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Profil Toko',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Lengkapi informasi agar pembeli '
                      'mengenal tokomu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Informasi Dasar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              // NAMA TOKO
              _buildTextField(
                label: 'Nama Toko',
                hint: 'Masukkan nama toko',
                controller: _namaTokoController,
                icon: Icons.store_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama toko wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // DESKRIPSI TOKO
              _buildTextField(
                label: 'Deskripsi Toko',
                hint: 'Ceritakan produk yang dijual',
                controller: _deskripsiController,
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi toko wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // KATEGORI
              _buildTextField(
                label: 'Kategori Toko',
                hint: 'Contoh: Makanan, Fashion, Kerajinan',
                controller: _kategoriController,
                icon: Icons.category_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kategori toko wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Kontak dan Alamat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              // ALAMAT TOKO
              _buildTextField(
                label: 'Alamat Toko',
                hint: 'Masukkan alamat lengkap toko',
                controller: _alamatController,
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat toko wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // NOMOR TELEPON
              _buildTextField(
                label: 'Nomor Telepon',
                hint: 'Contoh: 081234567890',
                controller: _teleponController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor telepon wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _sedangDisimpan
                      ? null
                      : _simpanInformasiToko,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        primaryColor.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _sedangDisimpan
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Informasi Toko',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}