import 'package:flutter/material.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/models/materi_model.dart';
import 'package:phintar/models/preference_handler.dart';
import 'package:phintar/services/materi_service.dart';
import 'package:phintar/views/6_materi/dynamic_materi_page.dart';
import 'package:phintar/widgets/app_bar.dart';
import 'package:phintar/widgets/app_banner.dart';
import 'package:phintar/widgets/app_search_bar.dart';
import 'package:phintar/widgets/extention/navigator.dart';

/// Halaman Home yang menampilkan kurikulum Fisika SMA secara real-time
/// dari Firebase Cloud Firestore, mendukung pemilihan tingkat kelas
/// (Fisika Kelas 10, Kelas 11, dan Kelas 12).
///
/// Mendukung filter kategori materi spesifik per kelas, pencarian instan,
/// dan navigasi ke halaman materi universal [DynamicMateriPage].
class HomePagePhintar extends StatefulWidget {
  const HomePagePhintar({super.key, this.username, this.initialGrade = 12});
  final String? username;
  final int initialGrade;

  @override
  State<HomePagePhintar> createState() => _HomePagePhintarState();
}

class _HomePagePhintarState extends State<HomePagePhintar> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  late int _selectedGrade;
  final MateriService _materiService = MateriService.instance;

  static const List<String> _categoriesKelas10 = [
    'Semua',
    'Pengukuran',
    'Kinematika',
    'Hukum Newton',
    'Usaha & Energi',
    'Momentum',
    'Gelombang',
  ];

  static const List<String> _categoriesKelas11 = [
    'Semua',
    'Dinamika Rotasi',
    'Elastisitas',
    'Fluida Statis',
    'Fluida Dinamis',
    'Suhu & Kalor',
    'Gas & Termo',
    'Gelombang & Bunyi',
  ];

  static const List<String> _categoriesKelas12 = [
    'Semua',
    'Listrik Dinamis',
    'Listrik Statis',
    'Kemagnetan',
    'Induksi & AC',
    'Gelombang EM',
    'Fisika Modern',
    'Fisika Inti',
  ];

  List<String> get _currentCategories {
    switch (_selectedGrade) {
      case 10:
        return _categoriesKelas10;
      case 11:
        return _categoriesKelas11;
      case 12:
      default:
        return _categoriesKelas12;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.initialGrade;
    // Memastikan seluruh modul Fisika Kelas 10, 11, & 12 terinisialisasi di Firestore
    _materiService.seedCurriculumMateri();
  }

  /// Menangani navigasi ke materi pembelajaran dinamis yang dipilih.
  void _navigateToMateri(MateriModel materi) {
    context.push(DynamicMateriPage(materi: materi));
  }

  /// Widget Segmented Control untuk memilih tingkat Kelas (Kelas 10, Kelas 11, atau Kelas 12).
  Widget _buildGradeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          _buildGradeOption(
            grade: 10,
            title: 'Kelas 10',
            icon: Icons.school_rounded,
          ),
          const SizedBox(width: 4),
          _buildGradeOption(
            grade: 11,
            title: 'Kelas 11',
            icon: Icons.science_rounded,
          ),
          const SizedBox(width: 4),
          _buildGradeOption(
            grade: 12,
            title: 'Kelas 12',
            icon: Icons.biotech_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeOption({
    required int grade,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedGrade == grade;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedGrade != grade) {
            setState(() {
              _selectedGrade = grade;
              _selectedCategory = 'Semua';
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.bottonColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.bottonColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                 : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.putih : AppTheme.textColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyle.normalText.copyWith(
                  color: isSelected ? AppTheme.putih : AppTheme.textColor,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.username ?? PreferenceHandler.userName;

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: 'Selamat datang, $displayName'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search Bar ─────────────────────────────────────────
              CustomSearchBar(
                hintText: 'Cari materi fisika...',
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 12),

              // ── Grade Selector Switcher (Kelas 10 / Kelas 11) ──────
              _buildGradeSelector(),
              const SizedBox(height: 12),

              // ── Kategori Filter Chips (Horizontal) ─────────────────
              SizedBox(
                height: 38,
                child: ListView.separated(
                  key: ValueKey('chips_$_selectedGrade'),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _currentCategories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _currentCategories[index];
                    final isSelected = category == _selectedCategory;

                    return ChoiceChip(
                      label: Text(
                        category,
                        style: AppTextStyle.smallText.copyWith(
                          color: isSelected ? AppTheme.putih : AppTheme.textColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = category);
                        }
                      },
                      selectedColor: AppTheme.bottonColor,
                      backgroundColor: AppTheme.backgroundSecondary,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.bottonColor
                            : AppTheme.borderColor,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Materi Fisika Kelas $_selectedGrade',
                    style: AppTextStyle.subjudul,
                  ),
                  Text(
                    _selectedCategory == 'Semua' ? 'Semua Topik' : _selectedCategory,
                    style: AppTextStyle.smallText.copyWith(
                      color: AppTheme.bottonColor,
                    ),
                  ),
                ],
              ),
              const Divider(color: AppTheme.borderColor, thickness: 1),
              const SizedBox(height: 8),

              // ── Stream data materi real-time dari Cloud Firestore ──
              StreamBuilder<List<MateriModel>>(
                stream: _materiService.getMateriStream(),
                builder: (context, snapshot) {
                  // State saat data masih dimuat
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.bottonColor,
                        ),
                      ),
                    );
                  }

                  // State saat terjadi error
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.merah,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gagal memuat materi pembelajaran.',
                              style: AppTextStyle.normalText,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${snapshot.error}',
                              style: AppTextStyle.normalText.copyWith(
                                fontSize: 12,
                                color: AppTheme.merah,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final allMateri = snapshot.data ?? [];

                  // 1. Filter Tingkat Kelas (Grade 10 atau Kelas 11)
                  final gradeFiltered = allMateri.where((m) {
                    return m.grade == _selectedGrade;
                  }).toList();

                  // 2. Filter Kategori
                  final categoryFiltered = (_selectedCategory == 'Semua')
                      ? gradeFiltered
                      : gradeFiltered.where((m) {
                          return m.category
                              .toLowerCase()
                              .contains(_selectedCategory.toLowerCase());
                        }).toList();

                  // 3. Filter Pencarian Teks
                  final query = _searchQuery.trim().toLowerCase();
                  final finalMateriList = categoryFiltered.where((m) {
                    if (query.isEmpty) return true;
                    return m.title.toLowerCase().contains(query) ||
                        m.category.toLowerCase().contains(query) ||
                        (m.description?.toLowerCase().contains(query) ?? false);
                  }).toList();

                  // State saat tidak ada materi ditemukan
                  if (finalMateriList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Belum ada materi untuk kategori "$_selectedCategory" (Kelas $_selectedGrade).'
                              : 'Materi "$_searchQuery" tidak ditemukan di Kelas $_selectedGrade.',
                          style: AppTextStyle.normalText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Daftar kartu materi dengan Material Design 3
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: finalMateriList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final materi = finalMateriList[index];
                      final subtitleText = (materi.description != null &&
                              materi.description!.isNotEmpty)
                          ? materi.description!
                          : (materi.category.isNotEmpty
                              ? materi.category
                              : 'Modul Pembelajaran Fisika SMA Kelas ${materi.grade}');

                      return EnterCourse(
                        title: materi.title,
                        subtitle: subtitleText,
                        onTap: () => _navigateToMateri(materi),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
