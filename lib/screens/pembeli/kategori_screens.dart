import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_product_screens.dart';

class KategoriScreen extends StatefulWidget {
  final String kategori;

  const KategoriScreen({super.key, required this.kategori});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF5F7F6);

  late Future<List<Map<String, String>>> _produkFuture;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _produkFuture = _getProdukKategori();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // FORMAT HARGA
  // ==========================================
  String _formatHarga(dynamic harga) {
    final int nilai = harga is num
        ? harga.toInt()
        : int.tryParse(harga?.toString() ?? '') ?? 0;

    final String angka = nilai.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp$angka';
  }

  // ==========================================
  // AMBIL PRODUK SESUAI KATEGORI DARI SUPABASE
  // ==========================================
  Future<List<Map<String, String>>> _getProdukKategori() async {
    final supabase = Supabase.instance.client;

    try {
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
          .eq('kategori', widget.kategori)
          .gt('stok', 0)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> dataProduk =
          List<Map<String, dynamic>>.from(response);

      if (dataProduk.isEmpty) {
        return [];
      }

      // Ambil ID penjual.
      final Set<String> sellerIds = dataProduk
          .map((produk) => produk['seller_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final Map<String, String> namaPenjualMap = {};

      // Ambil nama penjual yang sudah disetujui admin.
      if (sellerIds.isNotEmpty) {
        try {
          final profiles = await supabase
              .from('profiles')
              .select('id, nama, role, seller_status')
              .inFilter('id', sellerIds.toList());

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
          debugPrint('ERROR AMBIL NAMA PENJUAL: $e');
        }
      }

      // Gabungkan data produk dan nama penjual.
      return dataProduk.map((produk) {
        final sellerId = produk['seller_id']?.toString() ?? '';
        final namaProduk = produk['nama_produk']?.toString() ?? '';
        final harga = produk['harga'];
        final fotoUrl = produk['foto_url']?.toString() ?? '';
        final varian = produk['varian'];

        return <String, String>{
          'id': produk['id']?.toString() ?? '',
          'seller_id': sellerId,
          'nama_produk': namaProduk,
          'name': namaProduk,
          'kategori': produk['kategori']?.toString() ?? '',
          'harga': harga?.toString() ?? '0',
          'price': _formatHarga(harga),
          'stok': produk['stok']?.toString() ?? '0',
          'deskripsi': produk['deskripsi']?.toString() ?? '',
          'foto_url': fotoUrl,
          'image': fotoUrl,
          'varian': varian == null
              ? ''
              : varian is String
              ? varian
              : varian.toString(),
          'created_at': produk['created_at']?.toString() ?? '',
          'nama_penjual': namaPenjualMap[sellerId] ?? 'Penjual UMKM',
        };
      }).toList();
    } catch (e) {
      debugPrint('ERROR AMBIL PRODUK KATEGORI: $e');
      rethrow;
    }
  }

  // ==========================================
  // REFRESH PRODUK
  // ==========================================
  Future<void> _refreshProduk() async {
    final future = _getProdukKategori();

    setState(() {
      _produkFuture = future;
    });

    await future;
  }

  // ==========================================
  // BUKA DETAIL PRODUK
  // ==========================================
  void _openProduct(Map<String, String> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailProductScreen(product: product),
      ),
    );
  }

  // ==========================================
  // GAMBAR PRODUK
  // ==========================================
  Widget _buildProductImage(Map<String, String> product) {
    final fotoUrl = product['foto_url'] ?? '';
    final imagePath = product['image'] ?? '';

    if (fotoUrl.isNotEmpty) {
      return Image.network(
        fotoUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _gambarKosong();
        },
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _gambarKosong();
        },
      );
    }

    return _gambarKosong();
  }

  // ==========================================
  // GAMBAR KOSONG
  // ==========================================
  Widget _gambarKosong() {
    return Container(
      color: const Color(0xFFF1F4F2),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: 34,
      ),
    );
  }

  // ==========================================
  // KARTU PRODUK MINIMALIS
  // ==========================================
  Widget _buildProductCard(Map<String, String> product) {
    final nama = product['nama_produk'] ?? '';
    final harga = product['price'] ?? 'Rp0';
    final namaPenjual = product['nama_penjual'] ?? 'Penjual UMKM';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openProduct(product),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EEEA), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GAMBAR PRODUK
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF8FAF9),
                  padding: const EdgeInsets.all(8),
                  child: _buildProductImage(product),
                ),
              ),

              // INFORMASI PRODUK
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF26332D),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      harga,
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
                            namaPenjual,
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
  // KOLOM PENCARIAN MINIMALIS
  // ==========================================
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        style: const TextStyle(fontSize: 13, color: Color(0xFF26332D)),
        decoration: InputDecoration(
          hintText: 'Cari ${widget.kategori}',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF929D96)),
          prefixIcon: Icon(Icons.search_rounded, size: 21, color: primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 19),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5EBE7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 1),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STATUS KOSONG
  // ==========================================
  Widget _buildEmptyState({required IconData icon, required String message}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(icon, size: 52, color: Colors.grey.shade400),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BUILD DAFTAR PRODUK
  // ==========================================
  Widget _buildProductList() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _produkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 2.5,
            ),
          );
        }

        if (snapshot.hasError) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 100),
              Icon(
                Icons.wifi_off_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Produk gagal dimuat.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton.icon(
                  onPressed: _refreshProduk,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Coba Lagi'),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
              ),
            ],
          );
        }

        final semuaProduk = snapshot.data ?? [];

        // PENCARIAN BERDASARKAN NAMA PRODUK DAN PENJUAL
        final hasilPencarian = semuaProduk.where((product) {
          final nama = (product['nama_produk'] ?? '').toLowerCase();
          final penjual = (product['nama_penjual'] ?? '').toLowerCase();

          return nama.contains(_searchQuery) || penjual.contains(_searchQuery);
        }).toList();

        if (hasilPencarian.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inventory_2_outlined,
            message: _searchQuery.isNotEmpty
                ? 'Produk tidak ditemukan.\nCoba kata kunci lainnya.'
                : 'Belum ada produk ${widget.kategori} yang tersedia.',
          );
        }

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          itemCount: hasilPencarian.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.70,
          ),
          itemBuilder: (context, index) {
            return _buildProductCard(hasilPencarian[index]);
          },
        );
      },
    );
  }

  // ==========================================
  // BUILD UTAMA
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF26332D),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Text(
          widget.kategori,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // PENCARIAN
            _buildSearchField(),

            // DAFTAR PRODUK DAN REFRESH
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProduk,
                color: primaryColor,
                backgroundColor: Colors.white,
                child: _buildProductList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}