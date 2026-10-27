
import 'package:flutter/material.dart';
import 'cart_servis_screens.dart';

class CartScreen extends StatefulWidget {
  final Map<String, String>? addedProduct;
  final int initialQuantity;

  const CartScreen({
    super.key,
    this.addedProduct,
    this.initialQuantity = 1,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService.instance;

  static const Color primaryColor = Color(0xFF006B42);
  bool _isInitializing = true;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    try {
      // Muat keranjang yang tersimpan terlebih dahulu.
      await _cartService.loadCart();

      // Tambahkan produk dari halaman detail jika tersedia.
      final product = widget.addedProduct;

      if (product != null && mounted) {
        final normalizedProduct = <String, dynamic>{
          ...product,
          'id': product['product_id'] ?? product['id'],
          'name': product['nama_produk'] ??
              product['name'] ??
              'Produk',
          'price': _parsePrice(
            product['price'] ?? product['harga'],
          ),
          'image': product['image'] ??
              product['foto_url'] ??
              product['gambar'] ??
              '',
          'variant': product['varian_dipilih'] ??
              product['variant'] ??
              product['varian'] ??
              'Default',
          'stok': product['stok'] ?? '0',
        };

        _cartService.addProduct(
          normalizedProduct,
          quantity: widget.initialQuantity,
        );
      }
    } catch (error) {
      debugPrint('Gagal menyiapkan keranjang: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Keranjang gagal dimuat. Periksa koneksi dan Supabase.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  int _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();

    return int.tryParse(
          value.toString().replaceAll(
                RegExp(r'[^0-9]'),
                '',
              ),
        ) ??
        0;
  }

  String _formatRupiah(dynamic value) {
    final price = _parsePrice(value);
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );

    return 'Rp$formatted';
  }

  String _productName(Map<String, dynamic> item) {
    return (item['name'] ??
            item['nama_produk'] ??
            item['nama'] ??
            'Produk')
        .toString();
  }

  String _productImage(Map<String, dynamic> item) {
    return (item['image'] ??
            item['foto_url'] ??
            item['gambar'] ??
            '')
        .toString();
  }

  Widget _buildProductImage(String path) {
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return Image.network(
        path,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      );
    }

    if (path.isNotEmpty) {
      return Image.asset(
        path,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 76,
      height: 76,
      color: Colors.grey.shade100,
      child: const Icon(
        Icons.image_outlined,
        color: Colors.grey,
        size: 30,
      ),
    );
  }

  int _quantity(Map<String, dynamic> item) {
    return _parsePrice(item['quantity']).clamp(1, 999999);
  }

  int _subtotal(Map<String, dynamic> item) {
    return _parsePrice(item['price'] ?? item['harga']) *
        _quantity(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : AnimatedBuilder(
              animation: _cartService,
              builder: (context, _) {
                final items = _cartService.items;

                if (items.isEmpty) {
                  return _buildEmptyCart();
                }

                final selectedItems = items
                    .where(
                      (item) => item['isSelected'] == true,
                    )
                    .toList();

                final total = selectedItems.fold<int>(
                  0,
                  (sum, item) => sum + _subtotal(item),
                );

                final allSelected =
                    items.isNotEmpty &&
                    items.every(
                      (item) => item['isSelected'] == true,
                    );

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: allSelected,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    final selected = value ?? false;

                                    for (int i = 0;
                                        i < items.length;
                                        i++) {
                                      _cartService.toggleSelected(
                                        i,
                                        selected,
                                      );
                                    }
                                  },
                                ),
                                const Expanded(
                                  child: Text(
                                    'Pilih semua produk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${items.length} produk',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(items.length, (index) {
                            final item = items[index];

                            return _buildCartItem(
                              item,
                              index,
                            );
                          }),
                        ],
                      ),
                    ),
                    _buildCheckoutBar(total, selectedItems.length),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 78,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Keranjang masih kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih produk yang kamu inginkan untuk '
              'menambahkannya ke keranjang.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Mulai Belanja'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    Map<String, dynamic> item,
    int index,
  ) {
    final name = _productName(item);
    final image = _productImage(item);
    final price = item['price'] ?? item['harga'] ?? 0;
    final quantity = _quantity(item);
    final variant = (item['variant'] ??
            item['varian_dipilih'] ??
            'Default')
        .toString();

    final stock = int.tryParse(
          (item['stok'] ?? '0').toString(),
        ) ??
        0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item['isSelected'] == true,
            activeColor: primaryColor,
            onChanged: (value) {
              _cartService.toggleSelected(
                index,
                value ?? false,
              );
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildProductImage(image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Varian: $variant',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatRupiah(price),
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _quantityButton(
                      icon: Icons.remove,
                      onPressed: quantity > 1
                          ? () => _cartService.decreaseQuantity(index)
                          : null,
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add,
                      onPressed: stock > 0 && quantity < stock
                          ? () => _cartService.increaseQuantity(index)
                          : null,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Hapus produk',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmRemove(index, name),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 17,
          color: onPressed == null
              ? Colors.grey.shade300
              : primaryColor,
        ),
      ),
    );
  }

  Future<void> _confirmRemove(int index, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('Hapus "$name" dari keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _cartService.removeProduct(index);
    }
  }

  Widget _buildCheckoutBar(int total, int selectedCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
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
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total belanja',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(total),
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$selectedCount produk dipilih',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: selectedCount == 0 || _isCheckingOut
                  ? null
                  : _checkout,
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkout() async {
    if (_isCheckingOut) return;

    setState(() {
      _isCheckingOut = true;
    });

    try {
      await _cartService.waitForPendingSaves();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Keranjang siap. Halaman checkout perlu dihubungkan '
            'ke alur pemesanan.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }
}
