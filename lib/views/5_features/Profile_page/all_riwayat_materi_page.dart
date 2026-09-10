import 'package:flutter/material.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/services/firestore_materi_service.dart';
import 'package:phintar/services/materi_service.dart';
import 'package:phintar/views/6_materi/dynamic_materi_page.dart';
import 'package:phintar/widgets/app_bar.dart';
import 'package:phintar/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:phintar/widgets/history_card/riwayat_materi.dart';

enum MateriSortOption { longestDuration, newest }

class AllRiwayatMateriPage extends StatefulWidget {
  const AllRiwayatMateriPage({super.key});

  @override
  State<AllRiwayatMateriPage> createState() => _AllRiwayatMateriPageState();
}

class _AllRiwayatMateriPageState extends State<AllRiwayatMateriPage> {
  late Future<List<Map<String, dynamic>>> _historiesFuture;
  bool _isLoadingMateri = false;
  MateriSortOption _selectedSort = MateriSortOption.longestDuration;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  void _loadHistories() {
    setState(() {
      _historiesFuture = FirestoreMateriService.instance.getAllHistories();
    });
  }

  void _continueMateri(int materiId, [String? materiName]) async {
    if (_isLoadingMateri) return;
    setState(() => _isLoadingMateri = true);

    try {
      final materi = await MateriService.instance.getMateriByIdOrTitle(
        materiId,
        materiName,
      );

      if (!mounted) return;

      if (materi != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DynamicMateriPage(materi: materi)),
        );
        _loadHistories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materi pembelajaran tidak ditemukan.'),
            backgroundColor: AppTheme.merah,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka materi: $e'),
            backgroundColor: AppTheme.merah,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMateri = false);
      }
    }
  }

  void _showDeleteConfirmDialog(String id, String materiName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: AppTheme.merah),
              const SizedBox(width: 10),
              Text('Hapus Riwayat', style: AppTextStyle.dialogTitle),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus riwayat "$materiName"? Data ini tidak dapat dikembalikan.',
            style: AppTextStyle.dialogText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: AppTextStyle.normalText),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.merah,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await FirestoreMateriService.instance.deleteHistory(id);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                _loadHistories();
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Riwayat berhasil dihapus'),
                      backgroundColor: AppTheme.merah,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Hapus', style: AppTextStyle.botttonText),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _sortData(List<Map<String, dynamic>> data) {
    final sorted = List<Map<String, dynamic>>.from(data);
    if (_selectedSort == MateriSortOption.longestDuration) {
      sorted.sort((a, b) {
        final durA = (a['duration_seconds'] as num?)?.toInt() ?? 0;
        final durB = (b['duration_seconds'] as num?)?.toInt() ?? 0;
        if (durB != durA) {
          return durB.compareTo(durA);
        }
        final dateA = a['created_at']?.toString() ?? '';
        final dateB = b['created_at']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });
    } else {
      sorted.sort((a, b) {
        final dateA = a['created_at']?.toString() ?? '';
        final dateB = b['created_at']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(
        title: 'Semua Riwayat Materi',
        prefixIcon: Icons.arrow_back_ios_new_rounded,
        onPrefixIconTap: () => Navigator.of(context).pop(),
      ),
      body: RefreshIndicator(
        color: AppTheme.bottonColor,
        backgroundColor: AppTheme.backgroundSecondary,
        onRefresh: () async => _loadHistories(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppTheme.bottonColor),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.merah.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.merah),
                    ),
                    child: Text(
                      'Gagal memuat riwayat: ${snapshot.error}',
                      style: AppTextStyle.warningText,
                    ),
                  ),
                ),
              );
            }

            final rawData = snapshot.data ?? [];

            if (rawData.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF334155),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 54,
                          color: AppTheme.textColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada riwayat belajar',
                          style: AppTextStyle.normalText2Bold,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mulai pelajari materi untuk melihat riwayat dan durasi belajarmu.',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.smallText,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const BottomNavBarPhintar(initialIndex: 0),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bottonColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 20,
                            color: AppTheme.putih,
                          ),
                          label: Text(
                            'Mulai Belajar Materi',
                            style: AppTextStyle.smallTextBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final data = _sortData(rawData);

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                // Filter & Sort Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total Riwayat',
                          style: AppTextStyle.cardSubtitle,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.bottonColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${data.length}',
                            style: const TextStyle(
                              color: AppTheme.bottonColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildSortChip(
                          label: 'Durasi Terlama',
                          icon: Icons.timer_outlined,
                          isSelected:
                              _selectedSort ==
                              MateriSortOption.longestDuration,
                          onTap: () {
                            setState(() {
                              _selectedSort = MateriSortOption.longestDuration;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildSortChip(
                          label: 'Terbaru',
                          icon: Icons.access_time_rounded,
                          isSelected:
                              _selectedSort == MateriSortOption.newest,
                          onTap: () {
                            setState(() {
                              _selectedSort = MateriSortOption.newest;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List Cards
                ...List.generate(data.length, (index) {
                  final item = data[index];
                  final id = item['id']?.toString() ?? '';
                  final materiId = item['materi_id'] as int;
                  final materiName = getMateriTitle(
                    materiId,
                    item['materi_name'] as String?,
                  );
                  final durationSeconds =
                      (item['duration_seconds'] as num).toInt();
                  final dateString = item['created_at'] as String;
                  final durationColor = getDurationColor(durationSeconds);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _continueMateri(materiId, materiName),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF334155),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon Bulat
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.bottonColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: AppTheme.bottonColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Informasi Materi
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      materiName,
                                      style: AppTextStyle.cardTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time_rounded,
                                          size: 13,
                                          color: AppTheme.textColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            formatMateriDate(dateString),
                                            style: AppTextStyle.cardSubtitle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Indikator Durasi
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatDuration(durationSeconds),
                                    style: TextStyle(
                                      color: durationColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    durationSeconds >= 600
                                        ? 'Rajin!'
                                        : durationSeconds >= 180
                                        ? 'Cukup'
                                        : 'Sebentar',
                                    style: TextStyle(
                                      color: durationColor.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),

                              // Popup Menu Aksi (Lanjutkan & Hapus)
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: AppTheme.textColor,
                                  size: 20,
                                ),
                                color: AppTheme.backgroundSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                onSelected: (value) {
                                  if (value == 'continue') {
                                    _continueMateri(materiId, materiName);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmDialog(id, materiName);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'continue',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.play_arrow_rounded,
                                          color: AppTheme.bottonColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Lanjutkan Materi',
                                          style: AppTextStyle.normalText2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppTheme.merah,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Hapus',
                                          style: AppTextStyle.warningText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSortChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.bottonColor.withValues(alpha: 0.2)
              : AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.bottonColor : const Color(0xFF334155),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppTheme.bottonColor : AppTheme.textColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.bottonColor : AppTheme.textColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
