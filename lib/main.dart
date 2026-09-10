import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/firebase_options.dart';
import 'package:phintar/models/preference_handler.dart';
import 'package:phintar/providers/lab_provider.dart';
import 'package:phintar/providers/materi_provider.dart';
import 'package:phintar/providers/quiz_provider.dart';
import 'package:phintar/views/1_loginpage/login_page_phintar.dart';
import 'package:phintar/widgets/bottom_nav/bottom_nav_bar_phintar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase already initialized or error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  bool get _isLoggedIn {
    try {
      if (FirebaseAuth.instance.currentUser != null) return true;
    } catch (_) {}
    return PreferenceHandler.isLogin;
  }

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
        title: 'phintar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppTheme.backgroundPrimary,
        ),
        home: _isLoggedIn
            ? const BottomNavBarPhintar()
            : const LoginPagePhintar(),
      ),
    );
  }
}
