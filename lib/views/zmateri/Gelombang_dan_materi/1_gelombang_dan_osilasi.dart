import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class Materi1 extends StatefulWidget {
  const Materi1({super.key});

  @override
  State<Materi1> createState() => _Materi1State();
}

class _Materi1State extends State<Materi1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBarMateri(title: "Gelombang dan Osilasi"),
      body: Column(children: [Text('''data''')]),
    );
  }
}
