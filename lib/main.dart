import 'package:blabla/providers/lab_provider.dart';
import 'package:blabla/providers/materi_provider.dart';
import 'package:blabla/providers/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:blabla/views/1_loginpage/login_page_phintar.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MateriProvider>(
          create: (_) => MateriProvider()..loadMateri(),
        ),
        ChangeNotifierProvider<LabProvider>(
          create: (_) => LabProvider()..loadLabs(),
        ),
        ChangeNotifierProvider<QuizProvider>(
          create: (_) => QuizProvider()..loadQuizzes(),
        ),
      ],
      child: MaterialApp(
        title: 'Phintar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppTheme.backgroundPrimary,
        ),
        home: PreferenceHandler.isLogin
            ? const BottomNavBarPhintar()
            : const LoginPagePhintar(),
      ),
    );
  }
}
