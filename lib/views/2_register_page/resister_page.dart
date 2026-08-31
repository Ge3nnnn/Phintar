import 'package:blabla/widgets/app_textfield.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:blabla/widgets/app_button.dart';
import 'package:blabla/constants/app_images.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/data/database/db_helper.dart';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/widgets/extention/navigator.dart';
import 'package:blabla/models/user_model_login.dart';
import 'package:blabla/views/1_loginpage/login_page_phintar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RegisterScreenPhintar extends StatefulWidget {
  const RegisterScreenPhintar({super.key});

  @override
  State<RegisterScreenPhintar> createState() => _RegisterScreenPhintarState();
}

class _RegisterScreenPhintarState extends State<RegisterScreenPhintar> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    _confirmPasswordC.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _register() async {
    final user = UserModelSQL(
      email: _emailC.text.trim(),
      password: _passwordC.text,
      nama: _nameC.text.trim(),
    );
    final success = await DBHelper().registerUser(user);

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sudah terdaftar!'),
          backgroundColor: AppTheme.merah,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    final pageNavigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundSecondary,
        title: Text(
          "YEEAAYYY, ${_nameC.text} berhasil mendaftar!! 🎉🎉🎉🎉",
          textAlign: TextAlign.center,
          style: AppTextStyle.normalText2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/Animations/congraturation.json"),
            Text(
              "Ayo mulai perjalanan sains ${_nameC.text}!!",
              style: AppTextStyle.normalText2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              pageNavigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPagePhintar()),
              );
            },
            child: Text("Mulai Sekarang", style: AppTextStyle.normalText2),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text("Daftar Akun Anda", style: AppTextStyle.judul),
                Text(
                  "Mulai perjalanan sains anda.",
                  style: AppTextStyle.subjudul,
                ),
                const SizedBox(height: 20),
                _buildFormCard(),
                const SizedBox(height: 20),
                _buildLoginLink(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI Components
  // ---------------------------------------------------------------------------

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.glassBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder, width: 1.5),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
              label: "Nama Pengguna",
              controller: _nameC,
              hint: "Anda ingin dikenal sebagai",
              icon: Icons.person,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "Username tidak boleh kosong";
                }
                if (v.length < 3) return "Username terlalu pendek";
                return null;
              },
            ),
            _buildFormField(
              label: "Email",
              controller: _emailC,
              hint: "Daftarkan email anda",
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return "Email tidak boleh kosong";
                if (!v.contains('@')) return "Email tidak valid";
                return null;
              },
            ),
            _buildFormField(
              label: "Kata Sandi",
              controller: _passwordC,
              hint: "Masukan kata sandi anda",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "Kata sandi tidak boleh kosong";
                }
                if (v.length < 8) return "Minimal 8 karakter";
                return null;
              },
            ),
            _buildFormField(
              label: "Konfirmasi Kata Sandi",
              controller: _confirmPasswordC,
              hint: "Konfirmasi kata sandi anda",
              icon: Icons.lock_outline,
              obscureText: true,
              isLast: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "Konfirmasi password wajib diisi";
                }
                if (v != _passwordC.text) return "Kata sandi tidak cocok";
                return null;
              },
            ),
            const SizedBox(height: 25),
            CustomElevatedButton(
              text: "Daftar",
              width: double.infinity,
              onPressed: () {
                if (_formKey.currentState!.validate()) _register();
              },
            ),
            _buildDivider(),
            _buildSocialButtons(),
          ],
        ),
      ),
    );
  }

  /// Reusable labeled form field — reduces repetition across all four fields.
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.normalText2),
        const SizedBox(height: 5),
        CustomTextFields(
          controller: controller,
          hintText: hint,
          prefixIcon: icon,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
        ),
        if (!isLast) const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Atau daftar dengan",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ),
          const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomElevatedButton(
            iconAsset: AppImages.googleIcon,
            text: "Google",
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Sudah Punya Akun?", style: AppTextStyle.bottomText),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => context.pushReplacement(const LoginPagePhintar()),
          child: Text("Masuk", style: AppTextStyle.progresText),
        ),
      ],
    );
  }
}
