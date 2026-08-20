import 'package:blabla/widgets/app_textfield.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/database/db_helper.dart';
import 'package:blabla/extention/navigator.dart';

import 'package:blabla/views/loginpage/login_page_phintar.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResetPasswordPage2 extends StatefulWidget {
  final String email;
  const ResetPasswordPage2({super.key, required this.email});

  @override
  State<ResetPasswordPage2> createState() => _ResetPasswordPage2State();
}

class _ResetPasswordPage2State extends State<ResetPasswordPage2> {
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmpasswordC = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variabel untuk mengatur state loading saat mengecek database
  bool isLoading = false;

  // Variabel untuk menyimpan pesan error password
  String? passwordError;
  String? confirmPasswordError;

  void resetPassword() async {
    final pass = passwordC.text.trim();
    final confirm = confirmpasswordC.text.trim();

    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    bool hasError = false;

    if (pass.isEmpty) {
      setState(() {
        passwordError = 'Kata sandi tidak boleh kosong';
      });
      hasError = true;
    } else if (pass.length < 8) {
      setState(() {
        passwordError = 'Minimal 8 karakter';
      });
      hasError = true;
    }

    if (confirm.isEmpty) {
      setState(() {
        confirmPasswordError = 'Konfirmasi password wajib diisi';
      });
      hasError = true;
    } else if (confirm != pass) {
      setState(() {
        confirmPasswordError = 'Kata sandi tidak cocok';
      });
      hasError = true;
    }

    if (hasError) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Menyimpan data pengguna ke database SQLite melalui DBHelper.
      bool success = await DBHelper().updatePassword(widget.email, pass);

      if (!mounted) return;

      // Menampilkan notifikasi SnackBar sesuai hasil pendaftaran.
      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.backgroundSecondary,
            title: Text(
              "Kata Sandi Berhasil Diubah!!",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.putih),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset("assets/Animations/succeed_change_pass.json"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pushReplacement(const LoginPagePhintar());
                },
                child: Text("Kembali", style: TextStyle(color: AppTheme.putih)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Kata sandi gagal diubah!!",
              style: AppTextStyle.normalText,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Phintar"),
      backgroundColor: AppTheme.backgroundPrimary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundSecondary,
                border: Border.all(color: AppTheme.textColor, width: 1),
                borderRadius: BorderRadius.circular(9),
              ),
              margin: const EdgeInsets.all(9),
              height: 600,
              width: 500,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  // Bungkus Column dengan Form
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundPrimary,

                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock_reset,
                              size: 50,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Atur Ulang Kata Sandi",
                          style: AppTextStyle.subsubjudul,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Masukan Kata Sandi Baru Anda Dibawah Ini Untuk Mengamankan Akun.",
                          style: AppTextStyle.bottomText,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 13),
                        Row(
                          children: [
                            Text(
                              "Masukan kata sandi baru",
                              style: AppTextStyle.normalText,
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        CustomTextFields(
                          controller: passwordC,
                          errorText: passwordError,
                          onChanged: (value) {
                            if (passwordError != null) {
                              setState(() {
                                passwordError = null;
                              });
                            }
                          },
                          hintText: "Masukan kata sandi anda",
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kata sandi tidak boleh kosong";
                            } else if (value.length < 8) {
                              return "Minimal 8 karakter";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "Konfirmasi kata sandi baru",
                              style: AppTextStyle.normalText,
                            ),
                          ],
                        ),
                        CustomTextFields(
                          controller: confirmpasswordC,
                          errorText: confirmPasswordError,
                          onChanged: (value) {
                            if (confirmPasswordError != null) {
                              setState(() {
                                confirmPasswordError = null;
                              });
                            }
                          },
                          hintText: "Konfirmasi kata sandi anda",
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Konfirmasi password wajib diisi";
                            } else if (value != passwordC.text) {
                              return "Kata sandi tidak cocok";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20), // Tambahan jarak
                        ElevatedButton(
                          // Saat loading, matikan tombol (set null) agar tidak dispam klik
                          onPressed: isLoading ? null : resetPassword,
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.putih,
                                      strokeWidth: 4,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Ubah Kata Sandi"),
                                      SizedBox(
                                        width: 8,
                                      ), // Jarak antara teks dan icon
                                      Icon(Icons.arrow_forward_rounded),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(color: AppTheme.textColor),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            context.push(const LoginPagePhintar());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                color: AppTheme.putih,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Kembali ke halaman login",
                                style: AppTextStyle.normalText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
