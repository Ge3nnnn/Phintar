import 'package:blabla/views/homepage/home_page.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:bottom_navigator/bottom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BottomNavBarPhintar extends StatefulWidget {
  const BottomNavBarPhintar({super.key});

  @override
  State<BottomNavBarPhintar> createState() => _BottomNavBarPhintarState();
}

class _BottomNavBarPhintarState extends State<BottomNavBarPhintar> {
  int _selectedBottom = 0;

  // Fungsi untuk mengubah item navigasi aktif.
  void changeBottom(int index) {
    _selectedBottom = index;
    print("Ini adalah value dari $_selectedBottom");
    setState(() {});
  }

  // Daftar halaman/widget yang ditampilkan pada body sesuai indeks terpilih.
  final List<Widget> _widgetOptions = [HomePagePhintar()];
  // Daftar item menu yang muncul di navigasi bawah.
  List<BottomNavItem> navItems = [
    BottomNavItem(icon: Icons.home, label: "Home"),
    BottomNavItem(icon: Icons.school, label: "Laboratory"),
    BottomNavItem(icon: Icons.quiz, label: "Quiz"),
    BottomNavItem(icon: Icons.person, label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: FloatingNavBottomBar(
        showLabels: true,
        backgroundColor: AppTheme.backgroundSecondary,
        items: navItems,
        currentIndex: _selectedBottom,
        onTap: (index) => setState(() => _selectedBottom = index),
      ),
      // Menampilkan widget yang sesuai dengan indeks _selectedBottom
      body: _widgetOptions.elementAt(_selectedBottom),
    );
  }
}
