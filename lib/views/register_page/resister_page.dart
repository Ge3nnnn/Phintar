import 'package:blabla/constants/app_textfield.dart';
import 'package:blabla/constants/appbar.dart';
import 'package:blabla/constants/app_button.dart';
import 'package:blabla/constants/app_images.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/database/db_helper.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/extention/navigator.dart';
import 'package:blabla/models/user_model_login.dart';
import 'package:blabla/views/loginpage/login_page_phintar.dart';
import 'package:flutter/material.dart';

class RegisterScreenPhintar extends StatefulWidget {
  const RegisterScreenPhintar({super.key});

  @override
  State<RegisterScreenPhintar> createState() => _RegisterScreenPhintarState();
}

class _RegisterScreenPhintarState extends State<RegisterScreenPhintar> {
  // 1. PINDAHKAN CONTROLLER & KEY KE SINI (Di luar fungsi build)
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmpasswordC = TextEditingController();
  final TextEditingController nameC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 2. TAMBAHKAN DISPOSE UNTUK MENCEGAH MEMORY LEAK
  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    confirmpasswordC.dispose();
    nameC.dispose();
    super.dispose();
  }

  // 3. PINDAHKAN FUNGSI REGISTER KE SINI
  void register() async {
    final user = emailC.text.trim();
    final pass = passwordC.text;
    final name = nameC.text.trim();
    // memanggil database
    final pengguna = UserModelSQL(email: user, password: pass, nama: name);
    bool success = await DBHelper().registerUser(pengguna);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Akun berhasil dibuat')));
      // Opsional: Langsung arahkan ke halaman login setelah sukses
      // context.pushReplacement(const LoginPagePhintar());
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Phintar"),
      backgroundColor: AppTheme.backgroundPrimary,
      body: SingleChildScrollView(
        // Agar tidak error overflow saat keyboard muncul
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text("Daftar Akun Anda", style: AppTextStyle.judul),
              Text(
                "Mulai perjalanan sains anda.",
                style: AppTextStyle.subjudul,
              ),
              const SizedBox(height: 20),

              // 4. HAPUS HEIGHT: 600 PADA CONTAINER AGAR FLEKSIBEL
              Container(
                width: double.infinity, // Ambil lebar maksimal yang tersedia
                decoration: BoxDecoration(
                  color: AppTheme.backgroundSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.textColor),
                ),
                padding: const EdgeInsets.all(20.0), // Ganti padding di dalam
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextFields(
                        controller: nameC,
                        hintText: "Anda ingin dikenal sebagai",
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Username tidak boleh kosong";
                          } else if (value.length < 3) {
                            return "Username terlalu pendek";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextFields(
                        controller: emailC,
                        hintText: "Daftarkan email anda",
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email tidak boleh kosong";
                          } else if (!value.contains('@')) {
                            return "Email tidak valid";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextFields(
                        controller: passwordC,
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
                      const SizedBox(height: 16),
                      CustomTextFields(
                        controller: confirmpasswordC,
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
                      const SizedBox(height: 25),
                      CustomElevatedButton(
                        text: "Daftar",
                        width:
                            double.infinity, // Tombol memenuhi lebar container
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            register();
                          }
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Colors.grey, thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                "Atau daftar dengan",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Colors.grey, thickness: 1),
                            ),
                          ],
                        ),
                      ),

                      // 5. MENGGUNAKAN ROW DENGAN EXPANDED AGAR TIDAK OVERFLOW
                      Row(
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              iconAsset: AppImages.googleIcon,
                              text: "Google",
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomElevatedButton(
                              iconAsset: AppImages.facebookIcon,
                              text: "Facebook",
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sudah Punya Akun?", style: AppTextStyle.bottomText),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      context.pushReplacement(const LoginPagePhintar());
                    },
                    child: Text("Masuk", style: AppTextStyle.progresText),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 6. UPDATE CUSTOM TEXT FIELD DENGAN OUTLINE BORDER (Lebih Rapi)
  Widget buildCustomTextField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.textColor),
        prefixIcon: Icon(prefixIcon, color: AppTheme.textColor),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.textColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
