import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPenjualScreen extends StatefulWidget {
  final String sellerId;
  final String namaPenjual;
  final Map<String, String> product;

  const ChatPenjualScreen({
    super.key,
    required this.sellerId,
    required this.namaPenjual,
    required this.product,
  });

  @override
  State<ChatPenjualScreen> createState() => _ChatPenjualScreenState();
}

class _ChatPenjualScreenState extends State<ChatPenjualScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? chatId;
  String? errorMessage;

  bool loading = true;
  bool _isSending = false;

  // =====================================================
  // DATA PRODUK
  // =====================================================

  String get namaProduk {
    return widget.product['nama_produk'] ??
        widget.product['name'] ??
        'Produk UMKM';
  }

  String get fotoProduk {
    return widget.product['foto_url'] ?? widget.product['image'] ?? '';
  }

  String get deskripsiProduk {
    return widget.product['deskripsi'] ?? widget.product['description'] ?? '';
  }

  String get varianProduk {
    return widget.product['varian'] ?? '';
  }

  int get hargaProduk {
    final harga = widget.product['harga'] ?? widget.product['price'] ?? '0';

    return int.tryParse(harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  String get productId {
    return (widget.product['product_id'] ?? widget.product['id'] ?? '').trim();
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  // =====================================================
  // CARI ROOM BERDASARKAN PEMBELI DAN PENJUAL
  // SATU PEMBELI + SATU PENJUAL = SATU ROOM
  // =====================================================

  Future<Map<String, dynamic>?> _cariChat(String buyerId) async {
    return await supabase
        .from('chats')
        .select('id')
        .eq('buyer_id', buyerId)
        .eq('seller_id', widget.sellerId)
        .maybeSingle();
  }

  // =====================================================
  // INIT CHAT
  // =====================================================

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      if (widget.sellerId.trim().isEmpty) {
        throw Exception('ID penjual tidak ditemukan.');
      }

      if (productId.isEmpty) {
        throw Exception('ID produk tidak ditemukan.');
      }

      if (user.id == widget.sellerId) {
        throw Exception('Kamu tidak dapat chat toko sendiri.');
      }

      // Cari room berdasarkan buyer_id dan seller_id saja.
      final existingChat = await _cariChat(user.id);

      String idChat;

      if (existingChat != null) {
        idChat = existingChat['id'].toString();
      } else {
        try {
          // Room baru tidak lagi menyimpan satu product_id.
          final newChat = await supabase
              .from('chats')
              .insert({'buyer_id': user.id, 'seller_id': widget.sellerId})
              .select('id')
              .single();

          idChat = newChat['id'].toString();
        } on PostgrestException catch (e) {
          // Jika dua proses membuat room bersamaan,
          // ambil room yang sudah berhasil dibuat.
          if (e.code == '23505') {
            final duplicateChat = await _cariChat(user.id);

            if (duplicateChat != null) {
              idChat = duplicateChat['id'].toString();
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      }

      // Pastikan konteks produk tersedia dalam room.
      await _simpanKonteksProduk(idChat: idChat, buyerId: user.id);

      if (!mounted) return;

      setState(() {
        chatId = idChat;
        loading = false;
        errorMessage = null;
      });
    } catch (e) {
      debugPrint('INIT CHAT ERROR: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  // =====================================================
  // SIMPAN KONTEKS PRODUK KE MESSAGES
  // =====================================================

  Future<void> _simpanKonteksProduk({
    required String idChat,
    required String buyerId,
  }) async {
    // Periksa apakah produk ini sudah pernah diperkenalkan
    // dalam percakapan yang sama.
    final konteksAda = await supabase
        .from('messages')
        .select('id')
        .eq('chat_id', idChat)
        .eq('product_id', productId)
        .limit(1)
        .maybeSingle();

    // Jangan membuat kartu produk yang sama berulang kali
    // setiap kali pembeli membuka halaman chat.
    if (konteksAda != null) {
      return;
    }

    await supabase.from('messages').insert({
      'chat_id': idChat,
      'sender_id': buyerId,
      'message': 'Saya ingin bertanya tentang produk ini.',
      'product_id': productId,
      'product_name': namaProduk,
      'product_image': fotoProduk,
      'product_price': hargaProduk,
      'product_variant': varianProduk,
      'product_description': deskripsiProduk,
    });
  }

  // =====================================================
  // KIRIM PESAN
  // =====================================================

  Future<void> _kirimPesan() async {
    final pesan = _messageController.text.trim();

    if (pesan.isEmpty || _isSending) return;

    final user = supabase.auth.currentUser;

    if (user == null || chatId == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      await supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': user.id,
        'message': pesan,
      });

      _messageController.clear();

      _scrollKeBawah();
    } catch (e) {
      debugPrint('KIRIM PESAN ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesan gagal dikirim: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // =====================================================
  // SCROLL KE BAWAH
  // =====================================================

  void _scrollKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // =====================================================
  // PARSE TANGGAL
  // =====================================================

  DateTime? _parseTanggal(dynamic waktu) {
    if (waktu == null) return null;

    return DateTime.tryParse(waktu.toString())?.toLocal();
  }

  // =====================================================
  // FORMAT JAM
  // =====================================================

  String _formatWaktu(dynamic waktu) {
    final date = _parseTanggal(waktu);

    if (date == null) return '';

    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');

    return '$jam:$menit';
  }

  // =====================================================
  // FORMAT TANGGAL
  // =====================================================

  String _formatTanggal(DateTime tanggal) {
    const namaHari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const namaBulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final sekarang = DateTime.now();

    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

    final hariPesan = DateTime(tanggal.year, tanggal.month, tanggal.day);

    final selisih = hariIni.difference(hariPesan).inDays;

    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Kemarin';

    if (tanggal.year == sekarang.year) {
      return '${namaHari[tanggal.weekday - 1]}, '
          '${tanggal.day} ${namaBulan[tanggal.month - 1]}';
    }

    return '${namaHari[tanggal.weekday - 1]}, '
        '${tanggal.day} ${namaBulan[tanggal.month - 1]} '
        '${tanggal.year}';
  }

  // =====================================================
  // PEMISAH TANGGAL
  // =====================================================

  Widget _buildPemisahTanggal(DateTime tanggal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFEB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatTanggal(tanggal),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF52645A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // GAMBAR PRODUK
  // =====================================================

  Widget _gambarPengganti({double width = 85, double height = 85}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey,
        size: 35,
      ),
    );
  }

  Widget _buildGambarProduk(
    String foto, {
    double width = 85,
    double height = 85,
  }) {
    if (foto.isEmpty) {
      return _gambarPengganti(width: width, height: height);
    }

    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          foto,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _gambarPengganti(width: width, height: height);
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        foto,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _gambarPengganti(width: width, height: height);
        },
      ),
    );
  }

  // =====================================================
  // KARTU PRODUK DALAM RIWAYAT PESAN
  // =====================================================

  Widget _buildKartuProduk(Map<String, dynamic> message) {
    final nama = message['product_name']?.toString() ?? 'Produk UMKM';

    final foto = message['product_image']?.toString() ?? '';

    final deskripsi = message['product_description']?.toString() ?? '';

    final varian = message['product_variant']?.toString() ?? '';

    final hargaValue = message['product_price'];

    final harga = hargaValue == null
        ? 0
        : (hargaValue is num
              ? hargaValue.toInt()
              : int.tryParse(hargaValue.toString()) ?? 0);

    return Container(
      width: 290,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE7E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGambarProduk(foto, width: 75, height: 75),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Produk yang ditanyakan',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rp${_formatHarga(harga)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF006B42),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (varian.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text('Varian: $varian', style: const TextStyle(fontSize: 11)),
                ],
                if (deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BUBBLE PESAN
  // =====================================================

  Widget _buildPesan(Map<String, dynamic> message) {
    final user = supabase.auth.currentUser;

    final isMe = message['sender_id']?.toString() == user?.id;

    final isiPesan = message['message']?.toString() ?? '';

    final waktu = _formatWaktu(message['created_at']);

    final productIdMessage = message['product_id']?.toString() ?? '';

    final productNameMessage = message['product_name']?.toString() ?? '';

    final memilikiKonteksProduk =
        productIdMessage.isNotEmpty || productNameMessage.isNotEmpty;

    final warnaBubble = isMe ? const Color(0xFF006B42) : Colors.grey.shade200;

    final warnaTeks = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Kartu produk hanya muncul jika pesan
            // memiliki informasi produk.
            if (memilikiKonteksProduk) _buildKartuProduk(message),

            // Bubble isi pesan.
            if (isiPesan.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: warnaBubble,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isiPesan,
                        style: TextStyle(color: warnaTeks, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      waktu,
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // INPUT PESAN
  // =====================================================

  Widget _buildInputPesan() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                filled: true,
                fillColor: const Color(0xFFF5F7F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _kirimPesan(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSending ? null : _kirimPesan,
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF006B42),
                    ),
                  )
                : const Icon(Icons.send, color: Color(0xFF006B42)),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B42),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.namaPenjual,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Text(
              'Chat Penjual',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF006B42)),
            )
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 45,
                    ),
                    const SizedBox(height: 12),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          loading = true;
                          errorMessage = null;
                        });

                        _initChat();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B42),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase
                        .from('messages')
                        .stream(primaryKey: ['id'])
                        .eq('chat_id', chatId!)
                        .order('created_at', ascending: true),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Gagal memuat pesan:\n'
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF006B42),
                          ),
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada pesan.\n'
                            'Mulai percakapan dengan penjual.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollKeBawah();
                      });

                      final List<Widget> daftarChat = [];

                      DateTime? tanggalSebelumnya;

                      for (final message in messages) {
                        final tanggal = _parseTanggal(message['created_at']);

                        if (tanggal != null) {
                          final tanggalPesan = DateTime(
                            tanggal.year,
                            tanggal.month,
                            tanggal.day,
                          );

                          if (tanggalSebelumnya == null ||
                              tanggalPesan != tanggalSebelumnya) {
                            daftarChat.add(_buildPemisahTanggal(tanggal));

                            tanggalSebelumnya = tanggalPesan;
                          }
                        }

                        daftarChat.add(_buildPesan(message));
                      }

                      return ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        children: daftarChat,
                      );
                    },
                  ),
                ),
                _buildInputPesan(),
              ],
            ),
    );
  }
}