
import 'package:flutter/material.dart';

import 'home_screens.dart'; // Sesuaikan nama file Beranda
import 'akun_screens.dart'; // Sesuaikan nama file Akun
import 'cart_screens.dart';
import 'kategori_screens.dart';

class MarketplaceShell extends StatefulWidget {
  const MarketplaceShell({super.key});

  @override
  State<MarketplaceShell> createState() =>
      _MarketplaceShellState();
}

class _MarketplaceShellState extends State<MarketplaceShell> {
  int halamanAktif = 0;

  // Kategori yang sedang dibuka.
  String? kategoriTerpilih;

  void bukaKategori(String kategori) {
    setState(() {
      kategoriTerpilih = kategori;
    });
  }

  void kembaliKeDaftarKategori() {
    setState(() {
      kategoriTerpilih = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> halaman = [
      const HomeScreen(),
      kategoriTerpilih == null
          ? KategoriMenuShell(
              onPilihKategori: bukaKategori,
            )
          : KategoriScreen(
              kategori: kategoriTerpilih!,
              onBack: kembaliKeDaftarKategori,
            ),
      const CartScreen(),
      const AkunScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: halamanAktif,
        children: halaman,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: halamanAktif,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFF8FE),
        selectedItemColor: const Color(0xFF006B42),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            halamanAktif = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

// Daftar pilihan kategori di dalam navigasi utama.
class KategoriMenuShell extends StatelessWidget {
  final ValueChanged<String> onPilihKategori;

  const KategoriMenuShell({
    super.key,
    required this.onPilihKategori,
  });

  final List<String> kategori = const [
    'Fashion',
    'Makanan',
    'Minuman',
    'Kerajinan',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        backgroundColor: const Color(0xFF006B42),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kategori.length,
        itemBuilder: (context, index) {
          final nama = kategori[index];

          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.category_outlined,
                color: Color(0xFF006B42),
              ),
              title: Text(nama),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onPilihKategori(nama),
            ),
          );
        },
      ),
    );
  }
}
