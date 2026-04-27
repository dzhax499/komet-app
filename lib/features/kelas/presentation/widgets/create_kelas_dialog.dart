import 'dart:ui';
import 'package:flutter/material.dart';

class CreateKelasDialog extends StatefulWidget {
  final Function(String nama) onCreated;

  const CreateKelasDialog({super.key, required this.onCreated});

  @override
  State<CreateKelasDialog> createState() => _CreateKelasDialogState();
}

class _CreateKelasDialogState extends State<CreateKelasDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Class',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Input field - Diubah jadi Kapsul Transparan (Sesuai Gambar 2)
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent, // Ubah jadi transparan
                  borderRadius: BorderRadius.circular(50), // Ubah jadi bulat penuh (kapsul)
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Nama Kelas (misal: Kelas 5A)',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.book, color: Colors.white, size: 20),
                    border: InputBorder.none,
                    // Tambah padding horizontal biar teks ga nabrak lengkungan
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Create Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8F6F8),
                      Color(0xFF90BAC8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_controller.text.isNotEmpty) {
                        // Panggil fungsi onCreated yang di-passing dari parent
                        widget.onCreated(_controller.text);
                        Navigator.pop(context); // Tutup dialog
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}