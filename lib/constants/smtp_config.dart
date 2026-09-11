import 'package:email_otp/email_otp.dart';

/// Konfigurasi Kredensial SMTP untuk Pengiriman Email Nyata (OTP).
///
/// Untuk menggunakan Google Mail (Gmail) sebagai pengirim OTP:
/// 1. Pastikan akun Google pengirim telah mengaktifkan 2-Step Verification (Verifikasi 2 Langkah).
/// 2. Buka https://myaccount.google.com/apppasswords
/// 3. Buat Sandi Aplikasi (App Password) baru (misal diberi nama "Phintar Edu").
/// 4. Salin 16 digit sandi yang dihasilkan (tanpa spasi) ke variabel [appPassword] di bawah ini.
/// 5. Masukkan alamat Gmail pengirim ke [senderEmail].
class SmtpConfig {
  /// Host server SMTP (default: Gmail SMTP)
  static const String host = 'smtp.gmail.com';

  /// Port SMTP (default: 587 untuk TLS)
  static const EmailPort emailPort = EmailPort.port587;

  /// Tipe keamanan (default: TLS)
  static const SecureType secureType = SecureType.tls;

  /// Alamat email pengirim (Gmail resmi Phintar atau Gmail pengembang)
  /// Ganti dengan email aktif Anda.
  static const String senderEmail = 'fasle.kresna12@gmail.com';

  /// 16 Digit Google App Password (Sandi Aplikasi)
  /// CATATAN: Jangan gunakan password login akun Google biasa.
  /// Dapatkan 16 digit sandi dari: https://myaccount.google.com/apppasswords
  /// Contoh: 'abcd efgh ijkl mnop' (bisa ditulis tanpa spasi: 'abcdefghijklmnop')
  static const String appPassword = '';

  /// Nama pengirim yang tampil di kotak masuk penerima
  static const String appName = 'Phintar Edu';

  /// Mengetahui apakah kredensial SMTP sudah diisi lengkap
  static bool get isConfigured =>
      senderEmail.trim().isNotEmpty &&
      appPassword.trim().isNotEmpty &&
      appPassword.trim() != 'MASUKKAN_16_DIGIT_APP_PASSWORD_DISINI';
}
