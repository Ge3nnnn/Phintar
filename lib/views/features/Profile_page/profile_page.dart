import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/constants/appbar.dart';
import 'package:blabla/database/db_quiz.dart';
import 'package:blabla/extention/navigator.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/utils/riwayat_kuis.dart';
import 'package:blabla/views/edit_profile_page/edit_profile_phintar.dart';
import 'package:blabla/views/loginpage/login_page_phintar.dart';
import 'package:flutter/material.dart';

class ProfilePagePhintar extends StatefulWidget {
  const ProfilePagePhintar({super.key});

  @override
  State<ProfilePagePhintar> createState() => _ProfilePagePhintarState();
}

class _ProfilePagePhintarState extends State<ProfilePagePhintar> {
  final GlobalKey<RiwayatKuisSectionState> _riwayatKey =
      GlobalKey<RiwayatKuisSectionState>();
  Map<String, dynamic> _summaryStats = {
    'total': 0,
    'averageScore': 0.0,
    'maxScore': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await DatabaseHelperQuiz.instance.getSummaryStats();
    if (mounted) {
      setState(() {
        _summaryStats = stats;
      });
    }
  }

  void _onDataChanged() {
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final userName = PreferenceHandler.userName;
    final userEmail = PreferenceHandler.userEmail;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: const CustomAppBar(title: "Profile"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. User Profile Card ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.textColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.bottonColor.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.bottonColor, width: 2),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.bottonColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Pengguna Phintar',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.putih,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail.isNotEmpty
                              ? userEmail
                              : 'Belajar Fisika Interaktif',
                          style: AppTextStyle.normalText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.settings,
                      color: AppTheme.textColor,
                      size: 20,
                    ),
                    color: AppTheme.backgroundSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF334155)),
                    ),
                    onSelected: (value) {
                      if (value == 'quit') {
                        context.pushReplacement(const LoginPagePhintar());
                      } else if (value == 'edit_profile') {
                        context.push(const EditProfilePhintar()).then((_) {
                          if (mounted) setState(() {});
                        });
                      }
                      // Tambahkan disini jika ingin menambahkan hal yang lain
                    },
                    itemBuilder: (context) => [
                      // daftar di titik 3
                      PopupMenuItem(
                        value: 'edit_profile',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.edit,
                              color: AppTheme.bottonColor,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Edit Profile',
                              style: TextStyle(color: AppTheme.bottonColor),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'quit',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.logout_rounded,
                              color: AppTheme.merah,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Keluar',
                              style: TextStyle(color: AppTheme.merah),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─── 3. Riwayat Kuis Section (CRUD) ───
            RiwayatKuisSection(key: _riwayatKey, onDataChanged: _onDataChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
