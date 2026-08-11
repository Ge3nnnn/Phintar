import 'package:blabla/constants/app_theme.dart';
import 'package:flutter/material.dart';

class AppTextStyle {
  AppTextStyle._();
  static const judul = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppTheme.putih,
  );
  static const subjudul = TextStyle(fontSize: 20, color: AppTheme.putih);
  static const subsubjudul = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: AppTheme.textColor,
  );
  static const botttonText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppTheme.putih,
  );
  static const bottomText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppTheme.textColor,
  ); static const progresText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppTheme.progressColor,
  );
}
