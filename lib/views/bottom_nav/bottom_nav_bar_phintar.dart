import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/views/features/Profile_page/profile_page.dart';
import 'package:blabla/views/features/home_page/home_page.dart';
import 'package:blabla/views/features/kuis_page/quiz_page.dart';
import 'package:blabla/views/features/lab_page/lab_page.dart';
import 'package:bottom_navigator/bottom_navigator.dart';
import 'package:flutter/material.dart';

class BottomNavBarPhintar extends StatefulWidget {
  final int initialIndex;

  const BottomNavBarPhintar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBarPhintar> createState() => _BottomNavBarPhintarState();
}

class _BottomNavBarPhintarState extends State<BottomNavBarPhintar> {
  late int _selectedBottom;

  @override
  void initState() {
    super.initState();
    _selectedBottom = widget.initialIndex;
  }

  // Fungsi untuk mengubah item navigasi aktif.
  void changeBottom(int index) {
    _selectedBottom = index;
    setState(() {});
  }

  // Daftar halaman/widget yang ditampilkan pada body sesuai indeks terpilih.
  final List<Widget> _widgetOptions = [
    HomePagePhintar(),
    LabPagePhintar(),
    QuizPagePhintar(),
    ProfilePagePhintar(),
  ];
  // Daftar item menu yang muncul di navigasi bawah.
  List<BottomNavItem> navItems = [
    BottomNavItem(icon: Icons.home, label: "Home"),
    BottomNavItem(icon: Icons.science, label: "Laboratorium"),
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
