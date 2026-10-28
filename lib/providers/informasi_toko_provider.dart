import 'package:supabase_flutter/supabase_flutter.dart';

class InformasiTokoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =========================================
  // MENGAMBIL ID PENJUAL YANG SEDANG LOGIN
  // =========================================

  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Kamu harus login menggunakan Supabase Auth.',
      );
    }

    return user.id;
  }

  // =========================================
  // MENYIMPAN ATAU MEMPERBARUI INFORMASI TOKO
  // =========================================

  Future<void> simpanInformasiToko({
    required String namaToko,
    required String deskripsi,
    required String kategori,
    required String alamat,
    required String nomorTelepon,
    required String nomorWhatsApp,
    String? fotoToko,
  }) async {
    await _supabase.from('informasi_toko').upsert(
      {
        'user_id': _userId,
        'nama_toko': namaToko,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
        'nomor_whatsapp': nomorWhatsApp,
        'foto_toko': fotoToko,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  // =========================================
  // MENGAMBIL INFORMASI TOKO MILIK PENJUAL
  // =========================================

  Future<Map<String, dynamic>?> ambilTokoSaya() async {
    final data = await _supabase
        .from('informasi_toko')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    return data;
  }

  // =========================================
  // MEMANTAU PERUBAHAN DATA TOKO UNTUK PEMBELI
  // =========================================

  Stream<List<Map<String, dynamic>>> pantauTokoAktif() {
    return _supabase
        .from('informasi_toko')
        .stream(primaryKey: ['id'])
        .eq('aktif', true);
  }
}