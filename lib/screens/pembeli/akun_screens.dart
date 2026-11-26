import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_akun_screens.dart';
import 'pesanan_saya_screens.dart';
import 'alamat_saya_screens.dart';
import 'cart_screens.dart';

class AkunScreen extends StatefulWidget {
  final String? nama;
  final String? email;
  final bool showScaffold;
  final VoidCallback? onProfileUpdated;

  // Callback navigasi dari HomeScreen
  final ValueChanged<int>? onBottomNavTap;

  const AkunScreen({
    super.key,
    this.nama,
    this.email,
    this.showScaffold = true,
    this.onProfileUpdated,
    this.onBottomNavTap,
  });

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  static const Color primaryColor = Color(0xFF006B42);
  static const Color backgroundColor = Color(0xFFF5F7F6);

  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  String _nama = 'Pengguna';
  String _email = '';
  String _alamat = '';
  String? _fotoProfil;

  int _jumlahPesanan = 0;
  int _jumlahKeranjang = 0;

  bool _isLoading = true;
  bool _isUploadingFoto = false;

  @override
  void initState() {
    super.initState();

    _nama = widget.nama ?? 'Pengguna';
    _email = widget.email ?? '';

    _loadDataAkun();
  }

  // =========================================================
  // MEMUAT DATA AKUN
  // =========================================================
  Future<void> _loadDataAkun() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // MEMUAT PROFIL
    try {
      final profile = await _supabase
          .from('profiles')
          .select('nama, email, alamat, foto_profil')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && mounted) {
        setState(() {
          _nama = (profile['nama'] ?? widget.nama ?? 'Pengguna').toString();

          _email = (profile['email'] ?? user.email ?? '').toString();

          _alamat = (profile['alamat'] ?? '').toString();

          _fotoProfil = profile['foto_profil']?.toString();
        });
      } else if (mounted) {
        setState(() {
          _email = user.email ?? widget.email ?? '';
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat profil: $e');
    }

    // MEMUAT JUMLAH PESANAN
    try {
      final pesanan = await _supabase
          .from('orders')
          .select('id')
          .eq('buyer_id', user.id);

      if (mounted) {
        setState(() {
          _jumlahPesanan = (pesanan as List).length;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat jumlah pesanan: $e');
    }

    // MEMUAT JUMLAH PRODUK DALAM KERANJANG
    try {
      final keranjang = await _supabase
          .from('cart_items')
          .select('quantity')
          .eq('buyer_id', user.id);

      int total = 0;

      for (final item in keranjang as List) {
        final quantity = item['quantity'];

        if (quantity is num) {
          total += quantity.toInt();
        }
      }

      if (mounted) {
        setState(() {
          _jumlahKeranjang = total;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat jumlah keranjang: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // =========================================================
  // MEMILIH DAN MENGUNGGAH FOTO PROFIL
  // =========================================================
  Future<void> _ubahFotoProfil() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _tampilkanPesan('Silakan login terlebih dahulu.');
      return;
    }

    if (_isUploadingFoto) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 800,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _isUploadingFoto = true;
      });

      final Uint8List fotoBytes = await image.readAsBytes();

      final filePath =
          '${user.id}/foto_profil_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('foto-profil')
          .uploadBinary(
            filePath,
            fotoBytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final fotoUrl = _supabase.storage
          .from('foto-profil')
          .getPublicUrl(filePath);

      await _supabase
          .from('profiles')
          .update({'foto_profil': fotoUrl})
          .eq('id', user.id);

      if (!mounted) return;

      setState(() {
        _fotoProfil = fotoUrl;
      });

      widget.onProfileUpdated?.call();

      _tampilkanPesan('Foto profil berhasil diperbarui.');
    } catch (e, stackTrace) {
      debugPrint('GAGAL UPLOAD FOTO PROFIL: $e');
      debugPrint('DETAIL ERROR: $stackTrace');

      if (!mounted) return;

      _tampilkanPesan('Gagal mengunggah foto profil: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingFoto = false;
        });
      }
    }
  }

  // =========================================================
  // MENAMPILKAN PESAN
  // =========================================================
  void _tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // =========================================================
  // FOTO PROFIL
  // =========================================================
  Widget _buildFotoProfil() {
    return InkWell(
      onTap: _isUploadingFoto ? null : _ubahFotoProfil,
      borderRadius: BorderRadius.circular(50),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            backgroundImage: _fotoProfil != null && _fotoProfil!.isNotEmpty
                ? NetworkImage(_fotoProfil!)
                : null,
            child: _fotoProfil == null || _fotoProfil!.isEmpty
                ? const Icon(
                    Icons.person_outline,
                    color: primaryColor,
                    size: 36,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: _isUploadingFoto
                  ? const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt, size: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EDIT AKUN
  // =========================================================
  Future<void> _editAkun() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAkunScreen()),
    );

    if (!mounted) return;

    await _loadDataAkun();
    widget.onProfileUpdated?.call();
  }

  // =========================================================
  // PESANAN SAYA
  // =========================================================
  Future<void> _bukaPesanan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PesananSayaScreen()),
    );

    if (!mounted) return;

    await _loadDataAkun();
  }

  // =========================================================
  // KERANJANG
  // =========================================================
  Future<void> _bukaKeranjang() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartScreen()),
    );

    if (!mounted) return;

    await _loadDataAkun();
  }

  // =========================================================
  // ALAMAT SAYA
  // =========================================================
  Future<void> _bukaAlamatSaya() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlamatSayaScreen()),
    );

    if (!mounted) return;

    await _loadDataAkun();
  }

  // =========================================================
  // LOGOUT
  // =========================================================
  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) return;

    try {
      await _supabase.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      debugPrint('Gagal logout: $e');

      if (!mounted) return;

      _tampilkanPesan('Gagal keluar dari akun.');
    }
  }

  // =========================================================
  // TENTANG APLIKASI
  // =========================================================
  void _tentangAplikasi() {
    showAboutDialog(
      context: context,
      applicationName: 'ED Management',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.shopping_bag_outlined,
        color: primaryColor,
        size: 40,
      ),
      applicationLegalese: 'Marketplace Produk UMKM',
      children: const [
        SizedBox(height: 12),
        Text(
          'ED Management merupakan aplikasi katalog dan '
          'pemesanan produk UMKM.',
        ),
      ],
    );
  }

  // =========================================================
  // NAVIGASI BOTTOM NAVIGATION
  // =========================================================
  void _onBottomNavigationTap(int index) {
    if (index == 3) return;

    // Navigasi dikelola oleh HomeScreen.
    if (widget.onBottomNavTap != null) {
      widget.onBottomNavTap!(index);
      return;
    }

    // Jika AkunScreen berdiri sendiri.
    if (index == 0 || index == 1) {
      Navigator.pop(context, index);
    } else if (index == 2) {
      _bukaKeranjang();
    }
  }

  // =========================================================
  // BOTTOM NAVIGATION BAR
  // =========================================================
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      onTap: _onBottomNavigationTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Kategori',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Keranjang',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Akun',
        ),
      ],
    );
  }

  // =========================================================
  // WIDGET STATISTIK
  // =========================================================
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: primaryColor, size: 27),
              const SizedBox(height: 7),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // WIDGET MENU
  // =========================================================
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color iconColor = primaryColor,
    Color titleColor = Colors.black87,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DIVIDER MENU
  // =========================================================
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 68,
      endIndent: 12,
      color: Color(0xFFECEFED),
    );
  }

  // =========================================================
  // TAMPILAN UTAMA AKUN
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final content = Container(
      color: backgroundColor,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadDataAkun,
              color: primaryColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // HEADER
                  const Text(
                    'Akun Saya',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PROFIL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildFotoProfil(),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _editAkun,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 15,
                                      color: primaryColor,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Edit Profil',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // STATISTIK
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'Pesanan',
                          value: '$_jumlahPesanan',
                          onTap: _bukaPesanan,
                        ),
                        _buildStatItem(
                          icon: Icons.shopping_cart_outlined,
                          title: 'Keranjang',
                          value: '$_jumlahKeranjang',
                          onTap: _bukaKeranjang,
                        ),
                        _buildStatItem(
                          icon: Icons.location_on_outlined,
                          title: 'Alamat',
                          value: 'Atur',
                          onTap: _bukaAlamatSaya,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // MENU SAYA
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Menu Saya',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'Pesanan Saya',
                          subtitle: 'Lihat status dan riwayat pesanan',
                          onTap: _bukaPesanan,
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.shopping_cart_outlined,
                          title: 'Keranjang',
                          subtitle: 'Lihat produk yang akan dipesan',
                          onTap: _bukaKeranjang,
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Alamat Saya',
                          subtitle: _alamat.isNotEmpty
                              ? _alamat
                              : 'Kelola alamat Anda',
                          onTap: _bukaAlamatSaya,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // PENGATURAN
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.manage_accounts_outlined,
                          title: 'Pengaturan Akun',
                          subtitle: 'Ubah informasi profil Anda',
                          onTap: _editAkun,
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Informasi ED Management',
                          onTap: _tentangAplikasi,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // KELUAR
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Keluar',
                      subtitle: 'Keluar dari akun Anda',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: _logout,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );

    // JIKA DIPANGGIL DARI HOMESCREEN
    if (!widget.showScaffold) {
      return content;
    }

    // JIKA DIBUKA SECARA MANDIRI
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: content),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}