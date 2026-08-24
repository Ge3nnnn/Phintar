import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/views/5_features/home_page/home_page.dart';
import 'package:blabla/views/5_features/kuis_page/quiz_page.dart';
import 'package:blabla/views/5_features/lab_page/lab_page.dart';
import 'package:blabla/views/features/Profile_page/profile_page.dart';
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

  final List<Widget> _widgetOptions = [
    HomePagePhintar(),
    LabPagePhintar(),
    QuizPagePhintar(),
    ProfilePagePhintar(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedBottom],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottom,
        onTap: (index) => setState(() => _selectedBottom = index),
        backgroundColor: AppTheme.backgroundSecondary,
        selectedItemColor: AppTheme.bottonColor,
        unselectedItemColor: AppTheme.textColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science_rounded),
            label: "Laboratorium",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: "Quiz",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
