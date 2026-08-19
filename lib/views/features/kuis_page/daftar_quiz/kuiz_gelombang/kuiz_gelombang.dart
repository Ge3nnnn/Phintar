import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/constants/appbar.dart';
import 'package:blabla/database/db_quiz.dart';
import 'package:flutter/material.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _QuizQuestion {
  final String topic;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _QuizQuestion({
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

// ─── Data soal ────────────────────────────────────────────────────────────────

const List<_QuizQuestion> _questions = [
  // 1
  _QuizQuestion(
    topic: 'Osilasi',
    question:
        'Sebuah benda berosilasi harmonik sederhana dengan persamaan simpangan x = 5 sin(2πt) cm. Berapakah amplitudo dan frekuensi getaran tersebut?',
    options: [
      'A = 5 cm, f = 1 Hz',
      'A = 5 cm, f = 2 Hz',
      'A = 10 cm, f = 1 Hz',
      'A = 2 cm, f = 5 Hz',
    ],
    correctIndex: 0,
    explanation:
        'Dari persamaan x = A sin(ωt), didapat A = 5 cm. Karena ω = 2πf = 2π, maka f = 1 Hz.',
  ),
  // 2
  _QuizQuestion(
    topic: 'Osilasi',
    question:
        'Sebuah pegas dengan konstanta k = 400 N/m digantungi massa m = 1 kg. Berapakah periode osilasi sistem tersebut?',
    options: ['T = π/20 s', 'T = π/10 s', 'T = 0,2 s', 'T = 2π s'],
    correctIndex: 1,
    explanation:
        'Periode pegas: T = 2π√(m/k) = 2π√(1/400) = 2π/20 = π/10 ≈ 0,314 s.',
  ),
  // 3
  _QuizQuestion(
    topic: 'Osilasi',
    question:
        'Pada gerak harmonik sederhana, pada posisi manakah kecepatan benda mencapai nilai maksimum?',
    options: [
      'Pada titik amplitudo (ujung simpangan)',
      'Pada titik setimbang (x = 0)',
      'Pada setengah amplitudo',
      'Kecepatan selalu konstan',
    ],
    correctIndex: 1,
    explanation:
        'Kecepatan maksimum terjadi saat benda melewati titik keseimbangan (x = 0) karena seluruh energi potensial telah berubah menjadi energi kinetik.',
  ),
  // 4
  _QuizQuestion(
    topic: 'Gelombang Mekanik',
    question:
        'Gelombang transversal merambat pada tali dengan kecepatan 20 m/s dan frekuensi 5 Hz. Berapakah panjang gelombangnya?',
    options: ['2 m', '4 m', '100 m', '0,25 m'],
    correctIndex: 1,
    explanation:
        'λ = v/f = 20/5 = 4 m. Hubungan kecepatan, frekuensi, dan panjang gelombang: v = f × λ.',
  ),
  // 5
  _QuizQuestion(
    topic: 'Gelombang Mekanik',
    question:
        'Apa perbedaan utama antara gelombang transversal dan gelombang longitudinal?',
    options: [
      'Transversal merambat lebih cepat dari longitudinal',
      'Arah getar transversal tegak lurus arah rambat; longitudinal sejajar arah rambat',
      'Longitudinal hanya ada di udara, transversal hanya di zat padat',
      'Keduanya tidak memiliki perbedaan yang signifikan',
    ],
    correctIndex: 1,
    explanation:
        'Gelombang transversal: arah getaran ⊥ arah rambat (contoh: cahaya, gelombang tali). Gelombang longitudinal: arah getaran ∥ arah rambat (contoh: suara, gelombang pegas).',
  ),
  // 6
  _QuizQuestion(
    topic: 'Interferensi',
    question:
        'Dua gelombang cahaya koheren berinterferensi. Jika beda fase antara kedua gelombang tersebut adalah π radian, apa yang akan terjadi pada titik pertemuan mereka?',
    options: [
      'Terjadi interferensi konstruktif maksimal, menghasilkan terang maksimum.',
      'Terjadi interferensi destruktif maksimal, menghasilkan gelap gulita.',
      'Terbentuk pola difraksi dengan cincin-cincin konsentris.',
      'Amplitudo gelombang gabungan menjadi dua kali lipat amplitudo masing-masing gelombang.',
    ],
    correctIndex: 1,
    explanation:
        'Beda fase π radian (180°) berarti puncak gelombang pertama bertemu lembah gelombang kedua, sehingga terjadi pembatalan amplitudo — interferensi destruktif — menghasilkan area gelap.',
  ),
  // 7
  _QuizQuestion(
    topic: 'Interferensi',
    question:
        'Pada percobaan Young (celah ganda), apa yang terjadi jika jarak antar celah diperkecil sementara parameter lain tetap?',
    options: [
      'Pita terang menjadi lebih sempit dan rapat',
      'Jarak antar pita terang (fringe spacing) semakin besar',
      'Intensitas cahaya di layar berkurang',
      'Tidak ada perubahan pada pola interferensi',
    ],
    correctIndex: 1,
    explanation:
        'Fringe spacing Δy = λL/d. Jika jarak celah d diperkecil, maka Δy membesar — pita-pita terang semakin jarang/melebar.',
  ),
  // 8
  _QuizQuestion(
    topic: 'Difraksi',
    question:
        'Cahaya dengan panjang gelombang 600 nm melewati celah tunggal selebar 0,1 mm. Pada layar yang berjarak 1 m, di mana posisi minimum orde pertama gelap?',
    options: [
      '6 mm dari pusat',
      '12 mm dari pusat',
      '3 mm dari pusat',
      '0,6 mm dari pusat',
    ],
    correctIndex: 0,
    explanation:
        'Posisi gelap orde 1: y = λL/a = (600×10⁻⁹ × 1) / (0,1×10⁻³) = 6×10⁻³ m = 6 mm dari pusat.',
  ),
  // 9
  _QuizQuestion(
    topic: 'Difraksi',
    question:
        'Mengapa difraksi suara lebih mudah diamati dalam kehidupan sehari-hari dibandingkan difraksi cahaya?',
    options: [
      'Suara merambat lebih lambat sehingga lebih mudah difraksi',
      'Panjang gelombang suara (cm–m) sebanding dengan ukuran rintangan sehari-hari',
      'Cahaya tidak dapat mengalami difraksi sama sekali',
      'Suara memiliki energi yang lebih besar dari cahaya',
    ],
    correctIndex: 1,
    explanation:
        'Difraksi signifikan terjadi saat ukuran celah ≈ panjang gelombang. Suara λ ≈ cm hingga meter; cahaya λ ≈ 400–700 nm sehingga memerlukan celah sangat kecil agar terlihat.',
  ),
  // 10
  _QuizQuestion(
    topic: 'Resonansi',
    question:
        'Sebuah kolom udara dalam pipa terbuka kedua ujungnya beresonansi pada frekuensi dasar 340 Hz. Jika cepat rambat bunyi 340 m/s, berapakah panjang pipa tersebut?',
    options: ['0,5 m', '1 m', '0,25 m', '2 m'],
    correctIndex: 0,
    explanation:
        'Pipa terbuka kedua ujungnya: f₁ = v/(2L), maka L = v/(2f₁) = 340/(2×340) = 0,5 m.',
  ),
  // 11
  _QuizQuestion(
    topic: 'Resonansi',
    question: 'Apa yang dimaksud dengan resonansi pada sistem osilasi?',
    options: [
      'Getaran yang teredam hingga berhenti total',
      'Kondisi saat frekuensi gaya luar sama dengan frekuensi alami sistem, menyebabkan amplitudo sangat besar',
      'Interferensi antara dua gelombang yang saling meniadakan',
      'Pemantulan gelombang pada batas medium',
    ],
    correctIndex: 1,
    explanation:
        'Resonansi terjadi ketika frekuensi sumber eksternal sama dengan frekuensi alami sistem. Hasilnya adalah peningkatan amplitudo yang sangat besar karena energi diserap secara efisien.',
  ),
  // 12
  _QuizQuestion(
    topic: 'Gelombang Bunyi',
    question:
        'Sebuah sumber bunyi bergerak mendekati pengamat yang diam dengan kecepatan 20 m/s. Jika frekuensi sumber 500 Hz dan cepat rambat bunyi 340 m/s, berapakah frekuensi yang didengar pengamat?',
    options: ['470 Hz', '500 Hz', '531 Hz', '550 Hz'],
    correctIndex: 2,
    explanation:
        'Efek Doppler: f\' = f × v/(v−vs) = 500 × 340/(340−20) = 500 × 340/320 ≈ 531 Hz. Sumber mendekati menyebabkan frekuensi yang terdengar lebih tinggi.',
  ),
  // 13
  _QuizQuestion(
    topic: 'Gelombang Bunyi',
    question:
        'Intensitas bunyi suatu sumber pada jarak 2 m adalah 10⁻⁴ W/m². Berapakah taraf intensitasnya? (I₀ = 10⁻¹² W/m²)',
    options: ['40 dB', '60 dB', '80 dB', '100 dB'],
    correctIndex: 2,
    explanation:
        'TI = 10 log(I/I₀) = 10 log(10⁻⁴/10⁻¹²) = 10 log(10⁸) = 10 × 8 = 80 dB.',
  ),
  // 14
  _QuizQuestion(
    topic: 'Gelombang Cahaya',
    question:
        'Cahaya putih melewati prisma dan terurai menjadi spektrum warna. Warna mana yang mengalami pembiasan paling besar?',
    options: ['Merah', 'Kuning', 'Hijau', 'Ungu'],
    correctIndex: 3,
    explanation:
        'Ungu memiliki panjang gelombang terpendek (~400 nm) sehingga indeks biasnya paling besar dalam kaca dan mengalami pembiasan terbesar.',
  ),
  // 15
  _QuizQuestion(
    topic: 'Gelombang Cahaya',
    question:
        'Polarisasi cahaya merupakan bukti bahwa cahaya adalah gelombang...',
    options: [
      'Longitudinal, karena dapat terpolarisasi',
      'Transversal, karena arah getarannya dapat dibatasi pada satu bidang',
      'Mekanik, karena membutuhkan medium untuk merambat',
      'Stasioner, karena membentuk pola tetap',
    ],
    correctIndex: 1,
    explanation:
        'Hanya gelombang transversal yang dapat mengalami polarisasi, karena arah getarannya tegak lurus terhadap arah rambat sehingga bisa dibatasi pada satu bidang oleh polarisator.',
  ),
];

// ─── Halaman Quiz ─────────────────────────────────────────────────────────────

class QuizGelombangPhintar extends StatefulWidget {
  const QuizGelombangPhintar({super.key});

  @override
  State<QuizGelombangPhintar> createState() => _QuizGelombangPhintarState();
}

class _QuizGelombangPhintarState extends State<QuizGelombangPhintar> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _finished = false;

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

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      final percentage = (_score / _questions.length * 100).roundToDouble();
      DatabaseHelperQuiz.instance.insertHistory({
        'quiz_id': 1,
        'score': percentage,
      });
      setState(() {
        _finished = true;
      });
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(
        title: "Kuis: Gelombang dan Osilasi",
        prefixIcon: Icons.arrow_back,
      ),
      body: _finished ? _buildResultPage() : _buildQuizPage(),
    );
  }

  // ─── Halaman Hasil ──────────────────────────────────────────────────────────

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
                color: scoreColor.withOpacity(0.15),
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

  // ─── Halaman Soal ───────────────────────────────────────────────────────────

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

            // ── Card Soal ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopicChip(label: question.topic),
                  const SizedBox(height: 14),
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.putih,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Pilihan Jawaban ──
            ...List.generate(question.options.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AnswerOption(
                  label: ['A', 'B', 'C', 'D'][i],
                  text: question.options[i],
                  state: _answered
                      ? (i == question.correctIndex
                            ? _OptionState.correct
                            : (i == _selectedAnswer
                                  ? _OptionState.wrong
                                  : _OptionState.inactive))
                      : _OptionState.idle,
                  onTap: () => _selectAnswer(i),
                ),
              );
            }),

            // ── Penjelasan ──
            if (_answered) ...[
              const SizedBox(height: 4),
              _ExplanationBox(text: question.explanation),
              const SizedBox(height: 20),

              // ── Tombol Lanjut ──
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex < _questions.length - 1
                            ? 'Lanjut ke Pertanyaan ${_currentIndex + 2}'
                            : 'Lihat Hasil',
                        style: const TextStyle(
                          color: AppTheme.putih,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppTheme.putih,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── Enum state opsi ──────────────────────────────────────────────────────────

enum _OptionState { idle, correct, wrong, inactive }

// ─── Widget Topic Chip ────────────────────────────────────────────────────────

class _TopicChip extends StatelessWidget {
  final String label;
  const _TopicChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bottonColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.bottonColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.waves_rounded,
            size: 13,
            color: AppTheme.bottonColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.bottonColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget Opsi Jawaban ──────────────────────────────────────────────────────

class _AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color labelBg;
    Color labelFg;
    Color textColor;
    Widget? trailingIcon;

    switch (state) {
      case _OptionState.correct:
        borderColor = AppTheme.progressColor;
        bgColor = AppTheme.progressColor.withOpacity(0.1);
        labelBg = AppTheme.progressColor;
        labelFg = AppTheme.hytam;
        textColor = AppTheme.putih;
        trailingIcon = const Icon(
          Icons.check_circle_outline_rounded,
          color: AppTheme.progressColor,
          size: 20,
        );
        break;
      case _OptionState.wrong:
        borderColor = AppTheme.merah;
        bgColor = AppTheme.merah.withOpacity(0.1);
        labelBg = AppTheme.merah;
        labelFg = AppTheme.putih;
        textColor = AppTheme.putih;
        trailingIcon = const Icon(
          Icons.cancel_outlined,
          color: AppTheme.merah,
          size: 20,
        );
        break;
      case _OptionState.inactive:
        borderColor = AppTheme.backgroundSecondary;
        bgColor = AppTheme.backgroundSecondary;
        labelBg = AppTheme.backgroundPrimary;
        labelFg = AppTheme.textColor;
        textColor = AppTheme.textColor;
        trailingIcon = const Icon(
          Icons.cancel_outlined,
          color: AppTheme.textColor,
          size: 20,
        );
        break;
      case _OptionState.idle:
      default:
        borderColor = const Color(0xFF334155);
        bgColor = AppTheme.backgroundSecondary;
        labelBg = AppTheme.backgroundPrimary;
        labelFg = AppTheme.bottonColor;
        textColor = AppTheme.putih;
        trailingIcon = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: labelBg, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: labelFg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Widget Penjelasan ────────────────────────────────────────────────────────

class _ExplanationBox extends StatelessWidget {
  final String text;
  const _ExplanationBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textColor,
          height: 1.5,
        ),
      ),
    );
  }
}
