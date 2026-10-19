
import 'package:flutter/material.dart';

void main() {
  runApp(const MarketplaceApp());
}

const Color hijau = Color(0xFF007A53);

class MarketplaceApp extends StatelessWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ED Management',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: hijau,
          primary: hijau,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const AlamatSayaScreen(),
    );
  }
}

class Alamat {
  String nama;
  String telepon;
  String detail;
  String label;
  bool utama;

  Alamat({
    required this.nama,
    required this.telepon,
    required this.detail,
    this.label = 'Rumah',
    this.utama = false,
  });
}

class AlamatSayaScreen extends StatefulWidget {
  const AlamatSayaScreen({super.key});

  @override
  State<AlamatSayaScreen> createState() =>
      _AlamatSayaScreenState();
}

class _AlamatSayaScreenState extends State<AlamatSayaScreen> {
  final List<Alamat> daftarAlamat = [
    Alamat(
      nama: 'Rika',
      telepon: '08888889991',
      detail:
          'Dsn Pesanggrahan RT.03 RW.03 Desa Cendono kec. Purwosari',
      label: 'Rumah',
      utama: true,
    ),
  ];

  Future<void> bukaForm({Alamat? alamat}) async {
    final hasil = await Navigator.push<Alamat>(
      context,
      MaterialPageRoute(
        builder: (_) => FormAlamatScreen(alamat: alamat),
      ),
    );

    if (!mounted || hasil == null) return;

    setState(() {
      if (alamat != null) {
        final index = daftarAlamat.indexOf(alamat);
        if (index != -1) {
          daftarAlamat[index] = hasil;
        }
      } else {
        daftarAlamat.add(hasil);
      }

      if (hasil.utama) {
        for (final item in daftarAlamat) {
          item.utama = identical(item, hasil) ||
              item.nama == hasil.nama &&
                  item.telepon == hasil.telepon &&
                  item.detail == hasil.detail;
        }
      }

      if (daftarAlamat.isNotEmpty &&
          !daftarAlamat.any((item) => item.utama)) {
        daftarAlamat.first.utama = true;
      }
    });
  }

  void jadikanUtama(Alamat alamat) {
    setState(() {
      for (final item in daftarAlamat) {
        item.utama = identical(item, alamat);
      }
    });
  }

  void hapusAlamat(Alamat alamat) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus alamat ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              setState(() {
                daftarAlamat.remove(alamat);
                if (daftarAlamat.isNotEmpty &&
                    !daftarAlamat.any((a) => a.utama)) {
                  daftarAlamat.first.utama = true;
                }
              });
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Alamat Saya',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFDDDDDD)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => bukaForm(),
                icon: const Icon(Icons.add, size: 19),
                label: const Text(
                  'Tambah Alamat',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hijau,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
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
                        const Icon(
                          Icons.location_on_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text('Belum ada alamat'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => bukaForm(),
                          child: const Text('Tambah alamat sekarang'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: daftarAlamat.length,
                    itemBuilder: (context, index) {
                      final alamat = daftarAlamat[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFDDDDDD),
                          ),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (alamat.utama)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: hijau,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  'Alamat Utama',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (alamat.utama)
                              const SizedBox(height: 10),

                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${alamat.nama} ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '| ${alamat.telepon}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              alamat.detail,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      bukaForm(alamat: alamat),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Edit'),
                                ),
                                if (!alamat.utama)
                                  TextButton(
                                    onPressed: () =>
                                        jadikanUtama(alamat),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Jadikan Alamat Utama',
                                    ),
                                  ),
                                TextButton(
                                  onPressed: () => hapusAlamat(alamat),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Hapus'),
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

class FormAlamatScreen extends StatefulWidget {
  final Alamat? alamat;

  const FormAlamatScreen({super.key, this.alamat});

  @override
  State<FormAlamatScreen> createState() =>
      _FormAlamatScreenState();
}

class _FormAlamatScreenState extends State<FormAlamatScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController namaController;
  late final TextEditingController teleponController;
  late final TextEditingController detailController;

  late String label;
  late bool utama;

  @override
  void initState() {
    super.initState();

    final alamat = widget.alamat;
    namaController = TextEditingController(text: alamat?.nama ?? '');
    teleponController =
        TextEditingController(text: alamat?.telepon ?? '');
    detailController =
        TextEditingController(text: alamat?.detail ?? '');
    label = alamat?.label ?? 'Rumah';
    utama = alamat?.utama ?? false;
  }

  @override
  void dispose() {
    namaController.dispose();
    teleponController.dispose();
    detailController.dispose();
    super.dispose();
  }

  InputDecoration dekorasi(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
    );
  }

  Widget kolomInput(
    String judul,
    String hint,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            decoration: dekorasi(hint),
            validator: validator ??
                (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$judul wajib diisi';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }

  void simpan() {
    if (!formKey.currentState!.validate()) return;

    final alamatBaru = Alamat(
      nama: namaController.text.trim(),
      telepon: teleponController.text.trim(),
      detail: detailController.text.trim(),
      label: label,
      utama: utama,
    );

    Navigator.pop(context, alamatBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.alamat == null ? 'Tambah Alamat' : 'Edit Alamat',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFDDDDDD)),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Informasi Penerima',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Label Alamat',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: label,
              decoration: dekorasi('Pilih label alamat'),
              items: ['Rumah', 'Kantor', 'Kos']
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => label = value);
              },
            ),
            const SizedBox(height: 18),

            kolomInput(
              'Nama Penerima',
              'Masukkan nama lengkap',
              namaController,
            ),

            kolomInput(
              'Nomor Telepon',
              'Contoh: 081234567890',
              teleponController,
              keyboard: TextInputType.phone,
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^[0-9+ -]{8,20}$')
                        .hasMatch(value.trim())) {
                  return 'Masukkan nomor telepon yang valid';
                }
                return null;
              },
            ),

            const Divider(height: 30),
            const Text(
              'Detail Pengiriman',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            kolomInput(
              'Alamat Lengkap',
              'Jalan, RT/RW, desa, kecamatan, kota, provinsi, kode pos',
              detailController,
              maxLines: 4,
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: hijau,
              value: utama,
              title: const Text(
                'Jadikan alamat utama',
                style: TextStyle(fontSize: 14),
              ),
              onChanged: (value) {
                setState(() => utama = value ?? false);
              },
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hijau,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Simpan Alamat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
