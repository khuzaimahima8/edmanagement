import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EditAkunScreen extends StatefulWidget {
  const EditAkunScreen({super.key});

  @override
  State<EditAkunScreen> createState() => _EditAkunScreenState();
}

class _EditAkunScreenState extends State<EditAkunScreen> {
  static const Color primaryColor = Color(0xFF006B42);
  static const Color backgroundColor = Color(0xFFF7F0ED);

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Pengguna belum login.');
      }

      final data = await supabase
          .from('profiles')
          .select('id, nama, no_handphone, email, alamat')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        _namaController.text = (data['nama'] ?? '').toString();
        _emailController.text = (data['email'] ?? user.email ?? '').toString();
        _phoneController.text = (data['no_handphone'] ?? '').toString();
        _alamatController.text = (data['alamat'] ?? '').toString();
      } else {
        _emailController.text = user.email ?? '';
      }
    } catch (e) {
      debugPrint('ERROR LOAD PROFILE: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data akun: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Membuka pencarian alamat di Google Maps.
  Future<void> _bukaGoogleMaps() async {
    final alamat = _alamatController.text.trim();

    if (alamat.isEmpty) {
      _showMessage('Masukkan alamat terlebih dahulu.');
      return;
    }

    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': alamat,
    });

    try {
      final berhasil = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!berhasil && mounted) {
        _showMessage('Google Maps tidak dapat dibuka.');
      }
    } catch (e) {
      debugPrint('Gagal membuka Google Maps: $e');

      if (mounted) {
        _showMessage('Gagal membuka Google Maps.');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_namaController.text.trim().isEmpty) {
      _showMessage('Nama tidak boleh kosong.');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showMessage('Nomor HP tidak boleh kosong.');
      return;
    }

    if (_alamatController.text.trim().isEmpty) {
      _showMessage('Alamat tidak boleh kosong.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Pengguna belum login.');
      }

      // Perbarui data milik pengguna yang sedang login.
      final result = await supabase
          .from('profiles')
          .update({
            'nama': _namaController.text.trim(),
            'no_handphone': _phoneController.text.trim(),
            'alamat': _alamatController.text.trim(),
          })
          .eq('id', user.id)
          .select('id')
          .maybeSingle();

      if (result == null) {
        throw Exception(
          'Profil tidak ditemukan atau tidak dapat diperbarui. '
          'Periksa data profiles dan kebijakan RLS.',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data akun berhasil diperbarui.'),
          backgroundColor: primaryColor,
        ),
      );

      // Mengirim hasil agar halaman sebelumnya dapat memuat ulang data.
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('UPDATE PROFILE GAGAL: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Akun',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.person, size: 52, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildLabel('Nama'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _namaController,
                    hintText: 'Masukkan nama sesuai registrasi',
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 20),
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: _inputDecoration(
                      hintText: 'Email akun',
                      icon: Icons.email_outlined,
                    ).copyWith(filled: true, fillColor: Colors.grey.shade200),
                  ),

                  const SizedBox(height: 20),
                  _buildLabel('Nomor HP'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Masukkan nomor HP',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),
                  _buildLabel('Alamat'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _alamatController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      hintText: 'Masukkan alamat lengkap',
                      icon: Icons.location_on_outlined,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _bukaGoogleMaps,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Lihat Alamat di Google Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hintText: hintText, icon: icon),
    );
  }
}