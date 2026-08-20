import 'package:blabla/widgets/app_banner.dart';
import 'package:blabla/widgets/app_textfield.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/extention/navigator.dart';
import 'package:blabla/views/features/home_page/home_page.dart';
import 'package:blabla/views/features/lab_page/labo/labo_bandul_matematis.dart';
import 'package:blabla/views/features/lab_page/labo/labo_konstanta_pegas.dart';
import 'package:flutter/material.dart';

// Model sederhana untuk data laboratorium
class _LabItem {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _LabItem({required this.title, required this.subtitle, required this.onTap});
}

class LabPagePhintar extends StatefulWidget {
  const LabPagePhintar({super.key});

  @override
  State<LabPagePhintar> createState() => _LabPagePhintaarState();
}

class _LabPagePhintaarState extends State<LabPagePhintar> {
  String _searchQuery = '';

  // Daftar semua laboratorium
  late final List<_LabItem> _allLabs = [
    _LabItem(
      title: 'Bandul Matematis',
      subtitle: 'Visualisasi Gerak Harmonik\nSederhana',
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const LaboOsilasi()));
      },
    ),
    _LabItem(
      title: 'Konstanta Pegas',
      subtitle: 'Visualisasi Hukum Hooke',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LaboKonstantaPegas()),
        );
      },
    ),
    // Tambahkan lab lain di sini
  ];

  // Hasil filter berdasarkan query
  List<_LabItem> get _filteredLabs {
    if (_searchQuery.isEmpty) return _allLabs;
    final query = _searchQuery.toLowerCase();
    return _allLabs
        .where(
          (l) =>
              l.title.toLowerCase().contains(query) ||
              l.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredLabs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Laboratorium"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Daftar Laboratorium", style: AppTextStyle.subjudul),
              const SizedBox(height: 10),
              // Search Bar — terhubung ke filter
              CustomSearchBar(
                hintText: 'Cari laboratorium...',
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 20),
              // Tampilkan hasil atau pesan kosong
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Laboratorium "$_searchQuery" tidak ditemukan.',
                      style: AppTextStyle.normalText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...results.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EnterCourse(
                      title: l.title,
                      subtitle: l.subtitle,
                      onTap: l.onTap,
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
