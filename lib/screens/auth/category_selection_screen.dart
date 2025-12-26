// file: lib/screens/auth/category_selection_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../main_navigation.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int _selectedIndex = -1;
  final List<Map<String, dynamic>> _categories = [
    {"title": "Pelajar", "subtitle": "Siswa SMP/SMA/SMK", "icon": Icons.school_outlined},
    {"title": "Mahasiswa", "subtitle": "Perguruan tinggi", "icon": Icons.account_balance_outlined},
    {"title": "Umum", "subtitle": "Masyarakat luas", "icon": Icons.work_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pilih Kategori", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: _categories.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color.fromRGBO(0, 201, 167, 0.1) : const Color(0xFF2B3039),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFF00C9A7) : Colors.grey.shade700),
                        ),
                        child: Row(
                          children: [
                            Icon(_categories[index]['icon'], color: isSelected ? const Color(0xFF00C9A7) : Colors.white, size: 30),
                            const SizedBox(width: 20),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(_categories[index]['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(_categories[index]['subtitle'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              PrimaryButton(
                text: "Lanjutkan",
                onPressed: () {
                  if (_selectedIndex != -1) {
                    // ROUTING FINAL: Masuk ke Halaman Utama dan hapus history login
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}