import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_product_screens.dart';
import 'cart_screens.dart';
import 'akun_screens.dart';

class KategoriMenuScreen extends StatefulWidget {
  const KategoriMenuScreen({super.key});

  @override
  State<KategoriMenuScreen> createState() => _KategoriMenuScreenState();
}

class _KategoriMenuScreenState extends State<KategoriMenuScreen> {
  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF5F7F6);

  final TextEditingController _searchController = TextEditingController();

  String _kategoriAktif = 'Semua';
  String _searchQuery = '';

  String _namaUser = 'Pengguna';
  String _emailUser = '';

  late Future<List<Map<String, String>>> _produkFuture;

  final List<Map<String, dynamic>> _kategori = [
    {'nama': 'Semua', 'ikon': Icons.grid_view_rounded},
    {'nama': 'Makanan', 'ikon': Icons.restaurant},
    {'nama': 'Minuman', 'ikon': Icons.local_drink},
    {'nama': 'Kerajinan', 'ikon': Icons.brush},
    {'nama': 'Fashion', 'ikon': Icons.shopping_bag},
    {'nama': 'Lainnya', 'ikon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();

    _produkFuture = _ambilProduk();
    _ambilProfilUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // AMBIL PROFIL USER
  // ==========================================
  Future<void> _ambilProfilUser() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final data = await supabase
          .from('profiles')
          .select('nama, email')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _namaUser = data?['nama']?.toString() ?? 'Pengguna';
        _emailUser = data?['email']?.toString() ?? user.email ?? '';
      });
    } catch (e) {
      debugPrint('Gagal mengambil profil pengguna: $e');
    }
  }

  // ==========================================
  // FORMAT HARGA
  // ==========================================
  String _formatHarga(dynamic harga) {
    final int nilai = harga is num
        ? harga.toInt()
        : int.tryParse(
                harga?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '',
              ) ??
              0;

    final angka = nilai.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp$angka';
  }

  // ==========================================
  // AMBIL SEMUA PRODUK DARI SUPABASE
  // ==========================================
  Future<List<Map<String, String>>> _ambilProduk() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('products')
        .select('''
          id,
          seller_id,
          nama_produk,
          kategori,
          harga,
          stok,
          deskripsi,
          foto_url,
          varian,
          created_at
        ''')
        .gt('stok', 0)
        .order('created_at', ascending: false);

    final data = List<Map<String, dynamic>>.from(response);

    if (data.isEmpty) return [];

    final sellerIds = data
        .map((p) => p['seller_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final Map<String, String> namaPenjualMap = {};

    if (sellerIds.isNotEmpty) {
      try {
        final profiles = await supabase
            .from('profiles')
            .select('id, nama, role, seller_status')
            .inFilter('id', sellerIds);

        for (final profile in profiles) {
          final id = profile['id']?.toString() ?? '';
          final nama = profile['nama']?.toString() ?? '';
          final role = profile['role']?.toString() ?? '';
          final status = profile['seller_status']?.toString() ?? '';

          if (role == 'seller' && status == 'approved') {
            namaPenjualMap[id] = nama.isNotEmpty ? nama : 'Penjual UMKM';
          }
        }
      } catch (e) {
        debugPrint('Gagal mengambil nama penjual: $e');
      }
    }

    return data.map((p) {
      final idPenjual = p['seller_id']?.toString() ?? '';
      final nama = p['nama_produk']?.toString() ?? '';
      final harga = p['harga'];
      final foto = p['foto_url']?.toString() ?? '';
      final varian = p['varian'];

      return <String, String>{
        'id': p['id']?.toString() ?? '',
        'seller_id': idPenjual,
        'nama_produk': nama,
        'name': nama,
        'kategori': p['kategori']?.toString() ?? '',
        'harga': harga?.toString() ?? '0',
        'price': _formatHarga(harga),
        'stok': p['stok']?.toString() ?? '0',
        'deskripsi': p['deskripsi']?.toString() ?? '',
        'foto_url': foto,
        'image': foto,
        'varian': varian == null
            ? ''
            : varian is String
            ? varian
            : varian.toString(),
        'created_at': p['created_at']?.toString() ?? '',
        'nama_penjual': namaPenjualMap[idPenjual] ?? 'Penjual UMKM',
      };
    }).toList();
  }

  // ==========================================
  // REFRESH PRODUK
  // ==========================================
  Future<void> _refreshProduk() async {
    final future = _ambilProduk();

    setState(() {
      _produkFuture = future;
    });

    await future;
  }

  // ==========================================
  // FILTER KATEGORI
  // ==========================================
  bool _sesuaiKategori(Map<String, String> produk) {
    if (_kategoriAktif == 'Semua') return true;

    final kategoriProduk = (produk['kategori'] ?? '').trim().toLowerCase();

    if (_kategoriAktif == 'Lainnya') {
      const kategoriUtama = ['makanan', 'minuman', 'kerajinan', 'fashion'];

      return !kategoriUtama.contains(kategoriProduk);
    }

    return kategoriProduk == _kategoriAktif.toLowerCase();
  }

  // ==========================================
  // FILTER PENCARIAN
  // ==========================================
  List<Map<String, String>> _filterProduk(List<Map<String, String>> produk) {
    return produk.where((p) {
      final nama = (p['nama_produk'] ?? '').toLowerCase();
      final kategori = (p['kategori'] ?? '').toLowerCase();
      final penjual = (p['nama_penjual'] ?? '').toLowerCase();

      final cocokPencarian =
          nama.contains(_searchQuery) ||
          kategori.contains(_searchQuery) ||
          penjual.contains(_searchQuery);

      return _sesuaiKategori(p) && cocokPencarian;
    }).toList();
  }

  // ==========================================
  // BUKA DETAIL PRODUK
  // ==========================================
  void _bukaDetail(Map<String, String> produk) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailProductScreen(product: produk)),
    );
  }

  // ==========================================
  // BOTTOM NAVIGATION
  // ==========================================
  void _onBottomNavigationTap(int index) {
    switch (index) {
      case 0:
        // Kembali ke halaman Beranda sebelumnya.
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        break;

      case 1:
        // Sudah berada di halaman Kategori.
        break;

      case 2:
        // Membuka Keranjang.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
        break;

      case 3:
        // Membuka halaman Akun.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AkunScreen(
              nama: _namaUser,
              email: _emailUser,
              showScaffold: true,
              onProfileUpdated: _ambilProfilUser,
            ),
          ),
        );
        break;
    }
  }

  // ==========================================
  // KARTU KATEGORI - TAMPILAN BARU
  // ==========================================

  // ==========================================
  // KARTU KATEGORI - SAMA DENGAN HOME SCREEN
  // ==========================================
  Widget _buildKategori(Map<String, dynamic> item) {
    final nama = item['nama'] as String;
    final ikon = item['ikon'] as IconData;

    return GestureDetector(
      onTap: () {
        setState(() {
          _kategoriAktif = nama;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryColor,
            child: Icon(ikon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(nama, style: const TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }

  // ==========================================
  // GAMBAR PRODUK
  // ==========================================
  Widget _gambarProduk(Map<String, String> produk) {
    final foto = produk['foto_url'] ?? '';

    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      return Image.network(
        foto,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _gambarKosong(),
      );
    }

    if (foto.startsWith('assets/')) {
      return Image.asset(
        foto,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _gambarKosong(),
      );
    }

    return _gambarKosong();
  }

  Widget _gambarKosong() {
    return Center(
      child: Icon(Icons.image_outlined, size: 38, color: Colors.grey.shade400),
    );
  }

  // ==========================================
  // KARTU PRODUK
  // ==========================================
  Widget _buildKartuProduk(Map<String, String> produk) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _bukaDetail(produk),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9EEEB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF8FAF9),
                  padding: const EdgeInsets.all(9),
                  child: _gambarProduk(produk),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk['nama_produk'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF303B34),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      produk['price'] ?? 'Rp0',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            produk['nama_penjual'] ?? 'Penjual UMKM',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DAFTAR PRODUK
  // ==========================================
  Widget _buildDaftarProduk() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _produkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Produk gagal dimuat.'),
                TextButton(
                  onPressed: _refreshProduk,
                  child: Text(
                    'Coba Lagi',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          );
        }

        final semuaProduk = snapshot.data ?? [];
        final hasil = _filterProduk(semuaProduk);

        if (hasil.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 45,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    semuaProduk.isEmpty
                        ? 'Belum ada produk yang tersedia.'
                        : 'Produk tidak ditemukan.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          itemCount: hasil.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.69,
          ),
          itemBuilder: (context, index) {
            return _buildKartuProduk(hasil[index]);
          },
        );
      },
    );
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF26332D),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Kategori Produk',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),

      // ==========================================
      // BODY KATEGORI
      // ==========================================
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PENCARIAN
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari produk atau kategori...',
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: Color(0xFFE5EBE7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: Color(0xFFE5EBE7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF26332D),
                ),
              ),

              const SizedBox(height: 12),

              // ==========================================
              // KATEGORI - SAMA DENGAN HOME SCREEN
              // ==========================================
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _kategori
                      .where((item) => item['nama'] != 'Semua')
                      .map((item) {
                        return _buildKategori(item);
                      })
                      .toList(),
                ),
              ),

              const SizedBox(height: 22),

              // JUDUL PRODUK
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _kategoriAktif == 'Semua'
                          ? 'Semua Produk'
                          : 'Produk $_kategoriAktif',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF26332D),
                      ),
                    ),
                  ),
                  Text(
                    'Terbaru',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),

              // DAFTAR PRODUK
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshProduk,
                  color: primaryColor,
                  child: _buildDaftarProduk(),
                ),
              ),
            ],
          ),
        ),
      ),

      // ==========================================
      // BOTTOM NAVIGATION
      // ==========================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: _onBottomNavigationTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}