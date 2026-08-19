import 'package:blabla/constants/app_theme.dart';
import 'package:flutter/material.dart';

class AppTextStyle {
  AppTextStyle._();
  static const judul = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppTheme.putih,
  );
  static const subjudul = TextStyle(
    fontSize: 22,
    color: AppTheme.putih,
    fontWeight: FontWeight.bold,
  );
  static const subsubjudul = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppTheme.putih,
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
  );
  static const normalText = TextStyle(fontSize: 15, color: AppTheme.textColor);
  static const normalTextBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppTheme.textColor,
  );
  static const normalText2 = TextStyle(fontSize: 15, color: AppTheme.putih);
  static const normalText2Bold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppTheme.putih,
  );
  static const warningText = TextStyle(fontSize: 15, color: AppTheme.merah);
  static const progresText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppTheme.progressColor,
  );
}
