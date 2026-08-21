import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/database/db_materi.dart';
import 'package:blabla/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:blabla/views/6_materi/Gelombang_dan_materi/1_gelombang_dan_osilasi.dart';
import 'package:flutter/material.dart';

// Helper daftar materi yang tersedia
final Map<int, String> kAvailableMateri = {
  1: 'Gelombang dan Osilasi',
  // Tambahkan materi lainnya dengan format berikut:
  // 2: 'Nama Materi 2',
  // dst.
};

String getMateriTitle(int materiId) {
  return kAvailableMateri[materiId] ?? 'Materi Fisika #$materiId';
}

String formatMateriDate(String isoDate) {
  try {
    DateTime date = DateTime.parse(isoDate);
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} • $hour:$minute';
  } catch (_) {
    return isoDate;
  }
}

String formatDuration(int totalSeconds) {
  if (totalSeconds < 60) {
    return '$totalSeconds detik';
  } else if (totalSeconds < 3600) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return seconds > 0 ? '$minutes menit $seconds detik' : '$minutes menit';
  } else {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    return minutes > 0 ? '$hours jam $minutes menit' : '$hours jam';
  }
}

Color getDurationColor(int seconds) {
  if (seconds >= 600) return AppTheme.progressColor; // >= 10 menit (rajin)
  if (seconds >= 180) return AppTheme.kuning; // >= 3 menit (cukup)
  return AppTheme.merah; // < 3 menit (sebentar)
}

// WIDGET RIWAYAT MATERI (EMBEDDABLE PADA PROFILE PAGE)
class RiwayatMateriSection extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const RiwayatMateriSection({super.key, this.onDataChanged});

  @override
  State<RiwayatMateriSection> createState() => RiwayatMateriSectionState();
}

class RiwayatMateriSectionState extends State<RiwayatMateriSection> {
  late Future<List<Map<String, dynamic>>> _historiesFuture;

  @override
  void initState() {
    super.initState();
    refreshHistories();
  }

  void refreshHistories() {
    setState(() {
      _historiesFuture = DatabaseHelperMateri.instance.getAllHistories();
    });
    widget.onDataChanged?.call();
  }

  // ─── LANJUTKAN MATERI: Navigasi ke Halaman Materi ───
  void _continueMateri(int materiId) async {
    Widget targetMateriPage;
    switch (materiId) {
      case 1:
      default:
        targetMateriPage = const Materi1Gelombag();
        break;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => targetMateriPage));

    refreshHistories();
  }

  // ─── DELETE: Hapus Riwayat Tertentu ───
  void _showDeleteConfirmDialog(int id, String materiName) {
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
              SizedBox(width: 10),
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
                await DatabaseHelperMateri.instance.deleteHistory(id);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                refreshHistories();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historiesFuture,
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.bottonColor),
            ),
          );
        }

        // Error State
        if (snapshot.hasError) {
          return Container(
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
          );
        }

        final data = snapshot.data ?? [];

        // Header Section with Content
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar Riwayat Materi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.bottonColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text('Riwayat Materi', style: AppTextStyle.subjudul),
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
              ],
            ),
            const SizedBox(height: 8),

            // Empty State
            if (data.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155), width: 1),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const BottomNavBarPhintar(initialIndex: 0),
                          ),
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
              )
            else
              // List View of Histories
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = data[index];
                  final id = item['id'] as int;
                  final materiId = item['materi_id'] as int;
                  final materiName = item['materi_name'] as String;
                  final durationSeconds = (item['duration_seconds'] as num)
                      .toInt();
                  final dateString = item['created_at'] as String;
                  final durationColor = getDurationColor(durationSeconds);

                  return Container(
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
                            color: AppTheme.bottonColor.withValues(alpha: 0.15),
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
                                color: durationColor.withValues(alpha: 0.85),
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
                            side: const BorderSide(color: Color(0xFF334155)),
                          ),
                          onSelected: (value) {
                            if (value == 'continue') {
                              _continueMateri(materiId);
                            } else if (value == 'delete') {
                              _showDeleteConfirmDialog(id, materiName);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'continue',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppTheme.bottonColor,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Lanjutkan',
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
                                  SizedBox(width: 8),
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
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
