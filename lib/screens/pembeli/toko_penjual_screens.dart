import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cart_screens.dart';

class TokoPenjualScreen extends StatefulWidget {
  final String sellerId;
  final String namaPenjual;

  const TokoPenjualScreen({
    super.key,
    required this.sellerId,
    required this.namaPenjual,
  });

  @override
  State<TokoPenjualScreen> createState() => _TokoPenjualScreenState();
}

class _TokoPenjualScreenState extends State<TokoPenjualScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  static const Color primaryColor = Color(0xFF006B42);
  static const Color backgroundColor = Color(0xFFF5F7F6);

  late Future<List<Map<String, dynamic>>> _productsFuture;
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<Map<String, dynamic>?> _storeFuture;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // MEMUAT SEMUA DATA
  // ============================================================

  void _loadData() {
    _productsFuture = _loadProducts();
    _profileFuture = _loadProfile();
    _storeFuture = _loadStore();
    _reviewsFuture = _loadReviews();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });

    try {
      await Future.wait([
        _productsFuture,
        _profileFuture,
        _storeFuture,
        _reviewsFuture,
      ]);
    } catch (e) {
      debugPrint('Refresh Detail Toko: $e');
    }
  }

  // ============================================================
  // MENGAMBIL PRODUK
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    final result = await supabase
        .from('products')
        .select()
        .eq('seller_id', widget.sellerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  // ============================================================
  // MENGAMBIL PROFIL DAN INFORMASI TOKO
  // ============================================================

  Future<Map<String, dynamic>> _loadProfile() async {
    Map<String, dynamic> profile = {};
    Map<String, dynamic> store = {};

    // Mengambil profil penjual dari tabel profiles.
    try {
      final result = await supabase
          .from('profiles')
          .select(
            'id, nama, nama_usaha, no_handphone, alamat, foto_profil, role, seller_status',
          )
          .eq('id', widget.sellerId)
          .maybeSingle();

      if (result != null) {
        profile = Map<String, dynamic>.from(result);
      }
    } catch (e) {
      debugPrint('Gagal mengambil profiles: $e');

      // Cadangan menggunakan RPC yang sudah tersedia.
      try {
        final rpcResult = await supabase.rpc(
          'get_public_seller_profile',
          params: {'p_seller_id': widget.sellerId},
        );

        if (rpcResult is List && rpcResult.isNotEmpty) {
          profile = Map<String, dynamic>.from(rpcResult.first);
        }
      } catch (rpcError) {
        debugPrint('Gagal mengambil RPC profil: $rpcError');
      }
    }

    // Mengambil informasi toko.
    try {
      final result = await supabase
          .from('store_settings')
          .select('nama_toko, deskripsi_toko, foto_url, nomor_whatsapp')
          .eq('seller_id', widget.sellerId)
          .maybeSingle();

      if (result != null) {
        store = Map<String, dynamic>.from(result);
      }
    } catch (e) {
      debugPrint('Gagal mengambil store_settings: $e');
    }

    // Menggabungkan profil dan informasi toko.
    return {
      'nama_toko': _firstNotEmpty([
        store['nama_toko'],
        profile['nama_usaha'],
        profile['nama'],
        widget.namaPenjual,
      ]),
      'foto_toko': _firstNotEmpty([store['foto_url'], profile['foto_profil']]),
      'deskripsi_toko': _firstNotEmpty([store['deskripsi_toko']]),
      'nomor_telepon': _firstNotEmpty([
        store['nomor_whatsapp'],
        profile['no_handphone'],
      ]),
      'alamat': _firstNotEmpty([profile['alamat']]),
      'profile': profile,
      'store': store,
    };
  }

  String _firstNotEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }

    return '';
  }

  // ============================================================
  // STATUS TOKO
  // ============================================================

  Future<Map<String, dynamic>?> _loadStore() async {
    final result = await supabase
        .from('store_settings')
        .select('is_open, jam_buka, jam_tutup')
        .eq('seller_id', widget.sellerId)
        .maybeSingle();

    return result;
  }

  // ============================================================
  // ULASAN
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadReviews() async {
    final result = await supabase
        .from('reviews')
        .select('rating, ulasan, created_at, buyer_id')
        .eq('seller_id', widget.sellerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  // ============================================================
  // FORMAT HARGA
  // ============================================================

  int _convertPrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  String _rupiah(dynamic value) {
    final number = _convertPrice(value);

    return 'Rp${number.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
  }

  // ============================================================
  // TAMBAH KE KERANJANG
  // ============================================================

  void _addToCart(Map<String, dynamic> product) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    final stock = int.tryParse(product['stok']?.toString() ?? '0') ?? 0;

    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maaf, stok produk sedang habis.')),
      );
      return;
    }

    final namaProduk = product['nama_produk']?.toString() ?? 'Produk UMKM';

    final harga = _convertPrice(product['harga']);

    final foto = product['foto_url']?.toString() ?? '';

    final dynamic varianData = product['varian'];

    String varian = 'Default';

    if (varianData is String && varianData.trim().isNotEmpty) {
      varian = varianData;
    } else if (varianData is List && varianData.isNotEmpty) {
      varian = varianData.join(', ');
    } else if (varianData is Map && varianData.isNotEmpty) {
      varian = varianData.values.join(', ');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          addedProduct: {
            'product_id': product['id']?.toString(),
            'name': namaProduk,
            'variant': varian,
            'price': harga,
            'image': foto,
          },
          initialQuantity: 1,
        ),
      ),
    );
  }

  // ============================================================
  // FOTO PROFIL TOKO
  // ============================================================

  Widget _profilePhoto(String photo) {
    final imageUrl = photo.trim();

    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.startsWith('http://') || imageUrl.startsWith('https://')
            ? Image.network(
                imageUrl,
                key: ValueKey(imageUrl),
                width: 104,
                height: 104,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _profilePlaceholder();
                },
              )
            : _profilePlaceholder(),
      ),
    );
  }

  Widget _profilePlaceholder() {
    return Container(
      color: const Color(0xFFE5F1E9),
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_rounded,
        size: 48,
        color: primaryColor,
      ),
    );
  }

  // ============================================================
  // PROFIL TOKO
  // ============================================================

  Widget _profileSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 230,
            child: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorCard('Gagal memuat profil toko: ${snapshot.error}');
        }

        final seller = snapshot.data;

        if (seller == null) {
          return _errorCard('Data toko tidak ditemukan.');
        }

        final nama = _firstNotEmpty([
          seller['nama_toko'],
          widget.namaPenjual,
          'Penjual UMKM',
        ]);

        final photo = seller['foto_toko']?.toString() ?? '';

        final phone = seller['nomor_telepon']?.toString() ?? '';

        final address = seller['alamat']?.toString() ?? '';

        final description = seller['deskripsi_toko']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 75,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -48),
                child: Column(
                  children: [
                    _profilePhoto(photo),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        nama,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF26332B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Penjual UMKM',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          _profileInfoRow(
                            Icons.phone_outlined,
                            phone.isEmpty
                                ? 'Nomor telepon belum tersedia'
                                : phone,
                          ),

                          const SizedBox(height: 13),

                          _profileInfoRow(
                            Icons.location_on_outlined,
                            address.isEmpty ? 'Alamat belum tersedia' : address,
                          ),

                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 13),
                            _profileInfoRow(Icons.store_outlined, description),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _profileInfoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF58645D),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS TOKO
  // ============================================================

  Widget _storeStatus() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _storeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(color: primaryColor);
        }

        if (snapshot.hasError) {
          return _statusCard(
            isOpen: false,
            title: 'Status toko tidak dapat dimuat',
            subtitle: 'Silakan coba perbarui halaman.',
          );
        }

        final store = snapshot.data;

        if (store == null) {
          return _statusCard(
            isOpen: false,
            title: 'Status toko belum diatur',
            subtitle: 'Penjual belum mengatur status tokonya.',
          );
        }

        final isOpen = store['is_open'] == true;

        final openTime = store['jam_buka']?.toString() ?? '';

        final closeTime = store['jam_tutup']?.toString() ?? '';

        final jamToko = openTime.isNotEmpty && closeTime.isNotEmpty
            ? '$openTime - $closeTime'
            : 'Jam operasional belum diatur';

        return _statusCard(
          isOpen: isOpen,
          title: isOpen ? 'Toko Sedang Buka' : 'Toko Sedang Tutup',
          subtitle: 'Jam operasional: $jamToko',
        );
      },
    );
  }

  Widget _statusCard({
    required bool isOpen,
    required String title,
    required String subtitle,
  }) {
    final warna = isOpen ? const Color(0xFF16834A) : const Color(0xFFD64B4B);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFEAF6EE) : const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: warna.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOpen
                  ? Icons.storefront_rounded
                  : Icons.store_mall_directory_outlined,
              color: warna,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, color: warna, size: 9),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: warna,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF59665E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RATING DAN ULASAN
  // ============================================================

  Widget _ratingSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text('Gagal memuat ulasan: ${snapshot.error}');
        }

        final reviews = snapshot.data ?? [];

        final ratings = reviews
            .map(
              (review) => int.tryParse(review['rating']?.toString() ?? '') ?? 0,
            )
            .where((rating) => rating >= 1 && rating <= 5)
            .toList();

        final average = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b) / ratings.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 35),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ratings.isEmpty
                            ? 'Belum ada rating'
                            : average.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${ratings.length} rating pembeli',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Ulasan Pembeli',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'Belum ada ulasan dari pembeli.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              )
            else
              ...reviews.map((review) {
                final rating =
                    int.tryParse(review['rating']?.toString() ?? '') ?? 0;

                final comment = review['ulasan']?.toString() ?? '';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ),

                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          comment,
                          style: const TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // ============================================================
  // GAMBAR PRODUK
  // ============================================================

  // ============================================================
  // GAMBAR PRODUK - UKURAN SERAGAM 1:1
  // ============================================================

  Widget _productImage(String? url) {
    final imageUrl = url?.trim() ?? '';

    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: imageUrl.startsWith('http://') || imageUrl.startsWith('https://')
            ? Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return _imagePlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _imagePlaceholder();
                },
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1F3F1),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 42, color: Colors.grey.shade400),
    );
  }
  // ============================================================
  // KARTU PRODUK
  // ============================================================

  Widget _productCard(Map<String, dynamic> product) {
    final namaProduk = product['nama_produk']?.toString() ?? 'Produk UMKM';

    final harga = product['harga'] ?? 0;

    final stok = int.tryParse(product['stok']?.toString() ?? '0') ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE8ECE9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _productImage(product['foto_url']?.toString()),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 36,
                    child: Text(
                      namaProduk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _rupiah(harga),
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    stok > 0 ? 'Stok: $stok' : 'Stok habis',
                    style: TextStyle(
                      fontSize: 11,
                      color: stok > 0 ? Colors.black54 : Colors.red,
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 37,
                    child: ElevatedButton(
                      onPressed: stok > 0 ? () => _addToCart(product) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_shopping_cart, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              stok > 0 ? 'Tambah ke Keranjang' : 'Stok Habis',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR CARD
  // ============================================================

  Widget _errorCard(String message) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
    );
  }

  // ============================================================
  // JUDUL BAGIAN
  // ============================================================

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 21),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF26332B),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAMPILAN UTAMA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Detail Toko',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF26332B),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshData,
            tooltip: 'Perbarui halaman',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // PROFIL TOKO
            _profileSection(),

            // STATUS TOKO
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Status Toko', Icons.storefront_outlined),
                  const SizedBox(height: 13),
                  _storeStatus(),
                ],
              ),
            ),

            // RATING DAN ULASAN
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(
                    'Rating dan Ulasan',
                    Icons.star_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _ratingSection(),
                ],
              ),
            ),

            // PRODUK TOKO
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Produk Toko', Icons.shopping_bag_outlined),

                  const SizedBox(height: 14),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(25),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text('Gagal memuat produk: ${snapshot.error}');
                      }

                      final products = snapshot.data ?? [];

                      if (products.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 25),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 9),
                                Text(
                                  'Belum ada produk di toko ini.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.58,
                            ),
                        itemBuilder: (context, index) {
                          return _productCard(products[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}