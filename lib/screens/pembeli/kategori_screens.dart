
import 'package:flutter/material.dart';
import 'detail_product_screens.dart';

class KategoriScreen extends StatelessWidget {
  final String kategori;
  final VoidCallback? onBack;

  final Color primaryColor = const Color(0xFF006B42);

  const KategoriScreen({
    super.key,
    required this.kategori,
    this.onBack,
  });

  // =========================
  // SEMUA PRODUK
  // =========================
  final List<Map<String, String>> products = const [
    {
      'name': 'Tas Rajut',
      'price': 'Rp17.000',
      'image': 'assets/tas rajut.jpeg',
      'kategori': 'Fashion',
    },
    {
      'name': 'Keripik Pisang',
      'price': 'Rp10.000',
      'image': 'assets/rojomolo.jpeg',
      'kategori': 'Makanan',
    },
    {
      'name': 'Kopi Cendana',
      'price': 'Rp25.000',
      'image': 'assets/kopi cendono.jpeg',
      'kategori': 'Minuman',
    },
    {
      'name': 'Stik Kelor',
      'price': 'Rp12.000',
      'image': 'assets/tiktik daun kelor.jpeg',
      'kategori': 'Makanan',
    },
    {
      'name': 'Kerajinan Bambu',
      'price': 'Rp35.000',
      'image': 'assets/tas rajut.jpeg',
      'kategori': 'Kerajinan',
    },
    {
      'name': 'Produk UMKM Lainnya',
      'price': 'Rp20.000',
      'image': 'assets/rojomolo.jpeg',
      'kategori': 'Lainnya',
    },
  ];

  // =========================
  // FILTER PRODUK BERDASARKAN KATEGORI
  // =========================
  List<Map<String, String>> get filteredProducts {
    return products
        .where((product) => product['kategori'] == kategori)
        .toList();
  }

  // =========================
  // FUNGSI KEMBALI
  // =========================
  void _kembali(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProducts = filteredProducts;

    return Scaffold(
      backgroundColor: Colors.white,

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _kembali(context),
        ),
        title: Text(
          kategori,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: categoryProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada produk $kategori',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: categoryProducts.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 18,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = categoryProducts[index];
                final imagePath = product['image'] ?? '';
                final name = product['name'] ?? '';
                final price = product['price'] ?? '';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailProductScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GAMBAR PRODUK
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            imagePath,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // NAMA PRODUK
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // HARGA PRODUK
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
