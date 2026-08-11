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
  @override
  Widget build(BuildContext context) {
    // Controller untuk menangani input email dan password dari TextField.
    final TextEditingController emailC = TextEditingController();
    final TextEditingController passwordC = TextEditingController();
    final TextEditingController confirmpasswordC = TextEditingController();
    final TextEditingController nameC = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    // Fungsi untuk mendaftarkan akun pengguna baru ke database SQLite.
    void register() async {
      final user = emailC.text.trim();
      final pass = passwordC.text;
      final name = nameC.text.trim();

      // Validasi dasar bahwa inputan tidak boleh kosong.
      if (user.isEmpty || pass.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Isi semua field!')));
        return;
      }

      // Membuat objek UserModelSQL dari input form.
      final pengguna = UserModelSQL(email: user, password: pass, nama: name);

      // Menyimpan data pengguna ke database SQLite melalui DBHelper.
      bool success = await DBHelper().registerUser(pengguna);

      if (!mounted) return;

      // Menampilkan notifikasi SnackBar sesuai hasil pendaftaran.
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Akun berhasil dibuat')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar!')));
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        title: Text("Phintar", style: AppTextStyle.judul),
        backgroundColor: AppTheme.backgroundPrimary,
        shape: Border(bottom: BorderSide(color: AppTheme.textColor, width: 1)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Daftar Akun Anda", style: AppTextStyle.judul),
                    Text(
                      "Mulai perjalanan sains anda.",
                      style: AppTextStyle.subjudul,
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 600,
                          width: 500,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.textColor),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                Container(
                                  child: buildCustomTextField(
                                    controller: nameC,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Username tidak boleh kosong";
                                      } else if (value.length < 3) {
                                        return "Username harus menarik";
                                      }
                                      return null; // Input valid
                                    },
                                    hintText: "Anda ingin dikenal sebagai",
                                    prefixIcon: Icons.person,
                                  ),
                                ),
                                SizedBox(height: 10),
                                buildCustomTextField(
                                  controller: emailC,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Email tidak boleh kosong";
                                    } else if (!value.contains('@')) {
                                      return "Email tidak valid";
                                    }
                                    return null; // Input valid
                                  },
                                  hintText: "Daftarkan email anda",
                                  prefixIcon: Icons.mail_outline,
                                ),
                                SizedBox(height: 10),
                                buildCustomTextField(
                                  controller: passwordC,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Kata sandi tidak boleh kosong";
                                    } else if (value.length < 8) {
                                      return "Kata sandi kurang dari 8 karakter";
                                    }
                                    return null; // Input valid
                                  },
                                  hintText: "Masukan kata sandi anda",
                                  prefixIcon: Icons.lock_outline,
                                ),
                                SizedBox(height: 10),
                                buildCustomTextField(
                                  controller: confirmpasswordC,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Konfirmasi password tidak boleh kosong";
                                    } else if (value != passwordC.text) {
                                      return "Kata sandi tidak cocok";
                                    }
                                    return null; // Input valid
                                  },
                                  hintText: "Konfirmasi kata sandi anda",
                                  prefixIcon: Icons.lock_outline,
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      register();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(168, 30),
                                    backgroundColor: AppTheme.bottonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Text(
                                    "Daftar",
                                    style: AppTextStyle.botttonText,
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    bottom: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsGeometry.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          "Atau daftar dengan",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          register();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(168, 30),
                                        backgroundColor: AppTheme.bottonColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            AppImages.googleIcon,
                                            width:
                                                18, // <-- TAMBAHKAN INI. Sesuaikan angkanya (misal 16-20)
                                            height: 18,
                                            fit: BoxFit.contain,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Google",
                                            style: AppTextStyle.botttonText,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          register();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(168, 30),
                                        backgroundColor: AppTheme.bottonColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            AppImages.googleIcon,
                                            width:
                                                18, // <-- TAMBAHKAN INI. Sesuaikan angkanya (misal 16-20)
                                            height: 18,
                                            fit: BoxFit.contain,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Facebook",
                                            style: AppTextStyle.botttonText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah Punya Akun?",
                          style: AppTextStyle.bottomText,
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            context.pushReplacement(LoginPagePhintar());
                          },
                          child: Text("Masuk", style: AppTextStyle.progresText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.textColor),
        prefixIcon: Icon(prefixIcon, color: AppTheme.textColor),
      ),
    );
  }
}
