import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/data/database/db_quiz.dart';
import 'package:blabla/data/models/quiz_history_model.dart';
import 'package:blabla/data/models/quiz_model.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:flutter/material.dart';

/// Dynamic quiz screen — the SINGLE template for ALL quizzes.
///
/// Receives a [QuizModel] (with questions loaded) and renders the quiz
/// dynamically. Calculates score and saves to quiz history.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => QuizScreen(quiz: someQuizModel),
/// ));
/// ```
class QuizScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _finished = false;

  /// Shortcut getter — returns the list of questions from the quiz model.
  List<QuizQuestionModel> get _questions => widget.quiz.questions;

  /// Handles answer selection. Locks input after first tap and
  /// increments [_score] if the selected option is correct.
  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  /// Advances to the next question, or finishes the quiz if all
  /// questions have been answered. Saves history on completion.
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _saveQuizHistory();
      setState(() {
        _finished = true;
      });
    }
  }

  /// Persists the quiz result (score percentage) to the local SQLite
  /// database via [DatabaseHelperQuiz]. Uses upsert logic — if a
  /// history row for this quiz already exists it gets updated.
  Future<void> _saveQuizHistory() async {
    final double percentage = (_score / _questions.length * 100)
        .roundToDouble();
    await DatabaseHelperQuiz.instance.insertHistoryModel(
      QuizHistoryModel(
        quizId: widget.quiz.id,
        score: percentage,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Resets all quiz state so the user can retake the quiz from
  /// question 1 without leaving the screen.
  void _restart() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _score = 0;
      _finished = false;
    });
  }

  /// Builds the main scaffold with app bar showing the quiz title.
  /// Switches between result page and quiz page based on [_finished].
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(
        title: "Kuis: ${widget.quiz.title}",
        prefixIcon: Icons.arrow_back,
      ),
      body: _finished ? _buildResultPage() : _buildQuizPage(),
    );
  }

  // ─── Result Page ──────────────────────────────────────────────────────────

  /// Builds the result summary shown after all questions are answered.
  /// Displays a circular score badge, correct count, and retry/back buttons.
  Widget _buildResultPage() {
    final percentage = (_score / _questions.length * 100).round();
    final Color scoreColor = percentage >= 70
        ? AppTheme.progressColor
        : percentage >= 40
        ? const Color(0xFFFBBF24)
        : AppTheme.merah;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withValues(alpha: 0.15),
                border: Border.all(color: scoreColor, width: 3),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kuis Selesai!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.putih,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu menjawab benar $_score dari ${_questions.length} soal.',
              style: AppTextStyle.normalText2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildActionButton(
              label: 'Ulangi Kuis',
              icon: Icons.refresh_rounded,
              color: AppTheme.bottonColor,
              onTap: _restart,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Kembali ke Daftar Kuis',
              icon: Icons.arrow_back_rounded,
              color: AppTheme.backgroundSecondary,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable full-width elevated button with icon, used on the result page.
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, color: AppTheme.putih),
        label: Text(
          label,
          style: const TextStyle(
            color: AppTheme.putih,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ─── Quiz Page ────────────────────────────────────────────────────────────

  /// Builds the active quiz view: progress bar, topic badge, question card,
  /// answer options with correct/wrong highlighting, explanation box, and
  /// a "next" button. All content is driven by [QuizModel] data.
  Widget _buildQuizPage() {
    final question = _questions[_currentIndex];
    final total = _questions.length;
    final progress = (_currentIndex + 1) / total;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Progress Bar ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PERTANYAAN ${_currentIndex + 1} DARI $total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Skor: $_score',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.progressColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppTheme.backgroundSecondary,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.bottonColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Topic Badge ──
            if (question.topic != null && question.topic!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTranslucent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.topic!,
                  style: AppTextStyle.smallText.copyWith(
                    color: AppTheme.bottonColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (question.topic != null && question.topic!.isNotEmpty)
              const SizedBox(height: 12),

            // ── Question Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(
                question.question,
                style: AppTextStyle.normalText2.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 16),

            // ── Options ──
            ...List.generate(question.options.length, (i) {
              final isSelected = _selectedAnswer == i;
              final isCorrect = i == question.correctIndex;

              Color bgColor = AppTheme.backgroundSecondary;
              Color borderColor = AppTheme.borderColor;
              Color textColor = AppTheme.putih;

              if (_answered) {
                if (isCorrect) {
                  bgColor = AppTheme.successTranslucent;
                  borderColor = AppTheme.progressColor;
                  textColor = AppTheme.progressColor;
                } else if (isSelected && !isCorrect) {
                  bgColor = AppTheme.errorTranslucent;
                  borderColor = AppTheme.merah;
                  textColor = AppTheme.merah;
                }
              } else if (isSelected) {
                bgColor = AppTheme.primaryTranslucent;
                borderColor = AppTheme.bottonColor;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _selectAnswer(i),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _answered && isCorrect
                                ? AppTheme.progressColor
                                : _answered && isSelected && !isCorrect
                                ? AppTheme.merah
                                : AppTheme.backgroundPrimary,
                          ),
                          child: Center(
                            child: _answered && isCorrect
                                ? const Icon(
                                    Icons.check,
                                    color: AppTheme.putih,
                                    size: 16,
                                  )
                                : _answered && isSelected && !isCorrect
                                ? const Icon(
                                    Icons.close,
                                    color: AppTheme.putih,
                                    size: 16,
                                  )
                                : Text(
                                    String.fromCharCode(65 + i), // A, B, C, D
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.options[i],
                            style: AppTextStyle.normalText2.copyWith(
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // ── Explanation (shown after answering) ──
            if (_answered && question.explanation != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTranslucent,
                  borderRadius: BorderRadius.circular(10),
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
                          Icons.lightbulb_outline,
                          color: AppTheme.bottonColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pembahasan',
                          style: AppTextStyle.smallText.copyWith(
                            color: AppTheme.bottonColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: AppTextStyle.normalText2.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // ── Next Button ──
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bottonColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1
                        ? 'Pertanyaan Selanjutnya'
                        : 'Lihat Hasil',
                    style: AppTextStyle.botttonText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
