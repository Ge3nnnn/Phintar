import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/providers/quiz_provider.dart';
import 'package:blabla/views/5_features/kuis_page/quiz_screen.dart';
import 'package:blabla/widgets/app_banner.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/widgets/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Quiz list page — dynamically populated from database via [QuizProvider].
///
/// No more hardcoded quiz items. Adding a new quiz only requires adding
/// a JSON entry in the seed file (or inserting into the database).
class QuizPagePhintar extends StatefulWidget {
  const QuizPagePhintar({super.key});

  @override
  State<QuizPagePhintar> createState() => _QuizPagePhintarState();
}

class _QuizPagePhintarState extends State<QuizPagePhintar> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();

    // Filter quizzes based on search query
    final allQuizzes = quizProvider.quizList;
    final filteredQuizzes = _searchQuery.isEmpty
        ? allQuizzes
        : allQuizzes
            .where((q) =>
                q.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (q.category ?? '')
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Kuis"),
      body: quizProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.bottonColor),
            )
          : SingleChildScrollView(
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
                    // Search Bar
                    CustomSearchBar(
                      hintText: 'Cari kuis...',
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    // Results or empty state
                    if (filteredQuizzes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada kuis tersedia.'
                                : 'Kuis "$_searchQuery" tidak ditemukan.',
                            style: AppTextStyle.normalText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...filteredQuizzes.map(
                        (quiz) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: EnterCourse(
                            title: quiz.title,
                            subtitle:
                                '${quiz.questions.length} Soal | ${quiz.timeLimitMinutes} Menit',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QuizScreen(quiz: quiz),
                                ),
                              );
                            },
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
