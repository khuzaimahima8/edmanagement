import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlamatSayaScreen extends StatefulWidget {
  const AlamatSayaScreen({super.key});

  @override
  State<AlamatSayaScreen> createState() => _AlamatSayaScreenState();
}

class _AlamatSayaScreenState extends State<AlamatSayaScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Color primaryColor = const Color(0xFF006B42);

  List<Map<String, dynamic>> _addresses = [];
  String _namaUser = 'Pengguna';
  String _noHandphoneUser = '-';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ambilDataAlamat();
  }

  // =====================================================
  // AMBIL DATA PROFIL DAN DAFTAR ALAMAT
  // =====================================================

  Future<void> _ambilDataAlamat() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select('nama, no_handphone')
          .eq('id', user.id)
          .maybeSingle();

      final dataAlamat = await supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_primary', ascending: false)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _namaUser = profile?['nama']?.toString() ?? 'Pengguna';
        _noHandphoneUser = profile?['no_handphone']?.toString() ?? '-';

        _addresses = List<Map<String, dynamic>>.from(dataAlamat);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data alamat: $e')),
      );
    }
  }

  // =====================================================
  // TAMBAH ALAMAT BARU
  // =====================================================

  Future<void> _tambahAlamat() async {
    await _tampilkanFormAlamat();
  }

  // =====================================================
  // UBAH ALAMAT
  // =====================================================

  Future<void> _ubahAlamat(Map<String, dynamic> alamat) async {
    await _tampilkanFormAlamat(alamat: alamat);
  }

  // =====================================================
  // FORM TAMBAH / UBAH ALAMAT
  // =====================================================

  Future<void> _tampilkanFormAlamat({Map<String, dynamic>? alamat}) async {
    final bool isEdit = alamat != null;

    final namaController = TextEditingController(
      text: alamat?['nama_penerima']?.toString() ?? _namaUser,
    );

    final teleponController = TextEditingController(
      text:
          alamat?['no_handphone']?.toString() ??
          (_noHandphoneUser == '-' ? '' : _noHandphoneUser),
    );

    final alamatController = TextEditingController(
      text: alamat?['alamat']?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    final bool? simpan = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEdit ? 'Ubah Alamat' : 'Tambah Alamat Baru',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Penerima',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama penerima wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: teleponController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Handphone',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor handphone wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: alamatController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lengkap',
                      hintText: 'Masukkan alamat lengkap',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alamat wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
            ),
          ],
        );
      },
    );

    if (simpan == true) {
      await _simpanAlamat(
        nama: namaController.text.trim(),
        telepon: teleponController.text.trim(),
        alamatTeks: alamatController.text.trim(),
        alamatLama: alamat,
      );
    }

    namaController.dispose();
    teleponController.dispose();
    alamatController.dispose();
  }

  // =====================================================
  // SIMPAN ALAMAT KE SUPABASE
  // =====================================================

  Future<void> _simpanAlamat({
    required String nama,
    required String telepon,
    required String alamatTeks,
    Map<String, dynamic>? alamatLama,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _pesan('Silakan login terlebih dahulu');
      return;
    }

    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final bool isEdit = alamatLama != null;

      if (isEdit) {
        // Mengubah alamat yang dipilih saja.
        await supabase
            .from('addresses')
            .update({
              'nama_penerima': nama,
              'no_handphone': telepon,
              'alamat': alamatTeks,
            })
            .eq('id', alamatLama['id'])
            .eq('user_id', user.id);
      } else {
        // Alamat pertama otomatis menjadi alamat utama.
        final bool jadikanUtama = _addresses.isEmpty;

        await supabase.from('addresses').insert({
          'user_id': user.id,
          'nama_penerima': nama,
          'no_handphone': telepon,
          'alamat': alamatTeks,
          'is_primary': jadikanUtama,
        });
      }

      await _ambilDataAlamat();

      _pesan(
        isEdit ? 'Alamat berhasil diubah' : 'Alamat baru berhasil ditambahkan',
      );
    } catch (e) {
      _pesan('Gagal menyimpan alamat: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // =====================================================
  // PILIH ALAMAT UTAMA
  // =====================================================

  Future<void> _jadikanAlamatUtama(Map<String, dynamic> alamat) async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      // Nonaktifkan status utama pada semua alamat milik pengguna.
      await supabase
          .from('addresses')
          .update({'is_primary': false})
          .eq('user_id', user.id);

      // Jadikan alamat yang dipilih sebagai alamat utama.
      await supabase
          .from('addresses')
          .update({'is_primary': true})
          .eq('id', alamat['id'])
          .eq('user_id', user.id);

      await _ambilDataAlamat();

      _pesan('Alamat utama berhasil diubah');
    } catch (e) {
      _pesan('Gagal mengubah alamat utama: $e');
    }
  }

  // =====================================================
  // HAPUS ALAMAT
  // =====================================================

  Future<void> _hapusAlamat(Map<String, dynamic> alamat) async {
    final bool? yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Alamat'),
          content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
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
        );
      },
    );

    if (yakin != true) return;

    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      await supabase
          .from('addresses')
          .delete()
          .eq('id', alamat['id'])
          .eq('user_id', user.id);

      await _ambilDataAlamat();

      _pesan('Alamat berhasil dihapus');
    } catch (e) {
      _pesan('Gagal menghapus alamat: $e');
    }
  }

  void _pesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // =====================================================
  // TAMPILAN KARTU ALAMAT
  // =====================================================

  Widget _kartuAlamat(Map<String, dynamic> alamat) {
    final bool isPrimary = alamat['is_primary'] == true;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? primaryColor : Colors.grey.shade300,
          width: isPrimary ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Alamat Utama',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _jadikanAlamatUtama(alamat),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Jadikan Alamat Utama'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(
                  text: '${alamat['nama_penerima']} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '| ${alamat['no_handphone']}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            alamat['alamat']?.toString() ?? '-',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _isSaving ? null : () => _ubahAlamat(alamat),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Ubah'),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
              TextButton.icon(
                onPressed: () => _hapusAlamat(alamat),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
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
          'Alamat Saya',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _tambahAlamat,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Tambah Alamat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada alamat tersimpan',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tekan Tambah Alamat untuk memulai.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _ambilDataAlamat,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) {
                          return _kartuAlamat(_addresses[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}