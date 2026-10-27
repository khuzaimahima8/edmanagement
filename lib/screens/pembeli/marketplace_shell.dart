import 'package:flutter/material.dart';

import 'home_screens.dart';
import 'akun_screens.dart';
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

  // Membuka kategori yang dipilih.
  void bukaKategori(String kategori) {
    setState(() {
      kategoriTerpilih = kategori;
      halamanAktif = 1;
    });
  }

  // Kembali ke daftar kategori.
  void kembaliKeDaftarKategori() {
    setState(() {
      kategoriTerpilih = null;
    });
  }

  // Berpindah ke tab yang dipilih.
  void pindahHalaman(int index) {
    setState(() {
      halamanAktif = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> halaman = [
      // HALAMAN 0: BERANDA
      const HomeScreen(),

      // HALAMAN 1: KATEGORI
      kategoriTerpilih == null
          ? KategoriMenuShell(
              onPilihKategori: bukaKategori,
            )
          : KategoriScreen(
              kategori: kategoriTerpilih!,
              onBack: kembaliKeDaftarKategori,
            ),

      // HALAMAN 2: KERANJANG
      const CartScreen(),

      // HALAMAN 3: AKUN
      AkunScreen(
        onNavigateTab: (index) {
          pindahHalaman(index);
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: halamanAktif,
        children: halaman,
      ),

      // NAVIGASI BAWAH
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: halamanAktif,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFF8FE),
        selectedItemColor: const Color(0xFF006B42),
        unselectedItemColor: Colors.grey,

        onTap: pindahHalaman,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DAFTAR KATEGORI
// =====================================================

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
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),

              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.category_outlined,
                  color: Color(0xFF006B42),
                ),
              ),

              title: Text(
                nama,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF006B42),
              ),

              onTap: () {
                onPilihKategori(nama);
              },
            ),
          );
        },
      ),
    );
  }
}
