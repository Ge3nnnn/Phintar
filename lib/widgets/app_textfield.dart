import 'package:blabla/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:blabla/constants/app_typografy.dart';

class CustomTextFields extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const CustomTextFields({
    super.key,
    required this.controller,
    this.validator,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white), // Warna teks inputan
      decoration: InputDecoration(
        errorText: errorText,
        errorStyle: AppTextStyle.warningText,
        hintText: hintText,
        hintStyle: AppTextStyle.normalText,
        prefixIcon: Icon(prefixIcon, color: AppTheme.textColor),
        // 1. Padding di dalam TextField agar luas dan tidak mepet
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18, // Slightly more vertical padding for breathing room
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.bottonColor, width: 2), // Botton color highlight on focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.merah, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.merah, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.backgroundTertiary.withValues(alpha: 0.3), // Subtle translucent background
      ),
    );
  }
}
