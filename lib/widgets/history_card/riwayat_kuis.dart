import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/database/db_quiz.dart';
import 'package:blabla/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:blabla/views/features/kuis_page/daftar_quiz/kuiz_gelombang/kuiz_gelombang.dart';
import 'package:flutter/material.dart';

// Helper daftar kuis yang tersedia
final Map<int, String> kAvailableQuizzes = {
  1: 'Gelombang dan Osilasi',
  // Tambahkan kuis lainnya dengan format berikut:
  // 2: 'Nama Kuis 2',
  // dst.
};

String getQuizTitle(int quizId) {
  return kAvailableQuizzes[quizId] ?? 'Kuis Fisika #$quizId';
}

String formatQuizDate(String isoDate) {
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

Color getScoreColor(double score) {
  if (score >= 70) return AppTheme.progressColor;
  if (score >= 40) return AppTheme.kuning;
  return AppTheme.merah;
}

// ============================================================================
// WIDGET RIWAYAT KUIS (EMBEDDABLE PADA PROFILE PAGE)
// ============================================================================
class RiwayatKuisSection extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const RiwayatKuisSection({super.key, this.onDataChanged});

  @override
  State<RiwayatKuisSection> createState() => RiwayatKuisSectionState();
}

class RiwayatKuisSectionState extends State<RiwayatKuisSection> {
  late Future<List<Map<String, dynamic>>> _historiesFuture;

  @override
  void initState() {
    super.initState();
    refreshHistories();
  }

  void refreshHistories() {
    setState(() {
      _historiesFuture = DatabaseHelperQuiz.instance.getAllHistories();
    });
    widget.onDataChanged?.call();
  }

  // ─── 1. ULANGI KUIS: Navigasi ke Halaman Kuis ───
  void _retryQuiz(int quizId) async {
    Widget targetQuizPage;
    switch (quizId) {
      case 1:
      default:
        targetQuizPage = const QuizGelombangPhintar();
        break;
    }
    // tambahkan case untuk kuis lainnya
    // contoh
    // case 2:
    //   targetQuizPage = const QuizGetaranHarmonikSederhana();
    //   break;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => targetQuizPage));

    // Refresh riwayat setelah kembali dari pengerjaan kuis
    refreshHistories();
  }

  // ─── 3. DELETE: Hapus Riwayat Tertentu ───
  void _showDeleteConfirmDialog(int id, String quizName) {
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
              Text(
                'Hapus Riwayat',
                style: AppTextStyle.dialogTitle,
              ),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus riwayat "$quizName"? Data ini tidak dapat dikembalikan.',
            style: AppTextStyle.dialogText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: AppTextStyle.normalText,
              ),
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
                await DatabaseHelperQuiz.instance.deleteHistory(id);
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
              child: Text(
                'Hapus',
                style: AppTextStyle.botttonText,
              ),
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

        // Header Section with Actions
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar Riwayat Kuis
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history_edu_rounded,
                      color: AppTheme.bottonColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text('Riwayat Kuis', style: AppTextStyle.subjudul),
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
                      Icons.history_rounded,
                      size: 54,
                      color: AppTheme.textColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Anda belum mengerjakan kuis',
                      style: AppTextStyle.normalText2Bold,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mulai kerjakan kuis untuk melihat riwayat dan progres belajarmu.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.smallText,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const BottomNavBarPhintar(initialIndex: 2),
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
                        'Mulai Mengerjakan Kuis',
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
                  final score = (item['score'] as num).toDouble();
                  final quizId = item['quiz_id'] as int;
                  final dateString = item['created_at'] as String;
                  final quizName = getQuizTitle(quizId);
                  final scoreColor = getScoreColor(score);

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
                            Icons.quiz_rounded,
                            color: AppTheme.bottonColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Informasi Kuis
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quizName,
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
                                      formatQuizDate(dateString),
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
                        // Indikator Skor
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${score.round()}',
                              style: TextStyle(
                                color: scoreColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              score >= 70
                                  ? 'Lulus'
                                  : score >= 40
                                  ? 'Cukup'
                                  : 'Remedial',
                              style: TextStyle(
                                color: scoreColor.withValues(alpha: 0.85),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),

                        // Popup Menu Aksi (Ulangi Kuis & Hapus)
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
                            if (value == 'retry') {
                              _retryQuiz(quizId);
                            } else if (value == 'delete') {
                              _showDeleteConfirmDialog(id, quizName);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'retry',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.replay_rounded,
                                    color: AppTheme.bottonColor,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ulangi Kuis',
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
