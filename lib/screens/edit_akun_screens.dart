import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class EditAkunScreen extends StatefulWidget {
  const EditAkunScreen({super.key});

  @override
  State<EditAkunScreen> createState() => _EditAkunScreenState();
}

class _EditAkunScreenState extends State<EditAkunScreen> {
  late TextEditingController _namaController;
  late TextEditingController _teleponController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Mengambil nilai awal dari UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _namaController = TextEditingController(text: userProvider.nama);
    _teleponController = TextEditingController(text: userProvider.telepon);
    _emailController = TextEditingController(text: userProvider.email);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _simpanPerubahan() {
    // Memperbarui data di Provider secara global
    Provider.of<UserProvider>(context, listen: false).updateProfile(
      nama: _namaController.text,
      telepon: _teleponController.text,
      email: _emailController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!')),
    );

    Navigator.pop(context); // Kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Akun',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar Profil
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black12,
              child: Icon(Icons.person_outline, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text('Edit foto', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 24),

            // Form Input
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _buildTextField(_namaController),

                  const SizedBox(height: 16),
                  const Text('Nomor Telepon', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _buildTextField(_teleponController, keyboardType: TextInputType.phone),

                  const SizedBox(height: 16),
                  const Text('Alamat Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _buildTextField(_emailController, keyboardType: TextInputType.emailAddress),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }
}