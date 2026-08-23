import 'package:blabla/widgets/app_banner.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/views/features/kuis_page/daftar_quiz/kuiz_gelombang/kuiz_gelombang.dart';
import 'package:blabla/widgets/app_search_bar.dart';
import 'package:flutter/material.dart';

// Model sederhana untuk data kuis
class _KuisItem {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _KuisItem({required this.title, required this.subtitle, required this.onTap});
}

class QuizPagePhintar extends StatefulWidget {
  const QuizPagePhintar({super.key});

  @override
  State<QuizPagePhintar> createState() => _QuizPagePhintarState();
}

class _QuizPagePhintarState extends State<QuizPagePhintar> {
  String _searchQuery = '';

  // Daftar semua kuis
  late final List<_KuisItem> _allKuis = [
    _KuisItem(
      title: 'Gelombang dan Osilasi',
      subtitle: '15 Soal | 20 Menit',
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => QuizGelombangPhintar()));
      },
    ),
    // Tambahkan kuis lain di sini
  ];

  // Hasil filter berdasarkan query
  List<_KuisItem> get _filteredKuis {
    if (_searchQuery.isEmpty) return _allKuis;
    final query = _searchQuery.toLowerCase();
    return _allKuis
        .where(
          (k) =>
              k.title.toLowerCase().contains(query) ||
              k.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredKuis;

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Kuis"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Daftar Kuis", style: AppTextStyle.subjudul),
              const SizedBox(height: 10),
              Text(
                "Uji pemahamanmu tentang materi yang telah kamu pelajari!",
                style: AppTextStyle.normalText2,
              ),
              const SizedBox(height: 15),

              // Search Bar — terhubung ke filter
              CustomSearchBar(
                hintText: 'Cari kuis...',
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
                      'Kuis "$_searchQuery" tidak ditemukan.',
                      style: AppTextStyle.normalText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...results.map(
                  (k) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EnterCourse(
                      title: k.title,
                      subtitle: k.subtitle,
                      onTap: k.onTap,
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
