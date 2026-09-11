import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/firebase_options.dart';
import 'package:phintar/services/email_otp_service.dart';
import 'package:phintar/providers/lab_provider.dart';
import 'package:phintar/providers/materi_provider.dart';
import 'package:phintar/providers/quiz_provider.dart';
import 'package:phintar/views/1_loginpage/login_page_phintar.dart';
import 'package:phintar/widgets/bottom_nav/bottom_nav_bar_phintar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  EmailOtpService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  bool get _isLoggedIn {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
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
