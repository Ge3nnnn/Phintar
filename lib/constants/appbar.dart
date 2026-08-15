import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? prefixIcon;
  final VoidCallback? onPrefixIconTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.prefixIcon,
    this.onPrefixIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //Mematikan tombol back otomatis bawaan Flutter
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: AppTextStyle.judul,
        // Tambahkan styling text default kamu di sini
      ),
      centerTitle: false,
      // Logika untuk menampilkan leading (prefix icon) jika ada
      leading: prefixIcon != null
          ? IconButton(
              icon: Icon(prefixIcon),
              onPressed:
                  onPrefixIconTap ??
                  () {
                    // Default action jika icon ditekan tapi onPrefixIconTap tidak diisi
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
            )
          : null, // Jika null, Flutter akan otomatis memberikan tombol back bawaan jika ada halaman sebelumnya
      // menambahkan warna atau styling default lainnya di bawah ini
      backgroundColor: AppTheme.backgroundPrimary,
      shape: Border(bottom: BorderSide(color: AppTheme.textColor, width: 1)),
    );
  }

  // Menentukan ukuran standar AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? prefixIcon;
  final VoidCallback? onPrefixIconTap;

  const CustomAppBar2({
    super.key,
    required this.title,
    this.prefixIcon,
    this.onPrefixIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyle.subjudul,
        // Tambahkan styling text default kamu di sini
      ),
      centerTitle: false,
      // Logika untuk menampilkan leading (prefix icon) jika ada
      leading: prefixIcon != null
          ? IconButton(
              icon: Icon(prefixIcon, color: AppTheme.putih),
              onPressed:
                  onPrefixIconTap ??
                  () {
                    // Default action jika icon ditekan tapi onPrefixIconTap tidak diisi
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
            )
          : null, // Jika null, Flutter akan otomatis memberikan tombol back bawaan jika ada halaman sebelumnya
      // menambahkan warna atau styling default lainnya di bawah ini
      backgroundColor: AppTheme.backgroundPrimary,
      shape: Border(bottom: BorderSide(color: AppTheme.textColor, width: 1)),
    );
  }

  // Menentukan ukuran standar AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
