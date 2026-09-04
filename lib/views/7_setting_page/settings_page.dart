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
  void _navigateTo(Widget page) {
    context.push(page).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _handleLogout() async {
    await PreferenceHandler.logOut();
    if (!mounted) return;
    context.pushAndRemoveAll(const LoginPagePhintar());
  }

  List<_SettingItem> _buildSettingItems() {
    return [
      _SettingItem(
        icon: Icons.edit,
        title: 'Edit Profile',
        onTap: () => _navigateTo(const EditProfilePhintar()),
      ),
      _SettingItem(
        icon: Icons.lock_reset,
        title: 'Ubah Kata Sandi',
        onTap: () => _navigateTo(
          ResetPasswordPage2(
            email: PreferenceHandler.userEmail,
            isFromSettings: true,
          ),
        ),
      ),
      _SettingItem(
        icon: Icons.logout_rounded,
        title: 'Keluar',
        iconColor: AppTheme.merah,
        titleStyle: AppTextStyle.warningText,
        showTrailing: false,
        onTap: _handleLogout,
      ),
    ];
  }

  Widget _buildSettingTile(_SettingItem item) {
    return ListTile(
      leading: Icon(item.icon, color: item.iconColor),
      title: Text(
        item.title,
        style: item.titleStyle ?? AppTextStyle.progresText,
      ),
      trailing: item.showTrailing
          ? const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.bottonColor,
              size: 16,
            )
          : null,
      onTap: item.onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildSettingItems();

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: const CustomAppBar2(
        title: "Settings",
        prefixIcon: Icons.arrow_back,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Material(
            color: AppTheme.glassBackground,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.glassBorder, width: 1.5),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppTheme.borderColor, height: 1),
              itemBuilder: (context, index) => _buildSettingTile(items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final TextStyle? titleStyle;
  final bool showTrailing;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = AppTheme.bottonColor,
    this.titleStyle,
    this.showTrailing = true,
  });
}
