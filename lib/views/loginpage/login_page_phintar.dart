import 'package:blabla/widgets/app_button.dart';
import 'package:blabla/widgets/app_textfield.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/database/db_helper.dart';
import 'package:blabla/widgets/extention/navigator.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:blabla/views/register_page/resister_page.dart';
import 'package:blabla/views/reset_password_page/reset_password_page.dart';
import 'package:flutter/material.dart';

class LoginPagePhintar extends StatefulWidget {
  const LoginPagePhintar({super.key});

  @override
  State<LoginPagePhintar> createState() => _LoginPagePhintarState();
}

class _LoginPagePhintarState extends State<LoginPagePhintar> {
  // 1. PINDAHKAN CONTROLLER & KEY KE SINI (Di luar fungsi build)
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 2. TAMBAHKAN DISPOSE UNTUK MENCEGAH MEMORY LEAK
  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  // 3. PINDAHKAN FUNGSI LOGIN KE SINI
  void login() async {
    final user = emailC.text.trim();
    final pass = passwordC.text;

    // Memeriksa pencocokan kredensial email & password di database.
    final pengguna = await DBHelper().loginUser(user, pass);

    if (!mounted) return;

    if (pengguna != null) {
      // Simpan status login dan data pengguna
      await PreferenceHandler.setLogin(true);
      await PreferenceHandler.setUserName(pengguna.nama);
      await PreferenceHandler.setUserEmail(pengguna.email);
      if (!mounted) return;
      // Jika berhasil login, navigasi ke home page.
      context.pushAndRemoveAll(const BottomNavBarPhintar());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login gagal! Email atau Password salah.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      // 4. BUNGKUS DENGAN SingleChildScrollView AGAR TIDAK OVERFLOW SAAT KEYBOARD MUNCUL
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Phintar",
                    style: AppTextStyle.judul.copyWith(fontSize: 48),
                  ),
                  SizedBox(height: 40),

                  // 5. MENGGUNAKAN FUNGSI BANTUAN AGAR DESAIN KONSISTEN
                  CustomTextFields(
                    controller: emailC,
                    hintText: 'Masukan email anda',
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email tidak boleh kosong";
                      } else if (!value.contains('@')) {
                        return "Email tidak valid";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextFields(
                    controller: passwordC,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password tidak boleh kosong";
                      } else if (value.length < 8) {
                        return "Password kurang dari 8 karakter";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),

                  // Tombol Lupa Sandi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Lupa Kata Sandi?",
                          style: AppTextStyle.bottomText.copyWith(
                            color: AppTheme.bottonColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Tombol Login
                  CustomElevatedButton(
                    text: "Masuk",
                    width: double.infinity,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppTheme.textColor, thickness: 1),
                      ),
                      Padding(
                        // 6. PERBAIKAN TYPO: EdgeInsetsGeometry -> EdgeInsets
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: const Text(
                          "atau",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppTheme.textColor, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tombol Buat Akun Baru
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.borderColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreenPhintar(),
                          ),
                        );
                      },
                      child: Text(
                        "Buat Akun Baru",
                        style: AppTextStyle.botttonText.copyWith(color: AppTheme.textColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
