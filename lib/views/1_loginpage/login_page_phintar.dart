import 'package:phintar/constants/app_images.dart';
import 'package:phintar/services/firebase_auth_service.dart';
import 'package:phintar/widgets/app_button.dart';
import 'package:phintar/widgets/app_textfield.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/widgets/extention/navigator.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:phintar/views/2_register_page/register_page.dart';
import 'package:phintar/views/3_reset_password_page/reset_password_page.dart';
import 'package:flutter/material.dart';

class LoginPagePhintar extends StatefulWidget {
  const LoginPagePhintar({super.key});

  @override
  State<LoginPagePhintar> createState() => _LoginPagePhintarState();
}

class _LoginPagePhintarState extends State<LoginPagePhintar> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  void login() async {
    final email = emailC.text.trim();
    final pass = passwordC.text;

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuthService().loginWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final user = cred.user;
      if (user != null) {
        if (!mounted) return;
        context.pushAndRemoveAll(const BottomNavBarPhintar());
      }
    } catch (e) {
      if (!mounted) return;
      final message = FirebaseAuthService.getErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.merah),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuthService().signInWithGoogle();
      if (cred != null && cred.user != null) {
        if (!mounted) return;
        context.pushAndRemoveAll(const BottomNavBarPhintar());
      }
    } catch (e) {
      if (!mounted) return;
      final message = FirebaseAuthService.getErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.merah),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email tidak boleh kosong";
                        } else if (!FirebaseAuthService.isValidEmail(
                          value.trim(),
                        )) {
                          return "Format email tidak valid (contoh: nama@email.com)";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFields(
                      controller: passwordC,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
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
                                builder: (context) =>
                                    const ForgotPasswordPage(),
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
                      text: _isLoading ? "Memproses..." : "Masuk",
                      width: double.infinity,
                      onPressed: _isLoading
                          ? () {}
                          : () {
                              if (_formKey.currentState!.validate()) {
                                login();
                              }
                            },
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppTheme.textColor,
                            thickness: 1,
                          ),
                        ),
                        Padding(
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
                          child: Divider(
                            color: AppTheme.textColor,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tombol Masuk dengan Google
                    CustomElevatedButton(
                      text: "Masuk dengan Google",
                      iconAsset: AppImages.googleIcon,
                      width: double.infinity,
                      backgroundColor: AppTheme.backgroundSecondary,
                      onPressed: _isLoading ? () {} : signInWithGoogle,
                    ),
                    const SizedBox(height: 12),

                    // Tombol Buat Akun Baru
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.borderColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterScreenPhintar(),
                            ),
                          );
                        },
                        child: Text(
                          "Buat Akun Baru",
                          style: AppTextStyle.botttonText.copyWith(
                            color: AppTheme.textColor,
                          ),
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
