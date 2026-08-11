import 'package:blabla/database/db_helper.dart';
import 'package:blabla/models/user_model_colour_palatte.dart';
import 'package:blabla/models/user_model_login.dart';
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
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text("Daftar Akun", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.backgroundPrimary,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              buildCustomTextField(
                controller: passwordC,
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
              buildCustomTextField(
                controller: nameC,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Username tidak boleh kosong";
                  } else if (value.length < 3) {
                    return "Username harus menarik";
                  }
                  return null; // Input valid
                },
                hintText: "Anda ingin dikelan sebagai",
                prefixIcon: Icons.person,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    register();
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(168, 30),
                  backgroundColor: AppColors.bottonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text("Daftar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
        hintStyle: TextStyle(color: AppColors.textColor),
        prefixIcon: Icon(prefixIcon, color: AppColors.textColor),
      ),
    );
  }
}
