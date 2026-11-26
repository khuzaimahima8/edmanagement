import 'package:flutter/material.dart';

import 'cart_service_screens.dart';
import 'checkout_screens.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic>? addedProduct;
  final int? initialQuantity;

  const CartScreen({super.key, this.addedProduct, this.initialQuantity});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cartService = CartService.instance;

  bool _isInitializing = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  // ==================================================
  // INISIALISASI KERANJANG
  // ==================================================

  Future<void> _initializeCart() async {
    try {
      await cartService.loadCart();

      if (!mounted) return;

      if (widget.addedProduct != null) {
        cartService.addProduct(
          widget.addedProduct!,
          quantity: widget.initialQuantity ?? 1,
        );

        await cartService.waitForPendingSaves();
      }
    } catch (e) {
      debugPrint('Gagal memuat keranjang: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  // ==================================================
  // FORMAT HARGA
  // ==================================================

  int _price(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(
          value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '',
        ) ??
        0;
  }

  String _formatRupiah(dynamic value) {
    final number = _price(value);
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp$formatted';
  }

  int _quantity(Map<String, dynamic> item) {
    final quantity = _price(item['quantity']);
    return quantity < 1 ? 1 : quantity;
  }

  int _subtotal(Map<String, dynamic> item) {
    return _price(item['price'] ?? item['harga']) * _quantity(item);
  }

  List<Map<String, dynamic>> get _selectedItems {
    return cartService.items.where((item) {
      return item['isSelected'] == true;
    }).toList();
  }

  int get _totalBelanja {
    return _selectedItems.fold<int>(
      0,
      (total, item) => total + _subtotal(item),
    );
  }

  bool get _allSelected {
    return cartService.items.isNotEmpty &&
        cartService.items.every((item) => item['isSelected'] == true);
  }

  // ==================================================
  // PILIH SEMUA PRODUK
  // ==================================================

  void _toggleSelectAll(bool? value) {
    final selected = value ?? false;

    setState(() {
      for (final item in cartService.items) {
        item['isSelected'] = selected;
      }
    });

    for (int i = 0; i < cartService.items.length; i++) {
      cartService.toggleSelected(i, selected);
    }
  }

  // ==================================================
  // PILIH SATU PRODUK
  // ==================================================

  void _toggleProductSelection(Map<String, dynamic> item, bool? value) {
    final index = cartService.items.indexOf(item);

    if (index == -1) return;

    cartService.toggleSelected(index, value ?? false);

    setState(() {});
  }

  // ==================================================
  // UBAH JUMLAH PRODUK
  // ==================================================

  void _changeQuantity(Map<String, dynamic> item, int change) {
    final index = cartService.items.indexOf(item);

    if (index == -1) return;

    final newQuantity = _quantity(item) + change;

    if (newQuantity < 1) return;

    setState(() {
      item['quantity'] = newQuantity;
    });

    cartService.updateQuantity(index, newQuantity);
  }

  // ==================================================
  // HAPUS SATU PRODUK
  // ==================================================

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus produk ini '
            'dari keranjang?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final index = cartService.items.indexOf(item);

    if (index != -1) {
      cartService.removeProduct(index);

      setState(() {});
    }
  }

  // ==================================================
  // HAPUS PRODUK TERPILIH
  // ==================================================

  Future<void> _deleteSelectedItems() async {
    if (_selectedItems.isEmpty || _isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk Terpilih'),
          content: Text(
            'Hapus ${_selectedItems.length} produk terpilih '
            'dari keranjang?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      cartService.removeSelectedItems(
        List<Map<String, dynamic>>.from(_selectedItems),
      );

      await cartService.waitForPendingSaves();
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // ==================================================
  // CHECKOUT
  // ==================================================

  void _goToCheckout() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih produk yang ingin dibeli terlebih dahulu.'),
        ),
      );
      return;
    }

    // Sesuaikan bagian ini dengan constructor CheckoutScreen
    // yang sudah digunakan oleh project Anda.
    final orderItems = _selectedItems.map((item) {
      final data = Map<String, dynamic>.from(item);

      data['product_id'] = item['product_id'] ?? item['id'];
      data['nama_produk'] =
          item['nama_produk'] ?? item['name'] ?? item['nama'] ?? 'Produk';
      data['varian'] = item['varian'] ?? item['variant'] ?? 'Default';
      data['quantity'] = _quantity(item);
      data['harga'] = _price(item['price'] ?? item['harga']);
      data['subtotal'] = _subtotal(item);
      data['foto_url'] =
          item['foto_url'] ?? item['image'] ?? item['gambar'] ?? '';

      return data;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CheckoutScreen(orderItems: orderItems, totalPrice: _totalBelanja),
      ),
    );
  }

  // ==================================================
  // GAMBAR PRODUK
  // ==================================================

  Widget _productImage(Map<String, dynamic> item) {
    final image = (item['image'] ?? item['foto_url'] ?? item['gambar'] ?? '')
        .toString();

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    if (image.isNotEmpty) {
      return Image.asset(
        image,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 82,
      height: 82,
      color: const Color(0xFFF5F7F6),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Color(0xFF006B42),
        size: 32,
      ),
    );
  }

  // ==================================================
  // ITEM PRODUK
  // ==================================================

  Widget _buildProductCard(Map<String, dynamic> item) {
    final name =
        (item['name'] ?? item['nama_produk'] ?? item['nama'] ?? 'Produk')
            .toString();

    final variant = (item['variant'] ?? item['varian'] ?? 'Default').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EAE7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item['isSelected'] == true,
            activeColor: const Color(0xFF006B42),
            onChanged: (value) {
              _toggleProductSelection(item, value);
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _productImage(item),
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 7),
                Text(
                  _formatRupiah(item['price'] ?? item['harga']),
                  style: const TextStyle(
                    color: Color(0xFF006B42),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _quantityButton(
                      icon: Icons.remove,
                      onPressed: () {
                        _changeQuantity(item, -1);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${_quantity(item)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add,
                      onPressed: () {
                        _changeQuantity(item, 1);
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Hapus produk',
                      onPressed: () {
                        _confirmDelete(item);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
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
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD9E0DC)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  // ==================================================
  // TAMPILAN UTAMA
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF006B42),
        elevation: 0,
        actions: [
          if (cartService.items.isNotEmpty)
            IconButton(
              tooltip: 'Hapus produk terpilih',
              onPressed: _isDeleting ? null : _deleteSelectedItems,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF006B42)),
            )
          : cartService.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(),
      bottomNavigationBar: !_isInitializing && cartService.items.isNotEmpty
          ? _buildBottomCheckout()
          : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 76,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Keranjang masih kosong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan pilih produk yang ingin Anda beli.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B42),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali Belanja'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Checkbox(
                value: _allSelected,
                activeColor: const Color(0xFF006B42),
                onChanged: _toggleSelectAll,
              ),
              const Expanded(
                child: Text(
                  'Pilih Semua Produk',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: _selectedItems.isEmpty ? null : _deleteSelectedItems,
                child: const Text(
                  'Hapus Terpilih',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cartService.items.length,
            itemBuilder: (context, index) {
              return _buildProductCard(cartService.items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCheckout() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Belanja',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(_totalBelanja),
                    style: const TextStyle(
                      color: Color(0xFF006B42),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_selectedItems.length} produk dipilih',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _selectedItems.isEmpty ? null : _goToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B42),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}