import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class LaboKonstantaPegas extends StatefulWidget {
  const LaboKonstantaPegas({super.key});

  @override
  State<LaboKonstantaPegas> createState() => _LaboKonstantaPegasState();
}

class _LaboKonstantaPegasState extends State<LaboKonstantaPegas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(title: "Konstanta Pegas"),
    );
  }
}
