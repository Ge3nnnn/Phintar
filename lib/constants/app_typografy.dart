import 'package:blabla/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  AppTextStyle._();

  // Headings
  static final judul = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppTheme.textLight,
    letterSpacing: -0.5,
  );
  
  static final subjudul = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppTheme.textLight,
    letterSpacing: -0.3,
  );
  
  static final subsubjudul = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppTheme.textLight,
  );

  // Buttons & Interactions
  static final botttonText = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.putih,
    letterSpacing: 0.2,
  );
  
  static final bottomText = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppTheme.textColor,
  );

  // Body Texts
  static final normalText = GoogleFonts.outfit(
    fontSize: 15, 
    fontWeight: FontWeight.w400,
    color: AppTheme.textColor,
  );
  
  static final normalTextBold = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppTheme.textColor,
  );
  
  static final normalText2 = GoogleFonts.outfit(
    fontSize: 15, 
    fontWeight: FontWeight.w400,
    color: AppTheme.textLight,
  );
  
  static final normalText2Bold = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppTheme.textLight,
  );

  // States
  static final warningText = GoogleFonts.outfit(
    fontSize: 14, 
    fontWeight: FontWeight.w500,
    color: AppTheme.merah,
  );
  
  static final progresText = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppTheme.bottonColor, // Use modern bottonColor instead of old progressColor
  );

  // Card Texts
  static final cardTitle = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppTheme.putih,
  );

  static final cardSubtitle = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppTheme.textColor,
  );

  // Small Elements
  static final smallText = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppTheme.textColor,
  );

  static final smallTextBold = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppTheme.putih,
  );

  // Dialog Texts
  static final dialogTitle = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppTheme.putih,
  );

  static final dialogText = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textColor,
  );
}
