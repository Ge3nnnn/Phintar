import 'package:phintar/services/firebase_auth_service.dart';
import 'package:phintar/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:phintar/widgets/app_textfield.dart';
import 'package:phintar/widgets/app_bar.dart';
import 'package:phintar/widgets/app_button.dart';
import 'package:phintar/constants/app_images.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/widgets/extention/navigator.dart';
import 'package:phintar/views/1_loginpage/login_page_phintar.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameC.text.trim();
      final email = _emailC.text.trim();
      final password = _passwordC.text;

      await FirebaseAuthService().registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      final message = FirebaseAuthService.getErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.merah),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuthService().registerWithGoogle();
      if (!mounted) return;
      if (cred != null && cred.user != null) {
        if (!mounted) return;
        context.pushAndRemoveAll(const BottomNavBarPhintar());
      }
    } catch (e) {
      if (!mounted) return;
      final message = FirebaseAuthService.getErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.merah),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundSecondary,
        title: Text(
          "YEEAAYYY, ${_nameC.text.trim()} berhasil mendaftar!! 🎉🎉🎉🎉",
          textAlign: TextAlign.center,
          style: AppTextStyle.normalText2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/Animations/congraturation.json"),
            Text(
              "Ayo mulai perjalanan sains ${_nameC.text.trim()}!!",
              style: AppTextStyle.normalText2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pushAndRemoveAll(const BottomNavBarPhintar());
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
                if (v == null || v.trim().isEmpty) return "Email tidak boleh kosong";
                if (!FirebaseAuthService.isValidEmail(v.trim())) {
                  return "Format email tidak valid (contoh: nama@email.com)";
                }
                return null;
              },
            ),
            _buildFormField(
              label: "Kata Sandi",
              controller: _passwordC,
              hint: "Masukan kata sandi anda",
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
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
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
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
              text: _isLoading ? "Mendaftarkan..." : "Daftar",
              width: double.infinity,
              onPressed: _isLoading
                  ? () {}
                  : () {
                      if (_formKey.currentState!.validate()) _register();
                    },
            ),
            _buildDivider(),
            _buildSocialButtons(),
            const SizedBox(height: 16),
            _buildLoginLink(),
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
    Widget? suffixIcon,
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
          suffixIcon: suffixIcon,
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
            text: "Daftar dengan Google",
            backgroundColor: AppTheme.backgroundSecondary,
            onPressed: _isLoading ? () {} : _signUpWithGoogle,
          ),
        ),
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
