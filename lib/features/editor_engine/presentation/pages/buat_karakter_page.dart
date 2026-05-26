import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/camera_helper.dart';
import '../../../../core/utils/image_processing.dart';

class BuatKarakterPage extends StatefulWidget {
  final String submissionId;
  const BuatKarakterPage({super.key, required this.submissionId});

  @override
  State<BuatKarakterPage> createState() => _BuatKarakterPageState();
}

class _BuatKarakterPageState extends State<BuatKarakterPage> {
  File? _karakterTanpaBackground;
  bool _sedangMemproses = false;
  bool _isBlackAndWhite = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Kunci halaman ini ke Portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Kembalikan orientasi ke Landscape saat keluar dari halaman ini
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _prosesFotoKarakter() async {
    // 1. Ambil foto menggunakan CameraHelper
    final pathFoto = await CameraHelper.takePicture();
    if (pathFoto == null) return; // User membatalkan pengambilan foto

    setState(() {
      _sedangMemproses = true;
    });

    // 2. Tentukan tempat penyimpanan permanen untuk aset (Offline-first)
    // Menggunakan path_provider untuk mendapatkan direktori dokumen lokal HP
    final direktori = await getApplicationDocumentsDirectory();
    final namaFile = 'karakter_${_uuid.v4()}.png'; 
    final pathOutput = '${direktori.path}/$namaFile';

    // 3. Proses hapus background kertas (PCD Algoritma)
    final hasilPath = await ImageProcessing.removeWhiteBackground(
      pathFoto, 
      pathOutput, 
      blackAndWhite: _isBlackAndWhite,
    );

    // 4. Perbarui UI
    if (hasilPath != null) {
      setState(() {
        _karakterTanpaBackground = File(hasilPath);
        _sedangMemproses = false;
      });
    } else {
      setState(() {
        _sedangMemproses = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses gambar.')),
        );
      }
    }
  }

  void _simpanDanKembali() {
    if (_karakterTanpaBackground != null) {
      // Kembali ke halaman Editor dengan membawa path file gambar yang sudah jadi
      // (Nanti di layar Editor, path ini disave ke Hive atau object karakter)
      context.pop(_karakterTanpaBackground!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Karakter Baru'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Gambar karakter buatanmu di atas kertas putih bersih (jangan ada garis/buku tulis).\nFoto di tempat yang terang!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              
              // Kotak area Preview Hasil Foto
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _sedangMemproses
                    ? const Center(child: CircularProgressIndicator())
                    : _karakterTanpaBackground != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            // Menampilkan gambar lokal yang transparan
                            child: Image.file(_karakterTanpaBackground!, fit: BoxFit.contain),
                          )
                        : const Center(
                            child: Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                          ),
              ),
              const SizedBox(height: 32),
              
              // Tombol aksi
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(_karakterTanpaBackground == null ? 'Buka Kamera' : 'Ulangi Foto'),
                onPressed: _sedangMemproses ? null : _prosesFotoKarakter,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Opsi Filter
              SizedBox(
                width: 300,
                child: SwitchListTile(
                  title: const Text('Filter Hitam Putih'),
                  subtitle: const Text('Ubah warna coretan menjadi tinta hitam pekat', style: TextStyle(fontSize: 12)),
                  value: _isBlackAndWhite,
                  onChanged: (val) {
                    setState(() {
                      _isBlackAndWhite = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Tombol Simpan (hanya muncul jika sudah ada hasil)
              if (_karakterTanpaBackground != null)
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Gunakan Karakter Ini'),
                  onPressed: _simpanDanKembali,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
