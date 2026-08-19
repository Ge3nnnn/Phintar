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
    this.width = 168, // Default width sesuai kodemu
    this.height = 30, // Default height sesuai kodemu
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width, height),
        // Gunakan warna yang dipassing, jika null gunakan warna dari AppTheme kamu
        backgroundColor: backgroundColor ?? AppTheme.bottonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Agar posisi ikon & teks di tengah
        children: [
          // Jika iconAsset diisi, tampilkan Image
          if (iconAsset != null) ...[
            Image.asset(iconAsset!, width: 18, height: 18, fit: BoxFit.contain),
            const SizedBox(width: 10),
          ],
          // Teks Tombol
          Text(text, style: AppTextStyle.botttonText),
        ],
      ),
    );
  }
}
