import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:flutter/material.dart';

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
    if (!mounted) return;
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
          hintStyle: AppTextStyle.normalText,
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
