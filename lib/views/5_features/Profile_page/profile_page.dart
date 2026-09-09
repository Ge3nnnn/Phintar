import 'dart:io';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/services/firebase_auth_service.dart';
import 'package:phintar/views/7_setting_page/settings_page.dart';
import 'package:phintar/widgets/app_bar.dart';
import 'package:phintar/widgets/extention/navigator.dart';
import 'package:phintar/models/preference_handler.dart';
import 'package:phintar/widgets/history_card/riwayat_kuis.dart';
import 'package:phintar/widgets/history_card/riwayat_materi.dart';

import 'package:flutter/material.dart';

class ProfilePagePhintar extends StatefulWidget {
  const ProfilePagePhintar({super.key});

  @override
  State<ProfilePagePhintar> createState() => _ProfilePagePhintarState();
}

class _ProfilePagePhintarState extends State<ProfilePagePhintar> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuthService().currentUser;
    final userName =
        (currentUser?.displayName != null &&
            currentUser!.displayName!.isNotEmpty)
        ? currentUser.displayName!
        : PreferenceHandler.userName;
    final userEmail =
        (currentUser?.email != null && currentUser!.email!.isNotEmpty)
        ? currentUser.email!
        : PreferenceHandler.userEmail;
    final userPhoto = PreferenceHandler.userPhoto;
    final hasPhoto =
        userPhoto != null &&
        userPhoto.isNotEmpty &&
        File(userPhoto).existsSync();
    final networkPhoto = currentUser?.photoURL;
    final hasNetworkPhoto = networkPhoto != null && networkPhoto.isNotEmpty;

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
                      child: ClipOval(
                        child: hasPhoto
                            ? Image.file(
                                File(userPhoto),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : hasNetworkPhoto
                            ? Image.network(
                                networkPhoto,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.person_rounded,
                                  color: AppTheme.bottonColor,
                                  size: 36,
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: AppTheme.bottonColor,
                                size: 36,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty ? userName : 'Pengguna phintar',
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
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: AppTheme.textColor,
                        size: 24,
                      ),
                      onPressed: () {
                        context.push(const SettingsPage()).then((_) {
                          if (mounted) setState(() {});
                        });
                      },
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
