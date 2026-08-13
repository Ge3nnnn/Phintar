import 'package:blabla/constants/app_theme.dart';
import 'package:flutter/material.dart';

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
        errorStyle: const TextStyle(color: AppTheme.merah),
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.textColor),
        prefixIcon: Icon(prefixIcon, color: AppTheme.textColor),
        // 1. Padding di dalam TextField agar luas dan tidak mepet
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        // 2. Border saat kondisi normal (belum diklik)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8,
          ), // Sesuaikan lengkungan ujung kotak
          borderSide: BorderSide(color: AppTheme.textColor, width: 1),
        ),
        // 3. Border saat TextField diklik (sedang mengetik)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.putih, width: 1.5),
        ),

        // 4. Border MERAH saat validasi gagal (error)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.merah, width: 1),
        ),

        // 5. Border MERAH saat error dan sedang diklik
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.merah, width: 1.5),
        ),

        // Memastikan background transparan atau bisa kamu sesuaikan
        filled: true,
        fillColor: Colors.transparent,
      ),
    );
  }
}
