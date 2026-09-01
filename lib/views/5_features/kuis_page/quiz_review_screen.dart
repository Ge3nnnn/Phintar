import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/data/models/quiz_model.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ReviewFilter { all, correct, wrong }

/// Screen that displays a comprehensive review of all questions,
/// user answers, correct answers, and detailed physics explanations.
class QuizReviewScreen extends StatefulWidget {
  final QuizModel quiz;
  final Map<int, int> userAnswers;
  final VoidCallback? onRetry;

  const QuizReviewScreen({
    super.key,
    required this.quiz,
    required this.userAnswers,
    this.onRetry,
  });

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  ReviewFilter _selectedFilter = ReviewFilter.all;

  List<QuizQuestionModel> get _questions => widget.quiz.questions;

  int get _correctCount {
    int count = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (widget.userAnswers[i] == _questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  int get _wrongCount => _questions.length - _correctCount;

  double get _percentage =>
      _questions.isEmpty ? 0 : (_correctCount / _questions.length) * 100;

  Color get _scoreColor {
    if (_percentage >= 70) return AppTheme.progressColor;
    if (_percentage >= 40) return AppTheme.kuning;
    return AppTheme.merah;
  }

  String get _statusLabel {
    if (_percentage >= 85) return 'Sangat Baik!';
    if (_percentage >= 70) return 'Lulus!';
    if (_percentage >= 40) return 'Cukup (Perlu Latihan)';
    return 'Remedial';
  }

  List<MapEntry<int, QuizQuestionModel>> get _filteredQuestions {
    final list = _questions.asMap().entries.toList();
    switch (_selectedFilter) {
      case ReviewFilter.all:
        return list;
      case ReviewFilter.correct:
        return list
            .where(
              (entry) =>
                  widget.userAnswers[entry.key] == entry.value.correctIndex,
            )
            .toList();
      case ReviewFilter.wrong:
        return list
            .where(
              (entry) =>
                  widget.userAnswers[entry.key] != entry.value.correctIndex,
            )
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(
        title: 'Pembahasan: ${widget.quiz.title}',
        prefixIcon: Icons.arrow_back,
        onPrefixIconTap: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Score Summary Header ───
            _buildScoreSummaryCard(),
            const SizedBox(height: 20),

            // ─── 2. Filter Bar (Semua / Benar / Salah) ───
            _buildFilterBar(),
            const SizedBox(height: 16),

            // ─── 3. List of Question Review Cards ───
            if (_filteredQuestions.isEmpty)
              _buildEmptyFilterState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredQuestions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final entry = _filteredQuestions[index];
                  return _buildQuestionCard(
                    originalIndex: entry.key,
                    question: entry.value,
                  );
                },
              ),

            const SizedBox(height: 24),

            // ─── 4. Bottom Action Buttons ───
            _buildBottomButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Score Summary Card ───────────────────────────────────────────────────
  Widget _buildScoreSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Score Badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _scoreColor.withValues(alpha: 0.15),
                  border: Border.all(color: _scoreColor, width: 3),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_percentage.round()}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Title & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _scoreColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _scoreColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Evaluasi Hasil Kuis',
                      style: AppTextStyle.subsubjudul,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Periksa jawabanmu dan pahami pembahasannya di bawah.',
                      style: AppTextStyle.smallText,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.borderColor, height: 1),
          const SizedBox(height: 14),

          // Stats Counter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Total Soal',
                value: '${_questions.length}',
                color: AppTheme.textLight,
                icon: Icons.format_list_numbered_rounded,
              ),
              Container(width: 1, height: 32, color: AppTheme.borderColor),
              _buildStatItem(
                label: 'Benar',
                value: '$_correctCount',
                color: AppTheme.progressColor,
                icon: Icons.check_circle_rounded,
              ),
              Container(width: 1, height: 32, color: AppTheme.borderColor),
              _buildStatItem(
                label: 'Salah',
                value: '$_wrongCount',
                color: AppTheme.merah,
                icon: Icons.cancel_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textColor),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Filter Bar ───────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Row(
      children: [
        _buildFilterChip(
          title: 'Semua Soal',
          count: _questions.length,
          filter: ReviewFilter.all,
          color: AppTheme.bottonColor,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          title: 'Benar',
          count: _correctCount,
          filter: ReviewFilter.correct,
          color: AppTheme.progressColor,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          title: 'Salah',
          count: _wrongCount,
          filter: ReviewFilter.wrong,
          color: AppTheme.merah,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String title,
    required int count,
    required ReviewFilter filter,
    required Color color,
  }) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppTheme.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppTheme.borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Question Card ────────────────────────────────────────────────────────
  Widget _buildQuestionCard({
    required int originalIndex,
    required QuizQuestionModel question,
  }) {
    final userChoice = widget.userAnswers[originalIndex];
    final isAnswered = userChoice != null;
    final isCorrect = isAnswered && userChoice == question.correctIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect
              ? AppTheme.progressColor.withValues(alpha: 0.4)
              : AppTheme.merah.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Soal # + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundPrimary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Text(
                      'Soal ${originalIndex + 1}',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (question.topic != null && question.topic!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTranslucent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        question.topic!,
                        style: const TextStyle(
                          color: AppTheme.bottonColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Status Badge (Benar / Salah)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppTheme.progressColor.withValues(alpha: 0.15)
                      : AppTheme.merah.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? AppTheme.progressColor : AppTheme.merah,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_outline_rounded
                          : Icons.highlight_off_rounded,
                      size: 14,
                      color: isCorrect
                          ? AppTheme.progressColor
                          : AppTheme.merah,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect ? 'Benar' : 'Salah',
                      style: TextStyle(
                        color: isCorrect
                            ? AppTheme.progressColor
                            : AppTheme.merah,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Question Text
          Text(
            question.question,
            style: AppTextStyle.normalText2Bold.copyWith(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Options List
          ...List.generate(question.options.length, (optIndex) {
            final optionText = question.options[optIndex];
            final isThisCorrect = optIndex == question.correctIndex;
            final isThisUserChoice = userChoice == optIndex;

            Color bgColor = AppTheme.backgroundPrimary;
            Color borderColor = AppTheme.borderColor;
            Color circleColor = AppTheme.backgroundSecondary;
            Widget? statusBadge;
            Widget iconOrLetter;

            if (isThisCorrect) {
              // Jawaban Benar (Kunci Jawaban)
              bgColor = AppTheme.progressColor.withValues(alpha: 0.12);
              borderColor = AppTheme.progressColor;
              circleColor = AppTheme.progressColor;
              iconOrLetter = const Icon(
                Icons.check,
                color: AppTheme.putih,
                size: 16,
              );

              statusBadge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.progressColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isThisUserChoice
                      ? '✓ Jawaban Kamu (Benar)'
                      : '✓ Kunci Jawaban',
                  style: const TextStyle(
                    color: AppTheme.progressColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } else if (isThisUserChoice) {
              // Jawaban Salah yang Dipilih User
              bgColor = AppTheme.merah.withValues(alpha: 0.12);
              borderColor = AppTheme.merah;
              circleColor = AppTheme.merah;
              iconOrLetter = const Icon(
                Icons.close,
                color: AppTheme.putih,
                size: 16,
              );

              statusBadge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.merah.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '✗ Jawaban Kamu',
                  style: TextStyle(
                    color: AppTheme.merah,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } else {
              // Opsi Netral Lainnya
              iconOrLetter = Text(
                String.fromCharCode(65 + optIndex),
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circle letter or icon
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                      ),
                      child: Center(child: iconOrLetter),
                    ),
                    const SizedBox(width: 12),

                    // Option Text
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          color: isThisCorrect || isThisUserChoice
                              ? AppTheme.textLight
                              : AppTheme.textColor,
                          fontSize: 14,
                          fontWeight: isThisCorrect || isThisUserChoice
                              ? FontWeight.w600
                              : FontWeight.normal,
                          height: 1.4,
                        ),
                      ),
                    ),

                    if (statusBadge != null) ...[
                      const SizedBox(width: 8),
                      statusBadge,
                    ],
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 10),

          // ─── Explanation Section ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bottonColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.bottonColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: AppTheme.bottonColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pembahasan & Konsep',
                      style: GoogleFonts.outfit(
                        color: AppTheme.bottonColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  (question.explanation != null &&
                          question.explanation!.trim().isNotEmpty)
                      ? question.explanation!
                      : 'Kunci jawaban yang tepat adalah opsi ${String.fromCharCode(65 + question.correctIndex)}.',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textLight,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State for Filter ───────────────────────────────────────────────
  Widget _buildEmptyFilterState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            _selectedFilter == ReviewFilter.correct
                ? Icons.sentiment_dissatisfied_rounded
                : Icons.emoji_events_rounded,
            size: 48,
            color: AppTheme.bottonColor,
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == ReviewFilter.correct
                ? 'Belum ada jawaban benar'
                : 'Hebat! Tidak ada jawaban yang salah 🎉',
            style: AppTextStyle.normalText2Bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _selectedFilter == ReviewFilter.correct
                ? 'Kamu belum menjawab soal dengan benar pada kuis ini.'
                : 'Kamu berhasil menjawab semua pertanyaan dengan benar.',
            style: AppTextStyle.smallText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Bottom Actions ───────────────────────────────────────────────────────
  Widget _buildBottomButtons() {
    return Column(
      children: [
        if (widget.onRetry != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.bottonColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppTheme.putih,
                size: 20,
              ),
              label: Text('Ulangi Kuis', style: AppTextStyle.botttonText),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.borderColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textColor,
              size: 20,
            ),
            label: Text('Kembali', style: AppTextStyle.normalTextBold),
          ),
        ),
      ],
    );
  }
}
