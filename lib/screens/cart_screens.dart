import 'package:flutter/material.dart';
import 'checkout_screens.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic>? addedProduct;
  final int? initialQuantity;

  const CartScreen({
    super.key,
    this.addedProduct,
    this.initialQuantity,
  });
  

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color primaryColor = const Color(0xFF006B42);

  // Data item keranjang dengan variabel 'isSelected' untuk status centang
  List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Tas Rajut',
      'variant': 'Hitam',
      'price': 17000,
      'quantity': 1,
      'image': 'assets/tasrajut.jpeg',
      'isSelected': false, // Status awal belum dicentang
    },
    {
      'name': 'Keripik Pisang',
      'variant': '250 g',
      'price': 10000,
      'quantity': 1,
      'image': 'assets/keripikpisang.jpeg',
      'isSelected': false,
    },
    {
      'name': 'Tas Rajut',
      'variant': 'Default',
      'price': 17000,
      'quantity': 1,
      'image': 'assets/tasrajut.jpeg',
      'isSelected': false,
    },
  ];

  // Hitung Total Item yang dicentang saja
  int get totalSelectedItems {
    int total = 0;
    for (var item in cartItems) {
      if (item['isSelected'] == true) {
        total += (item['quantity'] as int);
      }
    }
    return total;
  }

  // Hitung Total Harga dari item yang dicentang saja
  int get totalPrice {
    int total = 0;
    for (var item in cartItems) {
      if (item['isSelected'] == true) {
        total += (item['price'] as int) * (item['quantity'] as int);
      }
    }
    return total;
  }

  // Format angka ke format rupiah sederhana (misal 17000 -> Rp17.000)
  String formatRupiah(int number) {
    return 'Rp${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: cartItems.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.shade200,
          thickness: 1,
          height: 24,
        ),
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // 1. Tanda Centang / Checkbox
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: item['isSelected'],
                    activeColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        item['isSelected'] = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Gambar Produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    item['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // 3. Nama, Varian & Harga
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['variant'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(item['price']),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Tombol Kuantitas (- 1 +)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (item['quantity'] > 1) {
                            setState(() {
                              item['quantity']--;
                            });
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text('-', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          '${item['quantity']}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            item['quantity']++;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text('+', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // 5. Bagian Bawah (Total Item, Total Harga, dan Tombol Checkout)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total item dinamis berdasarkan centang
                Text(
                  'Total ($totalSelectedItems item)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                // Total harga dinamis berdasarkan centang
                Text(
                  formatRupiah(totalPrice),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: totalSelectedItems > 0
                    ? () {
                        // Aksi Checkout jika ada item yang dicentang
                      }
                    : null, // Berubah nonaktif jika tidak ada item dicentang
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}