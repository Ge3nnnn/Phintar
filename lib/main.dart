import 'package:Phintar/firebase_options.dart';
import 'package:Phintar/providers/lab_provider.dart';
import 'package:Phintar/providers/materi_provider.dart';
import 'package:Phintar/providers/quiz_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Phintar/constants/app_theme.dart';
import 'package:Phintar/models/preference_handler.dart';
import 'package:Phintar/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:Phintar/views/1_loginpage/login_page_phintar.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
