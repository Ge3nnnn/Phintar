import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/constants/appbar.dart';
import 'package:flutter/material.dart';

class HomePagePhintar extends StatelessWidget {
  const HomePagePhintar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Selamat datang, "),
    );
  }
}
