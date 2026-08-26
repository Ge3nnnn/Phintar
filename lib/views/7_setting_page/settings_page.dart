import 'package:flutter/material.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/views/1_loginpage/login_page_phintar.dart';
import 'package:blabla/views/4_edit_profile_page/edit_profile_phintar.dart';
import 'package:blabla/views/3_reset_password_page/reset_password_page2.dart';
import 'package:blabla/widgets/extention/navigator.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/widgets/app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: const CustomAppBar2(
        title: "Settings",
        prefixIcon: Icons.arrow_back,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.glassBorder, width: 1.5),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.bottonColor),
                  title: Text('Edit Profile', style: AppTextStyle.progresText),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.bottonColor,
                    size: 16,
                  ),
                  onTap: () {
                    context.push(const EditProfilePhintar()).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                ),
                const Divider(color: AppTheme.borderColor, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.lock_reset,
                    color: AppTheme.bottonColor,
                  ),
                  title: Text(
                    'Ubah Kata Sandi',
                    style: AppTextStyle.progresText,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.bottonColor,
                    size: 16,
                  ),
                  onTap: () {
                    final email = PreferenceHandler.userEmail;
                    context
                        .push(
                          ResetPasswordPage2(
                            email: email,
                            isFromSettings: true,
                          ),
                        )
                        .then((_) {
                          if (mounted) setState(() {});
                        });
                  },
                ),
                const Divider(color: AppTheme.borderColor, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.merah,
                  ),
                  title: Text('Keluar', style: AppTextStyle.warningText),
                  onTap: () async {
                    await PreferenceHandler.logOut();
                    if (!context.mounted) return;
                    context.pushAndRemoveAll(const LoginPagePhintar());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
