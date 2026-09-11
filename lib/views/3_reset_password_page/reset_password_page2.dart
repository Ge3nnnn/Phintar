import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/services/email_otp_service.dart';
import 'package:phintar/services/firebase_auth_service.dart';
import 'package:phintar/views/1_loginpage/login_page_phintar.dart';
import 'package:phintar/widgets/app_bar.dart';
import 'package:phintar/widgets/app_button.dart';
import 'package:phintar/widgets/app_textfield.dart';
import 'package:phintar/widgets/extention/navigator.dart';

class ResetPasswordPage2 extends StatefulWidget {
  final String email;
  final bool isFromSettings;
  final bool isOtpVerified;
  final String? resetCode;

  const ResetPasswordPage2({
    super.key,
    required this.email,
    this.isFromSettings = false,
    this.isOtpVerified = false,
    this.resetCode,
  });

  @override
  State<ResetPasswordPage2> createState() => _ResetPasswordPage2State();
}

class _ResetPasswordPage2State extends State<ResetPasswordPage2> {
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmpasswordC = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? passwordError;
  String? confirmPasswordError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Proteksi: cegah akses ke halaman ubah kata sandi jika belum diverifikasi via OTP
    if (!widget.isFromSettings &&
        !widget.isOtpVerified &&
        !EmailOtpService().isEmailVerified(widget.email)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Akses ditolak: Silakan verifikasi kode OTP terlebih dahulu.',
              ),
              backgroundColor: AppTheme.merah,
            ),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    passwordC.dispose();
    confirmpasswordC.dispose();
    super.dispose();
  }

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
      if (widget.isFromSettings) {
        await FirebaseAuthService().updatePassword(pass);
      } else {
        final code = widget.resetCode;
        if (code != null && code.isNotEmpty) {
          // Konfirmasi pembaruan kata sandi langsung ke Firebase Authentication
          await FirebaseAuthService().confirmPasswordReset(
            codeOrUrl: code,
            newPassword: pass,
          );
        } else {
          await FirebaseAuthService().sendPasswordResetEmail(widget.email);
        }
      }

      if (!mounted) return;

      final pageNavigator = Navigator.of(context);
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          title: Text(
            "Kata Sandi Berhasil Diubah!!",
            textAlign: TextAlign.center,
            style: AppTextStyle.dialogTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 140,
                child: Lottie.asset(
                  "assets/Animations/succeed_change_pass.json",
                  repeat: false,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.isFromSettings
                    ? "Kata sandi akun Anda telah berhasil diperbarui."
                    : "Kata sandi untuk ${widget.email} telah berhasil diperbarui.\nSilakan masuk kembali dengan sandi baru Anda.",
                textAlign: TextAlign.center,
                style: AppTextStyle.normalText,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                EmailOtpService().clear();
                if (widget.isFromSettings) {
                  pageNavigator.pop();
                } else {
                  pageNavigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPagePhintar()),
                    (route) => false,
                  );
                }
              },
              child: Text(
                widget.isFromSettings ? "Kembali" : "Kembali ke Login",
                style: AppTextStyle.normalText2,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        final message = FirebaseAuthService.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
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
      appBar: const CustomAppBar(title: "Phintar"),
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.glassBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.glassBorder, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
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
                        child: const Center(
                          child: Icon(
                            Icons.lock_reset,
                            size: 50,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Atur Ulang Kata Sandi",
                        style: AppTextStyle.subsubjudul,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Masukan Kata Sandi Baru Anda Dibawah Ini Untuk Mengamankan Akun.",
                        style: AppTextStyle.bottomText,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.email.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Text(
                            widget.email,
                            style: AppTextStyle.normalText2.copyWith(
                              color: AppTheme.bottonColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Text(
                            "Masukan kata sandi baru",
                            style: AppTextStyle.normalText2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
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
                            return "Kata sandi tidak boleh kosong";
                          } else if (value.length < 8) {
                            return "Minimal 8 karakter";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "Konfirmasi kata sandi baru",
                            style: AppTextStyle.normalText2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
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
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Konfirmasi password wajib diisi";
                          } else if (value != passwordC.text) {
                            return "Kata sandi tidak cocok";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomElevatedButton(
                        onPressed: isLoading ? () {} : resetPassword,
                        width: double.infinity,
                        text: isLoading ? "Memproses..." : "Ubah Kata Sandi",
                      ),
                      const SizedBox(height: 10),
                      Divider(color: AppTheme.textColor),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          EmailOtpService().clear();
                          if (widget.isFromSettings) {
                            context.pop();
                          } else {
                            context.pushAndRemoveAll(const LoginPagePhintar());
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios,
                              color: AppTheme.putih,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.isFromSettings
                                  ? "Kembali"
                                  : "Kembali ke halaman login",
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
    );
  }
}
