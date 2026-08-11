import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/database/db_helper.dart';
import 'package:blabla/extention/navigator.dart';

import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/views/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:blabla/views/register_page/resister_page.dart';
import 'package:blabla/views/reset_password_pagr/reset_password_page.dart';
import 'package:flutter/material.dart';

class LoginPagePhintar extends StatefulWidget {
  const LoginPagePhintar({super.key});

  @override
  State<LoginPagePhintar> createState() => _LoginPagePhintarState();
}

class _LoginPagePhintarState extends State<LoginPagePhintar> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailC = TextEditingController();
    final TextEditingController passwordC = TextEditingController();
    final formKey = GlobalKey<FormState>();
    // Fungsi untuk memverifikasi login pengguna menggunakan data di SQLite.
    void login() async {
      final user = emailC.text.trim();
      final pass = passwordC.text;

      if (user.isEmpty || pass.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Isi semua field!')));
        return;
      }

      // Memeriksa pencocokan kredensial email & password di database.
      final pengguna = await DBHelper().loginUser(user, pass);

      if (!mounted) return;

      if (pengguna != null) {
        // Jika berhasil login, navigasi ke home page.
        context.pushAndRemoveAll(const BottomNavBarPhintar());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login gagal! email atau Password salah.'),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Phintar",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email tidak boleh kosong";
                    } else if (!value.contains('@')) {
                      return "Email tidak valid";
                    }
                    return null;
                  },
                  controller: emailC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
                    hintText: 'Masukan email anda',
                    hintStyle: TextStyle(color: AppTheme.textColor),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password tidak boleh kosong";
                    } else if (value.length < 8) {
                      return "Password kurang dari 8 karakter";
                    }
                    return null; // Input valid
                  },
                  controller: passwordC,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: AppTheme.textColor),
                  ),
                ),
                SizedBox(height: 5),
                // Tombol Lupa Sandi
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(color: AppTheme.progressColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Tombol Login
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(168, 35),
                    backgroundColor: AppTheme.bottonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text("Masuk", style: AppTextStyle.botttonText),
                ),

                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppTheme.textColor, thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                      child: Text(
                        "atau",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppTheme.textColor, thickness: 1),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFBFBFBF)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: TextButton(
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
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
