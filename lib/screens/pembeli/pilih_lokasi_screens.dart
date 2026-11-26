import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PilihLokasiScreen extends StatefulWidget {
  const PilihLokasiScreen({super.key});

  @override
  State<PilihLokasiScreen> createState() => _PilihLokasiScreenState();
}

class _PilihLokasiScreenState extends State<PilihLokasiScreen> {
  static const Color primaryColor = Color(0xFF006B42);

  final SupabaseClient _supabase = Supabase.instance.client;
  final MapController _mapController = MapController();

  // Posisi awal peta hanya sebagai titik awal tampilan,
  // bukan lokasi GPS pengguna.
  LatLng _titikTerpilih = const LatLng(-7.5, 112.5);

  bool _isLoading = true;
  bool _isSaving = false;
  bool _sudahMemilihTitik = false;

  @override
  void initState() {
    super.initState();
    _muatLokasi();
  }

  Future<void> _muatLokasi() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final profile = await _supabase
          .from('profiles')
          .select('latitude, longitude')
          .eq('id', user.id)
          .maybeSingle();

      final lat = profile?['latitude'];
      final lng = profile?['longitude'];

      if (lat != null && lng != null) {
        _titikTerpilih = LatLng(
          (lat as num).toDouble(),
          (lng as num).toDouble(),
        );
        _sudahMemilihTitik = true;
      }
    } catch (e) {
      debugPrint('Gagal memuat lokasi: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _simpanLokasi() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    if (!_sudahMemilihTitik) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ketuk peta untuk memilih titik lokasi.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _supabase
          .from('profiles')
          .update({
            'latitude': _titikTerpilih.latitude,
            'longitude': _titikTerpilih.longitude,
          })
          .eq('id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titik lokasi berhasil disimpan.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Gagal menyimpan lokasi: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan lokasi: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Titik Lokasi'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Geser peta, lalu ketuk lokasi rumah atau toko '
                    'yang tepat. Penanda merah menunjukkan titik pilihan.',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _titikTerpilih,
                      initialZoom: _sudahMemilihTitik ? 16 : 9,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _titikTerpilih = point;
                          _sudahMemilihTitik = true;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.edmanagement.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _titikTerpilih,
                            width: 50,
                            height: 55,
                            child: const Icon(
                              Icons.location_pin,
                              size: 48,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Koordinat lokasi',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Latitude: ${_titikTerpilih.latitude.toStringAsFixed(6)}\n'
                        'Longitude: ${_titikTerpilih.longitude.toStringAsFixed(6)}',
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _simpanLokasi,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(
                            _isSaving ? 'Menyimpan...' : 'Simpan Titik Lokasi',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}