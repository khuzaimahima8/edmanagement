import 'package:flutter/material.dart';

enum StatusPesanan {
  baru,
  diproses,
  dikirim,
  sampai,
}

String namaStatus(StatusPesanan status) {
  switch (status) {
    case StatusPesanan.baru:
      return 'Pesanan Baru';
    case StatusPesanan.diproses:
      return 'Sedang Diproses';
    case StatusPesanan.dikirim:
      return 'Sudah Dikirim';
    case StatusPesanan.sampai:
      return 'Barang Sudah Sampai';
  }
}

class Pesanan {
  final String id;
  final String namaPembeli;
  final String namaProduk;
  final int jumlah;
  final int harga;
  StatusPesanan status;

  Pesanan({
    required this.id,
    required this.namaPembeli,
    required this.namaProduk,
    required this.jumlah,
    required this.harga,
    this.status = StatusPesanan.baru,
  });

  int get total => jumlah * harga;
}

class PesananProvider extends ChangeNotifier {
  final List<Pesanan> _daftarPesanan = [
    Pesanan(
      id: 'ORD001',
      namaPembeli: 'Siti',
      namaProduk: 'Tas Rajut',
      jumlah: 2,
      harga: 17000,
    ),
    Pesanan(
      id: 'ORD002',
      namaPembeli: 'Aisyah',
      namaProduk: 'Keripik Pisang',
      jumlah: 1,
      harga: 10000,
    ),
  ];

  List<Pesanan> get daftarPesanan =>
      List.unmodifiable(_daftarPesanan);

  void ubahStatus(String id, StatusPesanan statusBaru) {
    final index = _daftarPesanan.indexWhere(
      (pesanan) => pesanan.id == id,
    );

    if (index == -1) return;

    final pesanan = _daftarPesanan[index];

    // Status hanya boleh bergerak maju.
    if (statusBaru.index != pesanan.status.index + 1) {
      return;
    }

    pesanan.status = statusBaru;
    notifyListeners();
  }

  void tambahPesanan(Pesanan pesanan) {
    _daftarPesanan.add(pesanan);
    notifyListeners();
  }
}