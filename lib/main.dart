import 'package:flutter/material.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:blabla/views/loginpage/login_page_phintar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phintar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppTheme.backgroundPrimary,
      ),
      home: PreferenceHandler.isLogin
          ? const BottomNavBarPhintar()
          : const LoginPagePhintar(),
    );
  }
}
