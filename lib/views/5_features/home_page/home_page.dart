import 'package:blabla/widgets/app_banner.dart';
import 'package:blabla/widgets/app_search_bar.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/widgets/extention/navigator.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/views/6_materi/Gelombang_dan_materi/1_gelombang_dan_osilasi.dart';
import 'package:flutter/material.dart';

/// Simple data class representing a course module entry on the home page.
///
/// To add a new modul, create a new [_ModulItem] in the [_allModuls] list
/// inside [_HomePagePhintarState] with title, subtitle, and onTap callback.
// Model sederhana untuk data modul
class _ModulItem {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModulItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

/// Home page displaying available course modules.
///
/// Shows a search bar and a list of [_ModulItem] cards.
/// Each card navigates to the corresponding materi page.
/// To add a new course, simply add a new [_ModulItem] to [_allModuls].
class HomePagePhintar extends StatefulWidget {
  const HomePagePhintar({super.key, this.username});
  final String? username;

  @override
  State<HomePagePhintar> createState() => _HomePagePhintarState();
}

class _HomePagePhintarState extends State<HomePagePhintar> {
  String _searchQuery = '';

  // Daftar modul (masukan agar search bisa bekerja)
  late final List<_ModulItem> _allModuls = [
    _ModulItem(
      title: 'Gelombang dan Osilasi',
      subtitle: 'Modul Fisika Dasar',
      onTap: () {
        context.push(Materi1Gelombag());
      },
    ),
    _ModulItem(
      title: 'Vektor dan Kinematika Gerak',
      subtitle: 'Modul Fisika Dasar',
      onTap: () {},
    ),
    _ModulItem(
      title: 'Dinamika Rotasi',
      subtitle: 'Modul Fisika Dasar',
      onTap: () {},
    ),
    // Tambahkan modul lain di sini
  ];

  /// Returns the list of modules filtered by the current search query.
  /// If the query is empty, returns all modules.
  List<_ModulItem> get _filteredModuls {
    if (_searchQuery.isEmpty) return _allModuls;
    final query = _searchQuery.toLowerCase();
    return _allModuls
        .where(
          (m) =>
              m.title.toLowerCase().contains(query) ||
              m.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  /// Builds the home page: app bar with username, search bar,
  /// section header, and the filtered list of module cards.
  @override
  Widget build(BuildContext context) {
    final results = _filteredModuls;
    final displayName = widget.username ?? PreferenceHandler.userName;

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: 'Selamat datang, $displayName'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar — terhubung ke filter
              CustomSearchBar(
                hintText: 'Cari modul...',
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 16),
              Text('Materi Materi', style: AppTextStyle.subjudul),
              const Divider(color: AppTheme.textColor, thickness: 1),
              const SizedBox(height: 8),

              // Tampilkan hasil atau pesan kosong
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Modul "$_searchQuery" tidak ditemukan.',
                      style: AppTextStyle.normalText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...results.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EnterCourse(
                      title: m.title,
                      subtitle: m.subtitle,
                      onTap: m.onTap,
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
