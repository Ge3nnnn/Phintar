import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:flutter/material.dart';

class HomePagePhintar extends StatefulWidget {
  const HomePagePhintar({super.key});

  @override
  State<HomePagePhintar> createState() => _HomePagePhintarState();
}

class _HomePagePhintarState extends State<HomePagePhintar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        title: Text("Phintar", style: AppTextStyle.judul),
        backgroundColor: AppTheme.backgroundPrimary,
      ),
    );
  }
}
