import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/widgets/extention/navigator.dart';
import 'package:blabla/widgets/history_card/riwayat_kuis.dart';
import 'package:blabla/widgets/history_card/riwayat_materi.dart';
import 'package:blabla/views/4_edit_profile_page/edit_profile_phintar.dart';
import 'package:blabla/views/1_loginpage/login_page_phintar.dart';
import 'package:flutter/material.dart';

class ProfilePagePhintar extends StatefulWidget {
  const ProfilePagePhintar({super.key});

  @override
  State<ProfilePagePhintar> createState() => _ProfilePagePhintarState();
}

class _ProfilePagePhintarState extends State<ProfilePagePhintar> {
  @override
  Widget build(BuildContext context) {
    final userName = PreferenceHandler.userName;
    final userEmail = PreferenceHandler.userEmail;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Profile"),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(16),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── 1. User Profile Card ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.glassBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.glassBorder, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.bottonColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.bottonColor,
                          width: 2,
                        ),
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty ? userName : 'Pengguna Phintar',
                            style: AppTextStyle.subsubjudul,
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
                      onSelected: (value) async {
                        if (value == 'quit') {
                          await PreferenceHandler.logOut();
                          if (!context.mounted) return;
                          context.pushAndRemoveAll(const LoginPagePhintar());
                        } else if (value == 'edit_profile') {
                          context.push(const EditProfilePhintar()).then((_) {
                            if (mounted) setState(() {});
                          });
                        }
                        // Tambahkan disini jika ingin menambahkan fitur yang lain
                      },
                      itemBuilder: (context) => [
                        // daftar di titik 3
                        PopupMenuItem(
                          value: 'edit_profile',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: AppTheme.bottonColor,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Edit Profile',
                                style: AppTextStyle.progresText,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'quit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: AppTheme.merah,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Keluar', style: AppTextStyle.warningText),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ─── Riwayat Materi Section (CRUD) ───
              RiwayatMateriSection(),
              SizedBox(height: 16),
              // ─── Riwayat Kuis Section (CRUD) ───
              RiwayatKuisSection(),
            ],
          ),
        ),
      ),
    );
  }
}
