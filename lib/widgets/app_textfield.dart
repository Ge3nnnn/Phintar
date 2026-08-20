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

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Cari Modul', // text di dalam search bar
    this.onChanged,
    this.onSubmitted,
    this.controller,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // Gunakan controller dari luar jika ada, jika tidak buat baru
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // Hanya dispose controller jika kita yang membuatnya secara internal
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (_controller.text.isNotEmpty && !_showClearButton) {
      setState(() => _showClearButton = true);
    } else if (_controller.text.isEmpty && _showClearButton) {
      setState(() => _showClearButton = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary, // Warna background
        borderRadius: BorderRadius.circular(30), // Membuat ujung melengkung
      ),
      child: TextField(
        style: const TextStyle(
          color: Colors.white,
        ), // Mengubah warna teks ketikan
        cursorColor: Colors.white, // Mengubah warna kursor yang berkedip
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: AppTheme.textColor),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: AppTheme.textColor),
          // Suffix icon (Tombol silang) hanya muncul jika ada teks
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppTheme.textColor),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call(
                      '',
                    ); // Trigger onChanged saat dihapus
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
