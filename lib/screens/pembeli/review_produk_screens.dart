import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewProdukScreen extends StatefulWidget {
  final String orderItemId;
  final String productId;
  final String productName;
  final String sellerId;

  const ReviewProdukScreen({
    super.key,
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.sellerId,
  });

  @override
  State<ReviewProdukScreen> createState() => _ReviewProdukScreenState();
}

class _ReviewProdukScreenState extends State<ReviewProdukScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF5F7F6);

  final TextEditingController _ulasanController = TextEditingController();

  int _rating = 5;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _alreadyReviewed = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _reviews = [];

  double get _averageRating {
    if (_reviews.isEmpty) return 0;

    final total = _reviews.fold<int>(
      0,
      (sum, item) => sum + _toInt(item['rating']),
    );

    return total / _reviews.length;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _ulasanController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      // Pastikan pesanan milik pembeli dan sudah selesai.
      final order = await supabase
          .from('orders')
          .select('id, buyer_id, status, items')
          .eq('id', widget.orderItemId)
          .eq('buyer_id', user.id)
          .maybeSingle();

      if (order == null ||
          order['status']?.toString().toLowerCase() != 'completed') {
        throw Exception('Rating hanya dapat diberikan untuk pesanan selesai.');
      }

      // Pastikan produk memang ada di dalam pesanan.
      final rawItems = order['items'];
      final items = rawItems is List ? rawItems : [];

      final productExists = items.any((item) {
        if (item is! Map) return false;

        return item['product_id']?.toString() == widget.productId;
      });

      if (!productExists) {
        throw Exception('Produk tidak ditemukan dalam pesanan ini.');
      }

      // Ambil seller_id dari tabel products.
      final product = await supabase
          .from('products')
          .select('seller_id')
          .eq('id', widget.productId)
          .maybeSingle();

      if (product == null) {
        throw Exception('Produk tidak ditemukan.');
      }

      final seller = product['seller_id']?.toString() ?? '';

      if (seller.isEmpty) {
        throw Exception('Data penjual produk tidak ditemukan.');
      }

      // Periksa apakah pembeli sudah memberikan ulasan.
      final existingReview = await supabase
          .from('reviews')
          .select('id')
          .eq('order_id', widget.orderItemId)
          .eq('product_id', widget.productId)
          .maybeSingle();

      final response = await supabase
          .from('reviews')
          .select('rating, ulasan, created_at')
          .eq('product_id', widget.productId)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _alreadyReviewed = existingReview != null;
        _reviews = List<Map<String, dynamic>>.from(
          response.map((item) => Map<String, dynamic>.from(item)),
        );
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });

      debugPrint('Gagal memuat ulasan: $error');
    }
  }

  Future<void> _submitReview() async {
    if (_isSubmitting || _alreadyReviewed) return;

    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage('Silakan login terlebih dahulu.');
      return;
    }

    final ulasan = _ulasanController.text.trim();

    if (ulasan.isEmpty) {
      _showMessage('Silakan tulis ulasan produk terlebih dahulu.');
      return;
    }

    if (_rating < 1 || _rating > 5) {
      _showMessage('Pilih rating antara 1 sampai 5 bintang.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Validasi ulang sebelum menyimpan.
      final order = await supabase
          .from('orders')
          .select('id, status, items')
          .eq('id', widget.orderItemId)
          .eq('buyer_id', user.id)
          .maybeSingle();

      if (order == null ||
          order['status']?.toString().toLowerCase() != 'completed') {
        throw Exception('Pesanan belum selesai atau tidak ditemukan.');
      }

      final rawItems = order['items'];
      final items = rawItems is List ? rawItems : [];

      final productExists = items.any((item) {
        if (item is! Map) return false;
        return item['product_id']?.toString() == widget.productId;
      });

      if (!productExists) {
        throw Exception('Produk tidak ditemukan dalam pesanan.');
      }

      final product = await supabase
          .from('products')
          .select('seller_id')
          .eq('id', widget.productId)
          .single();

      final sellerId = product['seller_id']?.toString() ?? '';

      if (sellerId.isEmpty) {
        throw Exception('Penjual produk tidak ditemukan.');
      }

      await supabase.from('reviews').insert({
        'order_id': widget.orderItemId,
        'product_id': widget.productId,
        'seller_id': sellerId,
        'buyer_id': user.id,
        'rating': _rating,
        'ulasan': ulasan,
      });

      if (!mounted) return;

      setState(() {
        _alreadyReviewed = true;
      });

      _showMessage('Rating dan ulasan berhasil dikirim.');

      await _loadReviews();

      if (!mounted) return;

      Navigator.pop(context, true);
    } on PostgrestException catch (error) {
      debugPrint('Supabase review error: ${error.message}');

      if (!mounted) return;

      if (error.code == '23505') {
        _showMessage('Anda sudah memberikan ulasan untuk produk ini.');
        setState(() {
          _alreadyReviewed = true;
        });
      } else {
        _showMessage('Gagal mengirim ulasan. ${error.message}');
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
      debugPrint('Review error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return '-';

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  Widget _buildStars({required int rating, double size = 24}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber.shade700,
          size: size,
        );
      }),
    );
  }

  Widget _buildRatingForm() {
    if (_alreadyReviewed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF006B42)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Anda sudah memberikan rating dan ulasan untuk produk ini.',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beri Rating dan Ulasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            widget.productName,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 14),
          const Text('Bagaimana penilaian Anda?'),
          const SizedBox(height: 6),
          Row(
            children: [
              ...List.generate(5, (index) {
                final starNumber = index + 1;

                return IconButton(
                  tooltip: '$starNumber bintang',
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _rating = starNumber;
                          });
                        },
                  icon: Icon(
                    starNumber <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber.shade700,
                    size: 32,
                  ),
                );
              }),
              const SizedBox(width: 4),
              Text(
                '$_rating/5',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ulasanController,
            enabled: !_isSubmitting,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Ceritakan pengalaman Anda membeli produk ini...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReview,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSubmitting ? 'Mengirim ulasan...' : 'Kirim Ulasan',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final rating = _toInt(review['rating']).clamp(0, 5);
    final ulasan = (review['ulasan'] ?? '').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.person_outline, color: primaryColor),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pembeli',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _formatDate(review['created_at']),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStars(rating: rating, size: 19),
          const SizedBox(height: 8),
          Text(
            ulasan.isEmpty ? 'Tidak ada komentar.' : ulasan,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              _buildStars(
                rating: _reviews.isEmpty
                    ? 0
                    : _averageRating.round().clamp(0, 5),
                size: 17,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rating Produk',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_reviews.length} ulasan',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Rating dan Ulasan'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Column(
                children: [
                  Text(_errorMessage!),
                  TextButton.icon(
                    onPressed: _loadReviews,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              )
            else
              _buildRatingForm(),

            const SizedBox(height: 18),
            _buildReviewSummary(),
            const SizedBox(height: 18),
            const Text(
              'Ulasan Pembeli',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const SizedBox.shrink()
            else if (_errorMessage != null)
              const Text('Ulasan belum dapat dimuat.')
            else if (_reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 42,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text('Belum ada ulasan untuk produk ini.'),
                    Text('Jadilah pembeli pertama yang memberi ulasan.'),
                  ],
                ),
              )
            else
              ..._reviews.map(_buildReviewItem),
          ],
        ),
      ),
    );
  }
}