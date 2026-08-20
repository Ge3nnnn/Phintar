import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final String? iconAsset; // Dibuat opsional jika button tidak butuh ikon
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color? backgroundColor;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconAsset,
    this.width = double.infinity, // Expand by default in modern forms
    this.height = 48, // Touch target minimum height
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width, height),
        backgroundColor: backgroundColor ?? AppTheme.bottonColor,
        elevation: 2, // Subtle shadow for depth
        shadowColor: (backgroundColor ?? AppTheme.bottonColor).withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Softer, more modern corners
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconAsset != null) ...[
            Image.asset(iconAsset!, width: 22, height: 22, fit: BoxFit.contain),
            const SizedBox(width: 12),
          ],
          Text(text, style: AppTextStyle.botttonText),
        ],
      ),
    );
  }
}
