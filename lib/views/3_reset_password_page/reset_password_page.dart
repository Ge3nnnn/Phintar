import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/services/firebase_auth_service.dart';
import 'package:phintar/views/3_reset_password_page/reset_password_page2.dart';
import 'package:phintar/widgets/app_bar.dart';
import 'package:phintar/widgets/app_button.dart';
import 'package:phintar/widgets/app_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController otpC = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isOtpSent = false;
  bool isLoading = false;
  bool isVerifying = false;
  String? emailError;
  String? otpError;

  int resendCountdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    emailC.dispose();
    otpC.dispose();
    super.dispose();
  }

  /// Memulai countdown 60 detik untuk mencegah spam pengiriman ulang email
  void _startCountdownTimer() {
    _timer?.cancel();
    setState(() {
      resendCountdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (resendCountdown > 1) {
        setState(() {
          resendCountdown--;
        });
      } else {
        setState(() {
          resendCountdown = 0;
        });
        timer.cancel();
      }
    });
  }

  /// Mengirimkan email verifikasi reset kata sandi resmi dari Firebase Authentication
  Future<void> sendOtpCode() async {
    final email = emailC.text.trim();

    if (email.isEmpty) {
      setState(() {
        emailError = 'Masukan email anda!';
      });
      return;
    }

    if (!FirebaseAuthService.isValidEmail(email)) {
      setState(() {
        emailError = 'Format email tidak valid (contoh: nama@email.com)';
      });
      return;
    }

    setState(() {
      isLoading = true;
      emailError = null;
    });

    try {
      // 1. Validasi keberadaan akun di database Firestore Phintar
      final isRegistered = await FirebaseAuthService().isEmailRegistered(email);
      if (!isRegistered) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          emailError =
              'Email ini belum terdaftar di Phintar. Silakan gunakan email yang sudah terdaftar.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email belum terdaftar di sistem Phintar.',
              style: AppTextStyle.normalText,
            ),
            backgroundColor: AppTheme.merah,
          ),
        );
        return;
      }

      // 2. Kirim email reset resmi langsung dari Firebase Authentication
      await FirebaseAuthService().sendPasswordResetEmail(email);

      if (!mounted) return;

      setState(() {
        isOtpSent = true;
        otpError = null;
        otpC.clear();
      });

      _startCountdownTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email verifikasi resmi dari Firebase telah dikirim ke $email.',
            style: AppTextStyle.normalText,
          ),
          backgroundColor: AppTheme.hijau,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (mounted) {
        final message = FirebaseAuthService.getErrorMessage(e);
        setState(() {
          emailError = message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: AppTextStyle.normalText),
            backgroundColor: AppTheme.merah,
            duration: const Duration(seconds: 4),
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

  /// Mengirim ulang email verifikasi Firebase jika timer cooldown sudah selesai
  Future<void> resendOtpCode() async {
    if (resendCountdown > 0 || isLoading) return;

    final email = emailC.text.trim();
    setState(() {
      isLoading = true;
      otpError = null;
    });

    try {
      await FirebaseAuthService().sendPasswordResetEmail(email);

      if (!mounted) return;

      _startCountdownTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email verifikasi baru telah dikirimkan ke $email.',
            style: AppTextStyle.normalText,
          ),
          backgroundColor: AppTheme.hijau,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (mounted) {
        final message = FirebaseAuthService.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: AppTextStyle.normalText),
            backgroundColor: AppTheme.merah,
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

  /// Memverifikasi kode atau tautan reset dari email Firebase Authentication
  Future<void> verifyOtpCode() async {
    final input = otpC.text.trim();

    if (input.isEmpty) {
      setState(() {
        otpError = 'Masukkan kode atau tautan verifikasi dari email!';
      });
      return;
    }

    setState(() {
      isVerifying = true;
      otpError = null;
    });

    try {
      // Verifikasi kode langsung ke Firebase Authentication server
      final verifiedEmail = await FirebaseAuthService().verifyPasswordResetCode(
        input,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kode verifikasi Firebase valid! Mengalihkan ke halaman atur ulang kata sandi...',
            style: AppTextStyle.normalText,
          ),
          backgroundColor: AppTheme.hijau,
          duration: const Duration(seconds: 2),
        ),
      );

      final cleanActionCode = FirebaseAuthService.extractActionCode(input);

      // Navigasi ke Halaman Reset Password Page 2 dengan status verifikasi aktif dan kode reset
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage2(
            email: verifiedEmail.isNotEmpty
                ? verifiedEmail
                : emailC.text.trim(),
            resetCode: cleanActionCode,
            isFromSettings: false,
            isOtpVerified: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = FirebaseAuthService.getErrorMessage(e);
      setState(() {
        otpError = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  /// Mengubah email tujuan dan mereset status
  void resetEmailState() {
    _timer?.cancel();
    setState(() {
      isOtpSent = false;
      resendCountdown = 0;
      otpError = null;
      otpC.clear();
    });
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
                color: AppTheme.glassBackground, // Glassmorphic effect
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.glassBorder, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header Icon
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            isOtpSent
                                ? Icons.mark_email_read_rounded
                                : Icons.lock_reset,
                            size: 50,
                            color: isOtpSent
                                ? AppTheme.bottonColor
                                : AppTheme.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Judul & Subjudul
                      Text(
                        isOtpSent
                            ? "Verifikasi Email Firebase"
                            : "Lupa Kata Sandi?",
                        style: AppTextStyle.subsubjudul,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        isOtpSent
                            ? "Email verifikasi resmi dari Firebase telah dikirim ke:"
                            : "Masukkan email Anda untuk menerima tautan / kode reset sandi dari Firebase",
                        style: AppTextStyle.bottomText,
                        textAlign: TextAlign.center,
                      ),

                      if (isOtpSent) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  emailC.text.trim(),
                                  style: AppTextStyle.normalText2.copyWith(
                                    color: AppTheme.bottonColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: resetEmailState,
                                child: Text(
                                  "Ganti",
                                  style: AppTextStyle.normalText.copyWith(
                                    color: AppTheme.textColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // TAHAP 1: INPUT EMAIL
                      if (!isOtpSent) ...[
                        Row(
                          children: [
                            Text(
                              "Alamat Email",
                              style: AppTextStyle.normalText2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        CustomTextFields(
                          controller: emailC,
                          errorText: emailError,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            if (emailError != null) {
                              setState(() {
                                emailError = null;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukan email anda!';
                            }
                            return null;
                          },
                          hintText: "fisikawan@gmail.com",
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),
                        CustomElevatedButton(
                          onPressed: isLoading ? () {} : sendOtpCode,
                          width: double.infinity,
                          text: isLoading
                              ? "Mengirim Email Firebase..."
                              : "Kirim Email Verifikasi",
                        ),
                      ],

                      // TAHAP 2: INPUT KODE / TAUTAN DARI EMAIL FIREBASE
                      if (isOtpSent) ...[
                        Row(
                          children: [
                            Text(
                              "Kode / Tautan Verifikasi",
                              style: AppTextStyle.normalText2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        CustomTextFields(
                          controller: otpC,
                          errorText: otpError,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            if (otpError != null) {
                              setState(() {
                                otpError = null;
                              });
                            }
                          },
                          hintText: "Tempel kode atau tautan dari email...",
                          prefixIcon: Icons.vpn_key_outlined,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              color: AppTheme.bottonColor,
                            ),
                            tooltip: "Tempel dari Clipboard",
                            onPressed: () async {
                              final clipboardData = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              if (clipboardData?.text != null &&
                                  clipboardData!.text!.trim().isNotEmpty) {
                                otpC.text = clipboardData.text!.trim();
                                if (otpError != null) {
                                  setState(() {
                                    otpError = null;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Info Box Petunjuk
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF38BDF8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Salin tautan atau kode yang Anda terima di email Firebase, lalu tempel di atas. Anda juga dapat langsung mengklik tautan di dalam email untuk mengubah sandi lewat peramban.",
                                  style: AppTextStyle.bottomText.copyWith(
                                    color: AppTheme.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Resend Countdown Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tidak menerima email? ",
                              style: AppTextStyle.bottomText,
                            ),
                            if (resendCountdown > 0)
                              Text(
                                "Kirim ulang (${resendCountdown}d)",
                                style: AppTextStyle.normalText2.copyWith(
                                  color: AppTheme.bottonColor,
                                ),
                              )
                            else
                              InkWell(
                                onTap: isLoading ? null : resendOtpCode,
                                child: Text(
                                  isLoading ? "Mengirim..." : "Kirim Ulang",
                                  style: AppTextStyle.normalText2.copyWith(
                                    color: AppTheme.bottonColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        CustomElevatedButton(
                          onPressed: isVerifying ? () {} : verifyOtpCode,
                          width: double.infinity,
                          text: isVerifying
                              ? "Memverifikasi ke Firebase..."
                              : "Verifikasi & Lanjutkan",
                        ),
                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: resetEmailState,
                          child: Text(
                            "Gunakan Email Lain",
                            style: AppTextStyle.normalText.copyWith(
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      Divider(color: AppTheme.textColor),
                      const SizedBox(height: 10),

                      // Tombol Kembali ke Login
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
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
    );
  }
}
