
import 'package:flutter/material.dart';

import 'detail_product_screens.dart';
import 'kategori_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFF006B42);

  // Controller dan kata pencarian
  final TextEditingController _searchController =
      TextEditingController();

  String _kataPencarian = '';
  String _namaUser = 'Pengguna Dummy';

  // =========================
  // AMBIL DATA USER (MOCK)
  // =========================
  Future<void> _getNamaUser() async {
    try {
      debugPrint('HOME - MOCK FRONT-END MODE');

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (mounted) {
        setState(() {
          _namaUser = 'Pengguna Dummy';
        });
      }
    } catch (e) {
      debugPrint('ERROR MOCK GET USER: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getNamaUser();
  }

  // =========================
  // KATEGORI
  // =========================
  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.restaurant,
      'label': 'Makanan',
    },
    {
      'icon': Icons.local_drink,
      'label': 'Minuman',
    },
    {
      'icon': Icons.brush,
      'label': 'Kerajinan',
    },
    {
      'icon': Icons.shopping_bag,
      'label': 'Fashion',
    },
    {
      'icon': Icons.more_horiz,
      'label': 'Lainnya',
    },
  ];

  // =========================
  // PRODUK
  // =========================
  final List<Map<String, String>> products = [
    {
      'name': 'Tas Rajut',
      'price': 'Rp17.000',
      'image': 'assets/tas rajut.jpeg',
    },
    {
      'name': 'Keripik Pisang',
      'price': 'Rp10.000',
      'image': 'assets/rojomolo.jpeg',
    },
    {
      'name': 'Kopi Cendana',
      'price': 'Rp25.000',
      'image': 'assets/kopi cendono.jpeg',
    },
    {
      'name': 'Stik Kelor',
      'price': 'Rp12.000',
      'image': 'assets/tiktik daun kelor.jpeg',
    },
  ];

  // =========================
  // FILTER PENCARIAN PRODUK
  // =========================
  List<Map<String, String>> get _produkTerfilter {
    final kataKunci = _kataPencarian.trim().toLowerCase();

    if (kataKunci.isEmpty) {
      return products;
    }

    return products.where((produk) {
      final nama = produk['name'] ?? '';

      return nama.toLowerCase().contains(kataKunci);
    }).toList();
  }

  // =========================
  // BUKA KATEGORI
  // =========================
  void _openCategory(String kategori) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KategoriScreen(
          kategori: kategori,
        ),
      ),
    );
  }

  // =========================
  // BUKA DETAIL PRODUK
  // =========================
  void _openProduct(Map<String, String> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailProductScreen(
          product: product,
        ),
      ),
    );
  }

  // =========================
  // HALAMAN BERANDA
  // =========================
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $_namaUser',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Temukan produk UMKM\nterbaik di sini',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE8F5EF),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =========================
            // SEARCH PRODUK
            // =========================
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _kataPencarian = value;
                });
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari Produk',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                suffixIcon: _kataPencarian.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _kataPencarian = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // KATEGORI
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: categories.map((cat) {
                final String categoryName =
                    cat['label']?.toString() ?? '';

                return GestureDetector(
                  onTap: () {
                    _openCategory(categoryName);
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: primaryColor,
                        child: Icon(
                          cat['icon'] as IconData? ??
                              Icons.category,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // =========================
            // PRODUK TERBARU
            // =========================
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _kataPencarian.isEmpty
                      ? 'Produk Terbaru'
                      : 'Hasil Pencarian',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_kataPencarian.isEmpty)
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            if (_kataPencarian.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_produkTerfilter.length} produk ditemukan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // =========================
            // HASIL PENCARIAN / GRID PRODUK
            // =========================
            if (_produkTerfilter.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 16,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Produk tidak ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Coba gunakan kata kunci lainnya.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: _produkTerfilter.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final item = _produkTerfilter[index];

                  final imagePath = item['image'] ?? '';
                  final name = item['name'] ?? '';
                  final price = item['price'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      _openProduct(item);
                    },
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(16),
                            child: imagePath.isNotEmpty
                                ? Image.asset(
                                    imagePath,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Container(
                                        color:
                                            Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(
                                            Icons
                                                .image_not_supported,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildHomeContent(),
    );
  }

  // =========================
  // BERSIHKAN CONTROLLER
  // =========================
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
