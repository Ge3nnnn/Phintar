import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/constants/appbar.dart';
import 'package:blabla/extention/navigator.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/views/loginpage/login_page_phintar.dart';
import 'package:flutter/material.dart';

class ProfilePagePhintar extends StatefulWidget {
  const ProfilePagePhintar({super.key});

  @override
  State<ProfilePagePhintar> createState() => _ProfilePagePhintarState();
}

class _ProfilePagePhintarState extends State<ProfilePagePhintar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar(title: "Profile"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  PreferenceHandler.logOut();
                  context.pushAndRemoveAll(const LoginPagePhintar());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundSecondary,
                  foregroundColor: AppTheme.putih,
                  minimumSize: const Size(170, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.logout, color: AppTheme.putih),
                label: const Text("Keluar", style: AppTextStyle.normalText2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
