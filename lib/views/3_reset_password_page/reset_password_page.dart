import 'package:blabla/widgets/app_button.dart';
import 'package:blabla/widgets/app_textfield.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/data/database/db_helper.dart';
import 'package:blabla/views/3_reset_password_page/reset_password_page2.dart';
import 'package:flutter/material.dart';
// Jika kamu menggunakan Firebase, import firebase auth/firestore di sini

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Pindahkan controller ke dalam State agar tidak di-rebuild terus menerus
  final TextEditingController emailC = TextEditingController();

  // Key untuk memvalidasi form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variabel untuk mengatur state loading saat mengecek database
  bool isLoading = false;

  // Variabel untuk menyimpan pesan error email
  String? emailError;

  @override
  void dispose() {
    emailC
        .dispose(); // Jangan lupa dispose controller untuk mencegah memory leak
    super.dispose();
  }

  // Fungsi untuk mengecek email
  void verifyEmail() async {
    final user = emailC.text.trim();

    if (user.isEmpty) {
      setState(() {
        emailError = 'masukan email anda!';
      });
      return;
    }

    setState(() {
      isLoading = true;
      emailError = null;
    });

    try {
      // Cek ke database apakah user terdaftar
      bool isRegistered = await DBHelper().checkEmailExists(user);

      if (!mounted) return;

      if (isRegistered) {
        //  Jika terdaftar, arahkan ke page selanjutnya (Tahap 2 / Ubah Password)
        // Kirim juga emailnya agar database tahu user mana yang mau di-update passwordnya
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage2(
              email: user,
            ), // Ganti dengan nama halaman tahap 2-mu
          ),
        );
      } else {
        setState(() {
          emailError = 'email belum terdaftar';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Terjadi kesalahan: $e",
              style: AppTextStyle.normalText,
            ),
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

  // // Fungsi pura-pura (Mock) untuk contoh. Hapus ini nanti.
  // bool _checkMockDatabase(String email) {
  //   List<String> registeredEmails = ["fisikawan@gmail.com", "test@gmail.com"];
  //   return registeredEmails.contains(email);
  // }

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
                        onPressed: isLoading
                            ? () {}
                            : verifyEmail, // Handle disabled state in verifyEmail or just empty func
                        width: double.infinity,
                        text: "Lanjut Ubah Kata Sandi",
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
