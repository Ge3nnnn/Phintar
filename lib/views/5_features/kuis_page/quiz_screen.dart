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
/// Features:
/// - Scrollable question-number navigation bar (click to jump)
/// - "Jawab" (Answer) and "Ragu-Ragu" (Unsure) action buttons
/// - Color-coded question numbers:
///   • Default background — unattempted
///   • Green — answered
///   • Yellow — marked as unsure
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

/// Possible status for each question in the quiz.
enum QuestionStatus { unattempted, answered, unsure }

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _finished = false;
  bool _isReviewMode = false;

  /// Tracks the status of every question (unattempted / answered / unsure).
  late List<QuestionStatus> _questionStatus;

  /// Stores the selected answer index per question so users can navigate
  /// back and see what they picked.
  late Map<int, int> _savedAnswers;

  /// ScrollController for the question-number navigation bar so we can
  /// auto-scroll the active number into view.
  final ScrollController _numberScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _questionStatus = List.filled(
      widget.quiz.questions.length,
      QuestionStatus.unattempted,
    );
    _savedAnswers = {};
  }

  @override
  void dispose() {
    _numberScrollController.dispose();
    super.dispose();
  }

  /// Shortcut getter — returns the list of questions from the quiz model.
  List<QuizQuestionModel> get _questions => widget.quiz.questions;

  /// Dynamically calculates the score based on saved answers.
  int get _score {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_savedAnswers.containsKey(i) &&
          _savedAnswers[i] == _questions[i].correctIndex) {
        score++;
      }
    }
    return score;
  }

  // ─── Navigation ─────────────────────────────────────────────────────────

  /// Navigates directly to question at [index]. Restores saved answer state
  /// if the question was previously attempted.
  void _goToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;
    setState(() {
      _currentIndex = index;
      if (_savedAnswers.containsKey(index)) {
        _selectedAnswer = _savedAnswers[index];
        _answered = true;
      } else {
        _selectedAnswer = null;
        _answered = false;
      }
    });
    _scrollToNumber(index);
  }

  /// Scrolls the question-number navigation bar so that [index] is visible.
  void _scrollToNumber(int index) {
    // Each number circle is 36 wide + 8 margin = 44 effective width.
    const double itemWidth = 44;
    final double targetOffset =
        (index * itemWidth) -
        (MediaQuery.of(context).size.width / 2) +
        (itemWidth / 2);
    _numberScrollController.animateTo(
      targetOffset.clamp(0, _numberScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ─── Answer Logic ───────────────────────────────────────────────────────

  /// Handles answer selection. During active quiz, allows changing answers
  /// before proceeding.
  void _selectAnswer(int index) {
    if (_isReviewMode) return;
    setState(() {
      _selectedAnswer = index;
      _answered = false; // Reset so user must confirm new answer
    });
  }

  /// Confirms the current selection as a definitive answer.
  /// Marks the question as answered and locks it in.
  void _confirmAnswer() {
    if (_selectedAnswer == null || _answered) return;
    setState(() {
      _answered = true;
      _savedAnswers[_currentIndex] = _selectedAnswer!;
      _questionStatus[_currentIndex] = QuestionStatus.answered;
    });
  }

  /// Marks the current question as "unsure" — saves the selection but
  /// flags it yellow in the navigation bar.
  void _markUnsure() {
    if (_selectedAnswer == null || _answered) return;
    setState(() {
      _answered = true;
      _savedAnswers[_currentIndex] = _selectedAnswer!;
      _questionStatus[_currentIndex] = QuestionStatus.unsure;
    });
  }

  /// Advances to the next question, or finishes the quiz if all
  /// questions have been answered. Saves history on completion.
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _goToQuestion(_currentIndex + 1);
    } else {
      // Validate before finishing
      bool allAnswered = true;
      bool anyUnsure = false;
      int firstUnansweredOrUnsureIndex = -1;

      for (int i = 0; i < _questions.length; i++) {
        if (!_savedAnswers.containsKey(i)) {
          allAnswered = false;
          if (firstUnansweredOrUnsureIndex == -1) firstUnansweredOrUnsureIndex = i;
        } else if (_questionStatus[i] == QuestionStatus.unsure) {
          anyUnsure = true;
          if (firstUnansweredOrUnsureIndex == -1) firstUnansweredOrUnsureIndex = i;
        }
      }

      if (!allAnswered || anyUnsure) {
        String message = !allAnswered 
            ? 'Harap jawab semua pertanyaan terlebih dahulu!' 
            : 'Masih ada pertanyaan yang ditandai ragu-ragu!';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(color: AppTheme.putih, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTheme.merah,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        if (firstUnansweredOrUnsureIndex != -1) {
          _goToQuestion(firstUnansweredOrUnsureIndex);
        }
        return;
      }

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
      _isReviewMode = false;
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _finished = false;
      _questionStatus = List.filled(
        _questions.length,
        QuestionStatus.unattempted,
      );
      _savedAnswers = {};
    });
  }

  // ─── Build ──────────────────────────────────────────────────────────────

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
              label: 'Lihat Pembahasan',
              icon: Icons.menu_book_rounded,
              color: AppTheme.progressColor,
              onTap: () {
                setState(() {
                  _isReviewMode = true;
                  _finished = false;
                  _currentIndex = 0;
                  if (_savedAnswers.containsKey(0)) {
                    _selectedAnswer = _savedAnswers[0];
                    _answered = true;
                  } else {
                    _selectedAnswer = null;
                    _answered = false;
                  }
                  _scrollToNumber(0);
                });
              },
            ),
            const SizedBox(height: 12),
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

  /// Builds the active quiz view: question-number navigation bar, topic
  /// badge, question card, answer options with correct/wrong highlighting,
  /// explanation box, and "Jawab" / "Ragu-Ragu" action buttons.
  Widget _buildQuizPage() {
    final question = _questions[_currentIndex];
    final total = _questions.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
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
                if (_isReviewMode)
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
            const SizedBox(height: 10),

            // ── Question Number Navigation Bar ──
            _buildQuestionNumberBar(total),
            const SizedBox(height: 16),

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

              if (_isReviewMode) {
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
                            color: _isReviewMode && isCorrect
                                ? AppTheme.progressColor
                                : _isReviewMode && isSelected && !isCorrect
                                ? AppTheme.merah
                                : AppTheme.backgroundPrimary,
                          ),
                          child: Center(
                            child: _isReviewMode && isCorrect
                                ? const Icon(
                                    Icons.check,
                                    color: AppTheme.putih,
                                    size: 16,
                                  )
                                : _isReviewMode && isSelected && !isCorrect
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
            if (_isReviewMode && question.explanation != null)
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

            // ── Answer / Unsure / Next Buttons ──
            if (!_answered && _selectedAnswer != null && !_isReviewMode)
              _buildAnswerUnsureButtons(),
            if (_isReviewMode)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _questions.length - 1) {
                      _goToQuestion(_currentIndex + 1);
                    } else {
                      setState(() {
                        _finished = true; // Go back to result page
                      });
                    }
                  },
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
                        : 'Selesai Review',
                    style: AppTextStyle.botttonText,
                  ),
                ),
              )
            else if (_answered)
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

  // ─── Question Number Navigation Bar ───────────────────────────────────────

  /// Builds a horizontally scrollable row of numbered circles.
  /// Each circle is color-coded by [QuestionStatus] (or correctness if in review mode).
  Widget _buildQuestionNumberBar(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: SingleChildScrollView(
        controller: _numberScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: List.generate(total, (i) {
            final isCurrent = i == _currentIndex;
            final status = _questionStatus[i];

            // Determine circle background color based on status and mode.
            Color circleBg = AppTheme.backgroundPrimary;

            if (_isReviewMode) {
              if (_savedAnswers.containsKey(i)) {
                final isCorrect =
                    _savedAnswers[i] == _questions[i].correctIndex;
                circleBg = isCorrect ? AppTheme.progressColor : AppTheme.merah;
              }
            } else {
              switch (status) {
                case QuestionStatus.answered:
                  circleBg = AppTheme.bottonColor; // blue
                  break;
                case QuestionStatus.unsure:
                  circleBg = AppTheme.kuning; // yellow
                  break;
                case QuestionStatus.unattempted:
                  circleBg = AppTheme.backgroundPrimary; // default
                  break;
              }
            }

            // Text color: white on colored backgrounds, textColor on default.
            final Color numTextColor = circleBg == AppTheme.backgroundPrimary
                ? (isCurrent ? AppTheme.putih : AppTheme.textColor)
                : AppTheme.putih;

            return GestureDetector(
              onTap: () => _goToQuestion(i),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent
                        ? AppTheme.bottonColor
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppTheme.bottonColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: numTextColor,
                      fontSize: 13,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Answer / Unsure Buttons ──────────────────────────────────────────────

  /// Builds the row containing "Jawab" (Answer) and "Ragu-Ragu" (Unsure)
  /// buttons. Only shown when an option is selected but not yet confirmed.
  Widget _buildAnswerUnsureButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // ── Jawab (Answer) Button ──
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _confirmAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.progressColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.check_circle_outline,
                color: AppTheme.putih,
                size: 20,
              ),
              label: const Text(
                'Jawab',
                style: TextStyle(
                  color: AppTheme.putih,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Ragu-Ragu (Unsure) Button ──
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _markUnsure,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kuning,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.help_outline,
                color: AppTheme.putih,
                size: 20,
              ),
              label: const Text(
                'Ragu-Ragu',
                style: TextStyle(
                  color: AppTheme.putih,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
