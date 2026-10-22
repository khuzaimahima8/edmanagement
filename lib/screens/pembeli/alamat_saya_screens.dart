
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlamatSayaScreen extends StatefulWidget {
  const AlamatSayaScreen({super.key});

  @override
  State<AlamatSayaScreen> createState() =>
      _AlamatSayaScreenState();
}

class _AlamatSayaScreenState extends State<AlamatSayaScreen> {
  final Color primaryColor = const Color(0xFF006B42);

  static const String _storageKey = 'ed_management_daftar_alamat';
  static const String _mainAddressKey = 'ed_management_alamat_utama';

  List<Map<String, dynamic>> daftarAlamat = [];
  String? idAlamatUtama;
  bool sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatAlamat();
  }

  // ==========================================
  // MEMUAT ALAMAT
  // ==========================================
  Future<void> _muatAlamat() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_storageKey);
    List<Map<String, dynamic>> alamatTersimpan = [];

    if (data != null) {
      try {
        final decoded = jsonDecode(data) as List;

        alamatTersimpan = decoded.map((item) {
          final map = Map<String, dynamic>.from(item as Map);

          // Kompatibilitas dengan data alamat versi sebelumnya.
          map['id'] ??=
              DateTime.now().microsecondsSinceEpoch.toString();
          map['label'] ??= 'Rumah';
          map['nama'] ??= '';
          map['telepon'] ??= '';
          map['provinsi'] ??= '';
          map['kota'] ??= '';
          map['kecamatan'] ??= '';
          map['kodePos'] ??= '';
          map['detail'] ??= map['alamat'] ?? '';

          return map;
        }).toList();
      } catch (_) {
        alamatTersimpan = [];
      }
    }

    String? idUtama = prefs.getString(_mainAddressKey);

    if (!alamatTersimpan.any((item) => item['id'] == idUtama)) {
      idUtama = alamatTersimpan.isNotEmpty
          ? alamatTersimpan.first['id'].toString()
          : null;
    }

    if (mounted) {
      setState(() {
        daftarAlamat = alamatTersimpan;
        idAlamatUtama = idUtama;
        sedangMemuat = false;
      });
    }

    // Simpan hasil migrasi data lama.
    await _simpanAlamat();
  }

  // ==========================================
  // MENYIMPAN ALAMAT KE SHARED PREFERENCES
  // ==========================================
  Future<void> _simpanAlamat() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(daftarAlamat),
    );

    if (idAlamatUtama != null) {
      await prefs.setString(
        _mainAddressKey,
        idAlamatUtama!,
      );
    } else {
      await prefs.remove(_mainAddressKey);
    }
  }

  // ==========================================
  // FORM TAMBAH DAN EDIT
  // ==========================================
  Future<void> _bukaForm({
    Map<String, dynamic>? alamatLama,
  }) async {
    final sedangEdit = alamatLama != null;

    final formKey = GlobalKey<FormState>();

    String label = alamatLama?['label']?.toString() ?? 'Rumah';

    final namaController = TextEditingController(
      text: alamatLama?['nama']?.toString() ?? '',
    );

    final teleponController = TextEditingController(
      text: alamatLama?['telepon']?.toString() ?? '',
    );

    final provinsiController = TextEditingController(
      text: alamatLama?['provinsi']?.toString() ?? '',
    );

    final kotaController = TextEditingController(
      text: alamatLama?['kota']?.toString() ?? '',
    );

    final kecamatanController = TextEditingController(
      text: alamatLama?['kecamatan']?.toString() ?? '',
    );

    final kodePosController = TextEditingController(
      text: alamatLama?['kodePos']?.toString() ?? '',
    );

    final detailController = TextEditingController(
      text: alamatLama?['detail']?.toString() ??
          alamatLama?['alamat']?.toString() ?? '',
    );

    bool jadikanUtama = sedangEdit
        ? idAlamatUtama == alamatLama['id']
        : daftarAlamat.isEmpty;

    try {
      final hasil = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  sedangEdit ? 'Edit Alamat' : 'Tambah Alamat',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: 420,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tandai sebagai',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // PILIHAN RUMAH, KANTOR, KOS
                          Row(
                            children: [
                              _pilihanLabel(
                                label: 'Rumah',
                                icon: Icons.home_outlined,
                                terpilih: label == 'Rumah',
                                onTap: () {
                                  setDialogState(() {
                                    label = 'Rumah';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              _pilihanLabel(
                                label: 'Kantor',
                                icon: Icons.work_outline,
                                terpilih: label == 'Kantor',
                                onTap: () {
                                  setDialogState(() {
                                    label = 'Kantor';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              _pilihanLabel(
                                label: 'Kos',
                                icon: Icons.apartment,
                                terpilih: label == 'Kos',
                                onTap: () {
                                  setDialogState(() {
                                    label = 'Kos';
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _judulField('Nama lengkap'),
                          _inputField(
                            controller: namaController,
                            hint: 'Nama penerima',
                            icon: Icons.person_outline,
                          ),

                          _judulField('Nomor telepon'),
                          _inputField(
                            controller: teleponController,
                            hint: '08xxxxxxxxxx',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 8),
                          const Text(
                            'Detail lokasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          _judulField('Provinsi'),
                          _inputField(
                            controller: provinsiController,
                            hint: 'Masukkan provinsi',
                            icon: Icons.map_outlined,
                          ),

                          _judulField('Kota / Kabupaten'),
                          _inputField(
                            controller: kotaController,
                            hint: 'Masukkan kota atau kabupaten',
                            icon: Icons.location_city_outlined,
                          ),

                          _judulField('Kecamatan'),
                          _inputField(
                            controller: kecamatanController,
                            hint: 'Masukkan kecamatan',
                            icon: Icons.location_on_outlined,
                          ),

                          _judulField('Kode pos'),
                          _inputField(
                            controller: kodePosController,
                            hint: 'Masukkan kode pos',
                            icon: Icons.markunread_mailbox_outlined,
                            keyboardType: TextInputType.number,
                          ),

                          _judulField('Alamat lengkap (opsional)'),
                          _inputField(
                            controller: detailController,
                            hint: 'Jalan, RT/RW, desa, nomor rumah',
                            icon: Icons.home_work_outlined,
                            maxLines: 3,
                            wajib: false,
                          ),

                          const SizedBox(height: 16),

                          // TOGGLE ALAMAT UTAMA
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F8F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Atur sebagai alamat utama',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Gunakan sebagai alamat pengiriman utama.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: jadikanUtama,
                                  activeThumbColor: primaryColor,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      jadikanUtama = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      Navigator.pop(dialogContext, {
                        'label': label,
                        'nama': namaController.text.trim(),
                        'telepon': teleponController.text.trim(),
                        'provinsi': provinsiController.text.trim(),
                        'kota': kotaController.text.trim(),
                        'kecamatan': kecamatanController.text.trim(),
                        'kodePos': kodePosController.text.trim(),
                        'detail': detailController.text.trim(),
                        'jadikanUtama': jadikanUtama,
                      });
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (hasil == null || !mounted) return;

      final String id = sedangEdit
          ? alamatLama['id'].toString()
          : DateTime.now().microsecondsSinceEpoch.toString();

      final dataAlamat = <String, dynamic>{
        'id': id,
        'label': hasil['label'],
        'nama': hasil['nama'],
        'telepon': hasil['telepon'],
        'provinsi': hasil['provinsi'],
        'kota': hasil['kota'],
        'kecamatan': hasil['kecamatan'],
        'kodePos': hasil['kodePos'],
        'detail': hasil['detail'],
      };

      setState(() {
        if (sedangEdit) {
          final index = daftarAlamat.indexWhere(
            (item) => item['id'] == id,
          );

          if (index != -1) {
            daftarAlamat[index] = dataAlamat;
          }
        } else {
          daftarAlamat.add(dataAlamat);
        }

        if (hasil['jadikanUtama'] == true) {
          idAlamatUtama = id;
        } else if (idAlamatUtama == id) {
          // Jangan biarkan alamat utama kosong jika masih ada alamat.
          idAlamatUtama = daftarAlamat
              .firstWhere(
                (item) => item['id'] != id,
                orElse: () => <String, dynamic>{},
              )['id']
              ?.toString();
        }

        if (idAlamatUtama == null && daftarAlamat.isNotEmpty) {
          idAlamatUtama = daftarAlamat.first['id'].toString();
        }
      });

      await _simpanAlamat();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sedangEdit
                ? 'Alamat berhasil diperbarui.'
                : 'Alamat berhasil ditambahkan.',
          ),
        ),
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        namaController.dispose();
        teleponController.dispose();
        provinsiController.dispose();
        kotaController.dispose();
        kecamatanController.dispose();
        kodePosController.dispose();
        detailController.dispose();
      });
    }
  }

  // ==========================================
  // WIDGET PILIHAN LABEL
  // ==========================================
  Widget _pilihanLabel({
    required String label,
    required IconData icon,
    required bool terpilih,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: terpilih
                ? const Color(0xFFE8F5EE)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: terpilih
                  ? primaryColor
                  : Colors.grey.shade300,
              width: terpilih ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: terpilih
                    ? primaryColor
                    : Colors.grey.shade600,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: terpilih
                      ? primaryColor
                      : Colors.black87,
                  fontWeight: terpilih
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET JUDUL DAN INPUT
  // ==========================================
  Widget _judulField(String judul) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        judul,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool wajib = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (wajib && (value == null || value.trim().isEmpty)) {
          return 'Bagian ini wajib diisi';
        }

        if (keyboardType == TextInputType.phone &&
            value != null &&
            value.trim().isNotEmpty &&
            value.trim().length < 8) {
          return 'Nomor telepon tidak valid';
        }

        if (keyboardType == TextInputType.number &&
            value != null &&
            value.trim().isNotEmpty &&
            !RegExp(r'^\d{5}$').hasMatch(value.trim())) {
          return 'Kode pos harus terdiri dari 5 angka';
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
      ),
    );
  }

  // ==========================================
  // HAPUS ALAMAT
  // ==========================================
  Future<void> _hapusAlamat(Map<String, dynamic> item) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Alamat'),
          content: Text(
            'Hapus alamat ${item['label']} milik ${item['nama']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true || !mounted) return;

    setState(() {
      daftarAlamat.removeWhere(
        (alamat) => alamat['id'] == item['id'],
      );

      if (idAlamatUtama == item['id']) {
        idAlamatUtama = daftarAlamat.isNotEmpty
            ? daftarAlamat.first['id'].toString()
            : null;
      }
    });

    await _simpanAlamat();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat berhasil dihapus.'),
      ),
    );
  }

  // ==========================================
  // JADIKAN ALAMAT UTAMA
  // ==========================================
  Future<void> _jadikanUtama(String id) async {
    setState(() {
      idAlamatUtama = id;
    });

    await _simpanAlamat();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat utama berhasil diubah.'),
      ),
    );
  }

  // ==========================================
  // TAMPILAN UTAMA
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alamat Saya',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade300,
            height: 1,
          ),
        ),
      ),
      body: sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _bukaForm(),
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                      ),
                      label: const Text('Tambah Alamat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: daftarAlamat.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada alamat tersimpan.',
                              ),
                              TextButton(
                                onPressed: () => _bukaForm(),
                                child: const Text(
                                  'Tambah alamat sekarang',
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16, 8, 16, 20,
                          ),
                          itemCount: daftarAlamat.length,
                          itemBuilder: (context, index) {
                            final item = daftarAlamat[index];
                            final isUtama =
                                item['id'] == idAlamatUtama;

                            final lokasi = [
                              item['detail'],
                              item['kecamatan'],
                              item['kota'],
                              item['provinsi'],
                              item['kodePos'],
                            ]
                                .where(
                                  (value) =>
                                      value != null &&
                                      value.toString().trim().isNotEmpty,
                                )
                                .join(', ');

                            IconData ikonLabel;

                            switch (item['label']) {
                              case 'Kantor':
                                ikonLabel = Icons.work_outline;
                                break;
                              case 'Kos':
                                ikonLabel = Icons.apartment;
                                break;
                              default:
                                ikonLabel = Icons.home_outlined;
                            }

                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: 14,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isUtama
                                      ? primaryColor
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isUtama
                                              ? primaryColor
                                              : const Color(0xFFE8F5EE),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isUtama
                                              ? 'Alamat Utama'
                                              : item['label'].toString(),
                                          style: TextStyle(
                                            color: isUtama
                                                ? Colors.white
                                                : primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isUtama)
                                        Icon(
                                          ikonLabel,
                                          color: primaryColor,
                                          size: 19,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text.rich(
                                    TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '${item['nama']} ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '| ${item['telepon']}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    lokasi.isEmpty
                                        ? 'Detail alamat belum diisi'
                                        : lokasi,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _bukaForm(
                                          alamatLama: item,
                                        ),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 17,
                                        ),
                                        label: const Text('Edit'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: primaryColor,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _hapusAlamat(item),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 17,
                                        ),
                                        label: const Text('Hapus'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                      if (!isUtama)
                                        TextButton(
                                          onPressed: () =>
                                              _jadikanUtama(
                                            item['id'].toString(),
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: primaryColor,
                                          ),
                                           child: const Text(
                                            'Jadikan Utama',
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
