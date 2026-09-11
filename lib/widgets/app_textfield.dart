import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/constants/app_typografy.dart';

class CustomTextFields extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;

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
    this.suffixIcon,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
    this.inputFormatters,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLength: maxLength,
      textAlign: textAlign,
      inputFormatters: inputFormatters,
      style: style ?? const TextStyle(color: Colors.white), // Warna teks inputan
      decoration: InputDecoration(
        counterText: showCounter ? null : '',
        errorText: errorText,
        errorStyle: AppTextStyle.warningText,
        hintText: hintText,
        hintStyle: AppTextStyle.normalText,
        prefixIcon: Icon(prefixIcon, color: AppTheme.textColor),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.bottonColor,
            width: 2,
          ),
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
        fillColor: AppTheme.backgroundTertiary.withValues(
          alpha: 0.3,
        ),
      ),
    );
  }
}
