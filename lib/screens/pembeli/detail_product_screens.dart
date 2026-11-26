import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cart_screens.dart' show CartScreen;
import 'cart_service_screens.dart';
import 'checkout_screens.dart';
import 'toko_penjual_screens.dart';
import 'chat_penjual_screens.dart';

class DetailProductScreen extends StatefulWidget {
  final Map<String, String> product;

  const DetailProductScreen({super.key, required this.product});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  static const Color primaryColor = Color(0xFF006B42);
  static const Color backgroundColor = Color(0xFFF5F7F6);

  int _selectedVariantIndex = 0;
  int _quantity = 1;

  bool _isFavorite = false;
  bool _isAddingToCart = false;
  bool _isBuyingNow = false;

  late Future<Map<String, dynamic>> _sellerFuture;
  late Future<Map<String, dynamic>?> _storeFuture;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  String get _sellerId => widget.product['seller_id'] ?? '';

  @override
  void initState() {
    super.initState();

    _sellerFuture = _loadSeller();
    _storeFuture = _loadStore();
    _reviewsFuture = _loadReviews();
  }

  // =========================================================
  // FORMAT HARGA
  // =========================================================

  int _priceToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    final cleaned = value.toString().replaceAll(RegExp(r'[^0-9]'), '');

    return int.tryParse(cleaned) ?? 0;
  }

  String _formatRupiah(dynamic value) {
    final number = _priceToInt(value);

    final formatted = number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp$formatted';
  }

  // =========================================================
  // VARIAN PRODUK
  // =========================================================

  List<String> _getVariants() {
    final rawVariant = widget.product['varian']?.trim() ?? '';

    if (rawVariant.isEmpty || rawVariant == 'null' || rawVariant == '[]') {
      return [];
    }

    if (rawVariant.startsWith('[') && rawVariant.endsWith(']')) {
      final content = rawVariant.substring(1, rawVariant.length - 1);

      if (content.trim().isEmpty) return [];

      return content
          .split(',')
          .map((item) => item.trim().replaceAll('"', '').replaceAll("'", ''))
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [rawVariant];
  }

  // =========================================================
  // GAMBAR PRODUK
  // =========================================================

  Widget _imageFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1F3F1),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 55,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    final path = imagePath.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        key: ValueKey(path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _imageFallback();
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return _imageFallback();
        },
      );
    }

    if (path.isNotEmpty) {
      return Image.asset(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _imageFallback();
        },
      );
    }

    return _imageFallback();
  }

  // =========================================================
  // FOTO TOKO
  // =========================================================

  Widget _buildSellerAvatar(String fotoProfil) {
    final photo = fotoProfil.trim();

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE5F1E9),
        border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: photo.startsWith('http://') || photo.startsWith('https://')
          ? Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _sellerPlaceholder();
              },
            )
          : _sellerPlaceholder(),
    );
  }

  Widget _sellerPlaceholder() {
    return const Center(
      child: Icon(Icons.storefront_rounded, color: primaryColor, size: 29),
    );
  }

  // =========================================================
  // HELPER DATA
  // =========================================================

  String _firstNotEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }

    return fallback;
  }

  // =========================================================
  // MENGAMBIL PROFIL DAN INFORMASI TOKO
  // =========================================================

  Future<Map<String, dynamic>> _loadSeller() async {
    Map<String, dynamic> profile = {};
    Map<String, dynamic> store = {};

    if (_sellerId.isEmpty) {
      return {
        'nama_toko': 'Penjual UMKM',
        'foto_toko': '',
        'alamat': '',
        'nomor_telepon': '',
        'deskripsi_toko': '',
      };
    }

    // Mengambil profil penjual.
    try {
      final result = await supabase
          .from('profiles')
          .select('id, nama, nama_usaha, no_handphone, alamat, foto_profil')
          .eq('id', _sellerId)
          .maybeSingle();

      if (result != null) {
        profile = Map<String, dynamic>.from(result);
      }
    } catch (e) {
      debugPrint('Gagal mengambil profil penjual: $e');
    }

    // Mengambil informasi toko.
    try {
      final result = await supabase
          .from('store_settings')
          .select('nama_toko, deskripsi_toko, foto_url, nomor_whatsapp')
          .eq('seller_id', _sellerId)
          .maybeSingle();

      if (result != null) {
        store = Map<String, dynamic>.from(result);
      }
    } catch (e) {
      debugPrint('Gagal mengambil informasi toko: $e');
    }

    // RPC menjadi cadangan apabila profil langsung tidak tersedia.
    if (profile.isEmpty) {
      try {
        final rpcResult = await supabase.rpc(
          'get_public_seller_profile',
          params: {'p_seller_id': _sellerId},
        );

        if (rpcResult is List && rpcResult.isNotEmpty) {
          profile = Map<String, dynamic>.from(rpcResult.first as Map);
        } else if (rpcResult is Map) {
          profile = Map<String, dynamic>.from(rpcResult);
        }
      } catch (e) {
        debugPrint('Gagal mengambil RPC profil penjual: $e');
      }
    }

    final productStoreName = _firstNotEmpty([
      widget.product['store_name'],
      widget.product['nama_penjual'],
    ]);

    return {
      'nama_toko': _firstNotEmpty([
        store['nama_toko'],
        profile['nama_usaha'],
        profile['nama'],
        productStoreName,
      ], fallback: 'Penjual UMKM'),

      'foto_toko': _firstNotEmpty([store['foto_url'], profile['foto_profil']]),

      'deskripsi_toko': _firstNotEmpty([store['deskripsi_toko']]),

      'nomor_telepon': _firstNotEmpty([
        store['nomor_whatsapp'],
        profile['no_handphone'],
      ]),

      'alamat': _firstNotEmpty([profile['alamat']]),
    };
  }

  // =========================================================
  // STATUS TOKO
  // =========================================================

  Future<Map<String, dynamic>?> _loadStore() async {
    if (_sellerId.isEmpty) return null;

    final result = await supabase
        .from('store_settings')
        .select('is_open, jam_buka, jam_tutup')
        .eq('seller_id', _sellerId)
        .maybeSingle();

    return result;
  }

  Widget _buildStoreStatus() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _storeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Status toko tidak dapat dimuat.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Memuat status toko...',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        final store = snapshot.data;

        if (store == null) {
          return const Text(
            'Status toko belum diatur',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        final isOpen = store['is_open'] == true;

        final openTime = store['jam_buka']?.toString() ?? '';

        final closeTime = store['jam_tutup']?.toString() ?? '';

        final hours = openTime.isNotEmpty && closeTime.isNotEmpty
            ? ' • $openTime - $closeTime'
            : '';

        return Row(
          children: [
            Icon(
              Icons.circle,
              size: 9,
              color: isOpen ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${isOpen ? 'Toko buka' : 'Toko tutup'}$hours',
                style: TextStyle(
                  fontSize: 11,
                  color: isOpen ? Colors.green.shade700 : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // MENGAMBIL ULASAN
  // =========================================================

  Future<List<Map<String, dynamic>>> _loadReviews() async {
    if (_sellerId.isEmpty) return [];

    final result = await supabase
        .from('reviews')
        .select('rating, ulasan, created_at')
        .eq('seller_id', _sellerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  // =========================================================
  // RATING DAN ULASAN
  // =========================================================

  Widget _buildSellerRating() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Rating belum dapat dimuat.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Memuat rating...',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        final reviews = snapshot.data ?? [];

        final ratings = reviews
            .map(
              (review) => int.tryParse(review['rating']?.toString() ?? '') ?? 0,
            )
            .where((rating) => rating >= 1 && rating <= 5)
            .toList();

        if (ratings.isEmpty) {
          return const Text(
            'Belum ada rating',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        final average = ratings.reduce((a, b) => a + b) / ratings.length;

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            _showReviews(reviews, average, ratings.length);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 17),
                const SizedBox(width: 4),
                Text(
                  '${average.toStringAsFixed(1)} (${ratings.length})',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReviews(
    List<Map<String, dynamic>> reviews,
    double average,
    int total,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating dan Ulasan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${average.toStringAsFixed(1)} dari 5 ($total rating)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];

                        final rating =
                            int.tryParse(review['rating']?.toString() ?? '') ??
                            0;

                        final comment = review['ulasan']?.toString() ?? '';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE5F1E9),
                            child: Icon(
                              Icons.person_outline,
                              color: primaryColor,
                            ),
                          ),
                          title: Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 17,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            comment.isEmpty ? 'Tanpa komentar' : comment,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // PROFIL PENJUAL
  // =========================================================

  Widget _buildSellerSection() {
    if (_sellerId.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _sellerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _sellerErrorCard('Gagal memuat informasi toko.');
        }

        final seller = snapshot.data ?? {};

        final namaPenjual = _firstNotEmpty([
          seller['nama_toko'],
        ], fallback: 'Penjual UMKM');

        final fotoProfil = seller['foto_toko']?.toString() ?? '';

        final alamatPenjual = seller['alamat']?.toString() ?? '';

        final nomorHp = seller['nomor_telepon']?.toString() ?? '';

        final description = seller['deskripsi_toko']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE8ECE9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSellerAvatar(fotoProfil),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Toko',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          namaPenjual,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF26332B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Penjual UMKM',
                          style: TextStyle(fontSize: 11, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chat penjual',
                    onPressed: () {
                      _openSellerChat(namaPenjual);
                    },
                    icon: const Icon(Icons.chat_outlined, color: primaryColor),
                  ),
                ],
              ),

              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],

              if (alamatPenjual.isNotEmpty) ...[
                const SizedBox(height: 12),
                _sellerInfoRow(Icons.location_on_outlined, alamatPenjual),
              ],

              if (nomorHp.isNotEmpty) ...[
                const SizedBox(height: 8),
                _sellerInfoRow(Icons.phone_outlined, nomorHp),
              ],

              const Divider(height: 22),

              _buildStoreStatus(),

              const SizedBox(height: 8),

              _buildSellerRating(),

              const SizedBox(height: 13),

              SizedBox(
                width: double.infinity,
                height: 43,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TokoPenjualScreen(
                          sellerId: _sellerId,
                          namaPenjual: namaPenjual,
                        ),
                      ),
                    );
                  },
                  child: const Text('Lihat Toko'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sellerInfoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 2),
        Icon(icon, size: 17, color: primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sellerErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      ),
    );
  }

  // =========================================================
  // CHAT PENJUAL
  // =========================================================

  void _openSellerChat(String namaPenjual) {
    final namaProduk =
        widget.product['nama_produk'] ??
        widget.product['name'] ??
        'Produk UMKM';

    final fotoProduk =
        widget.product['foto_url'] ?? widget.product['image'] ?? '';

    final hargaProduk = _priceToInt(
      widget.product['harga'] ?? widget.product['price'] ?? '0',
    );

    final deskripsiProduk =
        widget.product['deskripsi'] ?? widget.product['description'] ?? '';

    final variants = _getVariants();

    final selectedVariant =
        variants.isNotEmpty && _selectedVariantIndex < variants.length
        ? variants[_selectedVariantIndex]
        : '';

    final Map<String, String> chatProduct = {
      ...widget.product,
      'id': widget.product['id'] ?? '',
      'product_id': widget.product['id'] ?? '',
      'nama_produk': namaProduk,
      'foto_url': fotoProduk,
      'harga': hargaProduk.toString(),
      'deskripsi': deskripsiProduk,
      'varian': selectedVariant,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPenjualScreen(
          sellerId: _sellerId,
          namaPenjual: namaPenjual,
          product: chatProduct,
        ),
      ),
    );
  }

  // =========================================================
  // DATA PRODUK UNTUK PESANAN
  // =========================================================

  Map<String, dynamic> _buildOrderProduct({
    required String name,
    required int price,
    required String imagePath,
    required String selectedVariant,
  }) {
    final productId = widget.product['id'] ?? '';

    final variant = selectedVariant.isNotEmpty ? selectedVariant : 'Default';

    return {
      ...widget.product,
      'id': productId,
      'product_id': productId,
      'seller_id': _sellerId,
      'name': name,
      'nama_produk': name,
      'price': price,
      'harga': price.toString(),
      'image': imagePath,
      'foto_url': imagePath,
      'variant': variant,
      'varian': variant,
      'quantity': _quantity,
      'isSelected': true,
      'subtotal': price * _quantity,
      'store_name':
          widget.product['store_name'] ??
          widget.product['nama_penjual'] ??
          'Penjual UMKM',
    };
  }

  // =========================================================
  // VALIDASI PEMBELIAN
  // =========================================================

  bool _validatePurchase(int stock) {
    if (supabase.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return false;
    }

    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok produk sedang habis.')),
      );
      return false;
    }

    if (_quantity < 1 || _quantity > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah produk harus antara 1 dan $stock.')),
      );
      return false;
    }

    final productId = widget.product['id'] ?? '';

    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID produk tidak ditemukan.')),
      );
      return false;
    }

    return true;
  }

  // =========================================================
  // TAMBAH KE KERANJANG
  // =========================================================

  Future<void> _addToCart({
    required String name,
    required int price,
    required String imagePath,
    required String selectedVariant,
    required int stock,
  }) async {
    if (_isAddingToCart || _isBuyingNow) return;

    if (!_validatePurchase(stock)) return;

    setState(() => _isAddingToCart = true);

    try {
      final product = _buildOrderProduct(
        name: name,
        price: price,
        imagePath: imagePath,
        selectedVariant: selectedVariant,
      );

      CartService.instance.addProduct(product, quantity: _quantity);

      await CartService.instance.waitForPendingSaves();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name ditambahkan ke keranjang.'),
          backgroundColor: primaryColor,
        ),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses keranjang: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  // =========================================================
  // BELI SEKARANG
  // =========================================================

  Future<void> _beliSekarang({
    required String name,
    required int price,
    required String imagePath,
    required String selectedVariant,
    required int stock,
  }) async {
    if (_isAddingToCart || _isBuyingNow) return;

    if (!_validatePurchase(stock)) return;

    setState(() => _isBuyingNow = true);

    try {
      final orderProduct = _buildOrderProduct(
        name: name,
        price: price,
        imagePath: imagePath,
        selectedVariant: selectedVariant,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            totalPrice: price * _quantity,
            orderItems: [orderProduct],
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka checkout: $error')));
    } finally {
      if (mounted) {
        setState(() => _isBuyingNow = false);
      }
    }
  }

  // =========================================================
  // TOMBOL JUMLAH
  // =========================================================

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
          color: disabled ? const Color(0xFFF1F3F1) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          color: disabled ? Colors.grey : primaryColor,
          size: 20,
        ),
      ),
    );
  }

  // =========================================================
  // TAMPILAN UTAMA
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final String name =
        widget.product['nama_produk'] ??
        widget.product['name'] ??
        'Detail Produk';

    final String imagePath =
        widget.product['image'] ?? widget.product['foto_url'] ?? '';

    final String description =
        widget.product['deskripsi'] ?? widget.product['description'] ?? '';

    final int priceValue = _priceToInt(
      widget.product['harga'] ?? widget.product['price'] ?? '0',
    );

    final List<String> variants = _getVariants();

    final int stock = int.tryParse(widget.product['stok'] ?? '0') ?? 0;

    final bool canBuy = stock > 0;

    final String selectedVariant =
        variants.isNotEmpty && _selectedVariantIndex < variants.length
        ? variants[_selectedVariantIndex]
        : '';

    return Scaffold(
      backgroundColor: backgroundColor,

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF26332B)),
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            color: Color(0xFF26332B),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Favorit',
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black54,
            ),
          ),
        ],
      ),

      // =====================================================
      // KONTEN DETAIL PRODUK
      // =====================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO PRODUK
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECE9)),
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _buildProductImage(imagePath),
                ),
              ),
            ),

            const SizedBox(height: 17),

            // NAMA DAN HARGA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF26332B),
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    _formatRupiah(priceValue),
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: canBuy
                          ? const Color(0xFFEAF6EE)
                          : const Color(0xFFFFEEEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          canBuy
                              ? Icons.inventory_2_outlined
                              : Icons.info_outline,
                          size: 16,
                          color: canBuy ? primaryColor : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          canBuy
                              ? 'Stok tersedia: $stock'
                              : 'Stok produk habis',
                          style: TextStyle(
                            fontSize: 12,
                            color: canBuy ? primaryColor : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 13),

            // PROFIL TOKO
            _buildSellerSection(),

            const SizedBox(height: 5),

            // DESKRIPSI PRODUK
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    description.isNotEmpty
                        ? description
                        : 'Belum ada deskripsi produk.',
                    style: const TextStyle(
                      color: Color(0xFF626D66),
                      height: 1.6,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // VARIAN PRODUK
            if (variants.isNotEmpty) ...[
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Varian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: List.generate(variants.length, (index) {
                        final selected = _selectedVariantIndex == index;

                        return ChoiceChip(
                          label: Text(variants[index]),
                          selected: selected,
                          selectedColor: primaryColor.withValues(alpha: 0.15),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected
                                ? primaryColor
                                : Colors.grey.shade300,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? primaryColor : Colors.black87,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          onSelected: (value) {
                            if (!value) return;

                            setState(() {
                              _selectedVariantIndex = index;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],

            // JUMLAH PRODUK
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Produk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _quantityButton(
                        icon: Icons.remove,
                        disabled: _quantity <= 1,
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() {
                              _quantity--;
                            });
                          }
                        },
                      ),

                      Container(
                        width: 55,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      _quantityButton(
                        icon: Icons.add,
                        disabled: !canBuy || _quantity >= stock,
                        onTap: () {
                          if (_quantity < stock) {
                            setState(() {
                              _quantity++;
                            });
                          }
                        },
                      ),

                      const Spacer(),

                      Text(
                        'Stok: $stock',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SUBTOTAL
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    _formatRupiah(priceValue * _quantity),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),

      // =====================================================
      // TOMBOL KERANJANG DAN BELI SEKARANG
      // =====================================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: canBuy && !_isAddingToCart && !_isBuyingNow
                        ? () {
                            _addToCart(
                              name: name,
                              price: priceValue,
                              imagePath: imagePath,
                              selectedVariant: selectedVariant,
                              stock: stock,
                            );
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isAddingToCart
                        ? const SizedBox(
                            height: 17,
                            width: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.shopping_cart_outlined, size: 19),
                    label: Text(
                      _isAddingToCart ? 'Menyimpan...' : 'Keranjang',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: canBuy && !_isAddingToCart && !_isBuyingNow
                        ? () {
                            _beliSekarang(
                              name: name,
                              price: priceValue,
                              imagePath: imagePath,
                              selectedVariant: selectedVariant,
                              stock: stock,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isBuyingNow
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            canBuy ? 'Beli Sekarang' : 'Stok Habis',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}