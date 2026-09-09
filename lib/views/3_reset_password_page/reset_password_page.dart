import 'package:Phintar/services/firebase_auth_service.dart';
import 'package:Phintar/widgets/app_button.dart';
import 'package:Phintar/widgets/app_textfield.dart';
import 'package:Phintar/constants/app_typografy.dart';
import 'package:Phintar/widgets/app_bar.dart';
import 'package:Phintar/constants/app_theme.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailC = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? emailError;

  @override
  void dispose() {
    emailC.dispose();
    super.dispose();
  }

  // Fungsi untuk mengirim email reset sandi via Firebase Auth
  void verifyEmail() async {
    final user = emailC.text.trim();

    if (user.isEmpty) {
      setState(() {
        emailError = 'Masukan email anda!';
      });
      return;
    }

    setState(() {
      isLoading = true;
      emailError = null;
    });

    try {
      await FirebaseAuthService().sendPasswordResetEmail(user);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          title: Row(
            children: [
              const Icon(Icons.mark_email_read_rounded, color: AppTheme.bottonColor),
              const SizedBox(width: 10),
              Text(
                "Email Terkirim!",
                style: AppTextStyle.dialogTitle,
              ),
            ],
          ),
          content: Text(
            "Tautan untuk mengatur ulang kata sandi telah dikirim ke $user.\n\nSilakan periksa kotak masuk atau folder spam Anda.",
            style: AppTextStyle.normalText,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: Text("Kembali ke Login", style: AppTextStyle.normalText2),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        final message = FirebaseAuthService.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: AppTextStyle.normalText,
            ),
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
                      Text("Lupa Kata Sandi?", style: AppTextStyle.subsubjudul),
                      SizedBox(height: 10),
                      Text(
                        "Masukan email anda untuk mengubah sandi",
                        style: AppTextStyle.bottomText,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text("Alamat Email", style: AppTextStyle.normalText2),
                        ],
                      ),
                      SizedBox(height: 5),
                      CustomTextFields(
                        controller: emailC,
                        errorText: emailError,
                        onChanged: (value) {
                          if (emailError != null) {
                            setState(() {
                              emailError = null;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'masukan email anda!';
                          }
                          return null;
                        },
                        hintText: "fisikawan@gmail.com",
                        prefixIcon: Icons.email,
                      ),
                      SizedBox(height: 20), // Tambahan jarak
                      CustomElevatedButton(
                        onPressed: isLoading ? () {} : verifyEmail,
                        width: double.infinity,
                        text: isLoading
                            ? "Mengirim..."
                            : "Kirim Tautan Reset Sandi",
                      ),
                      SizedBox(height: 10),
                      Divider(color: AppTheme.textColor),
                      SizedBox(height: 10),
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
