import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/constants/appbar.dart';
import 'package:flutter/material.dart';

class LabPagePhintar extends StatefulWidget {
  const LabPagePhintar({super.key});

  @override
  State<LabPagePhintar> createState() => _LabPagePhintarState();
}

class _LabPagePhintarState extends State<LabPagePhintar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Laboratorium"),
    );
  }
}
