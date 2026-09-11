import 'dart:async';
import 'dart:math';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/foundation.dart';
import 'package:phintar/constants/smtp_config.dart';

/// Status hasil verifikasi kode OTP
enum OtpVerificationStatus {
  success,
  invalid,
  expired,
  notSent,
}

/// Service untuk mengelola pengiriman, verifikasi, dan masa berlaku OTP via Email.
class EmailOtpService {
  static final EmailOtpService _instance = EmailOtpService._internal();
  factory EmailOtpService() => _instance;
  EmailOtpService._internal();

  String? _currentEmail;
  DateTime? _otpSentAt;
  String? _activeOtp;
  static bool _isSmtpConfigured = false;

  /// Mode fallback simulasi saat SMTP belum diatur (berguna untuk pengujian unit test).
  static bool allowMockFallback = true;

  /// Daftar email yang telah lolos verifikasi OTP
  final Set<String> _verifiedEmails = <String>{};

  /// Inisialisasi awal konfigurasi Email OTP.
  /// Secara otomatis memuat kredensial dari [SmtpConfig].
  static void initialize() {
    EmailOTP.config(
      appName: SmtpConfig.appName,
      appEmail: SmtpConfig.senderEmail,
      otpLength: 6,
      otpType: OTPType.numeric,
      expiry: 300000, // 5 menit (300.000 ms)
      emailTheme: EmailTheme.v5,
    );

    if (SmtpConfig.isConfigured) {
      configureSmtp(
        host: SmtpConfig.host,
        username: SmtpConfig.senderEmail,
        password: SmtpConfig.appPassword,
        emailPort: SmtpConfig.emailPort,
        secureType: SmtpConfig.secureType,
        appName: SmtpConfig.appName,
        appEmail: SmtpConfig.senderEmail,
      );
      debugPrint(
        '[EmailOtpService] SMTP siap digunakan dengan pengirim: ${SmtpConfig.senderEmail}',
      );
    } else {
      _isSmtpConfigured = false;
      debugPrint(
        '[EmailOtpService] Perhatian: SmtpConfig.appPassword belum diisi. Pengiriman email langsung ke inbox belum aktif.',
      );
    }
  }

  /// Mengonfigurasi kredensial SMTP untuk pengiriman email langsung ke kotak masuk pengguna.
  static void configureSmtp({
    required String host,
    required String username,
    required String password,
    EmailPort emailPort = EmailPort.port587,
    SecureType secureType = SecureType.tls,
    String? appEmail,
    String? appName,
  }) {
    EmailOTP.config(
      appName: appName ?? SmtpConfig.appName,
      appEmail: appEmail ?? username,
      otpLength: 6,
      otpType: OTPType.numeric,
      expiry: 300000, // 5 menit
      emailTheme: EmailTheme.v5,
    );

    EmailOTP.setSMTP(
      emailPort: emailPort,
      secureType: secureType,
      host: host,
      username: username,
      password: password,
    );
    _isSmtpConfigured = true;
    debugPrint('[EmailOtpService] SMTP berhasil dikonfigurasi ke server $host.');
  }

  /// Mengetahui apakah kredensial SMTP sudah diatur
  static bool get isSmtpConfigured => _isSmtpConfigured;

  /// Email tujuan aktif yang saat ini sedang dalam proses verifikasi OTP
  String? get currentEmail => _currentEmail;

  /// Waktu ketika OTP terakhir dikirim
  DateTime? get otpSentAt => _otpSentAt;

  /// Kode OTP aktif (hanya digunakan untuk keperluan debugging / pengujian lokal)
  String? get currentOtpForTesting => _activeOtp;

  /// Memeriksa apakah suatu email telah diverifikasi dengan kode OTP
  bool isEmailVerified(String email) {
    return _verifiedEmails.contains(email.trim().toLowerCase());
  }

  /// Menandai email sebagai terverifikasi
  void markEmailVerified(String email) {
    _verifiedEmails.add(email.trim().toLowerCase());
  }

  /// Menghapus status verifikasi untuk suatu email
  void revokeEmailVerification(String email) {
    _verifiedEmails.remove(email.trim().toLowerCase());
  }

  /// Menghasilkan kode OTP 6-digit numerik acak
  String _generateRandomOtp() {
    final rand = Random.secure();
    final code = 100000 + rand.nextInt(900000);
    return code.toString();
  }

  /// Mengirimkan kode OTP ke email tujuan.
  ///
  /// Jika SMTP telah dikonfigurasi via [SmtpConfig] atau [configureSmtp], email akan dikirim langsung
  /// melalui server SMTP Gmail ke kotak masuk penerima.
  /// Jika belum, pesan informatif akan dikembalikan agar kredensial diisi.
  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      return {
        'success': false,
        'message': 'Alamat email tidak boleh kosong.',
      };
    }

    _currentEmail = cleanEmail;
    _otpSentAt = DateTime.now();

    // Jika SMTP aktif, kirim email secara nyata
    if (_isSmtpConfigured) {
      try {
        final success = await EmailOTP.sendOTP(email: cleanEmail);
        if (success) {
          _activeOtp = EmailOTP.getOTP();
          debugPrint(
            '[EmailOtpService] Email OTP berhasil terkirim ke $cleanEmail (Kode: $_activeOtp)',
          );
          return {
            'success': true,
            'message': 'Kode OTP telah dikirim ke kotak masuk $cleanEmail.',
            'otp': _activeOtp,
            'isMock': false,
          };
        } else {
          final error = EmailOTP.lastError ?? 'Gagal mengirim email OTP.';
          debugPrint('[EmailOtpService Error] $error');

          String humanError = error;
          if (error.contains('535') || error.contains('BadCredentials') || error.contains('Username and Password not accepted')) {
            humanError = 'Autentikasi SMTP gagal: Pastikan Google App Password (16 digit) benar di lib/constants/smtp_config.dart.';
          } else if (error.contains('Connection') || error.contains('SocketException')) {
            humanError = 'Gagal terhubung ke server SMTP Gmail. Periksa koneksi internet Anda.';
          }

          return {
            'success': false,
            'message': humanError,
            'isMock': false,
          };
        }
      } catch (e) {
        debugPrint('[EmailOtpService Exception] $e');
        return {
          'success': false,
          'message': 'Terjadi kesalahan saat mengirim OTP: $e',
          'isMock': false,
        };
      }
    } else {
      // SMTP belum dikonfigurasi
      if (allowMockFallback) {
        await EmailOTP.sendOTP(email: cleanEmail);
        _activeOtp = EmailOTP.getOTP() ?? _generateRandomOtp();

        debugPrint('=======================================================');
        debugPrint('[Phintar OTP] Mode Simulasi Pengiriman Email:');
        debugPrint('Tujuan: $cleanEmail');
        debugPrint('Kode OTP: $_activeOtp');
        debugPrint('Keterangan: Untuk pengiriman nyata ke kotak masuk email,');
        debugPrint('masukkan 16-digit Google App Password di lib/constants/smtp_config.dart');
        debugPrint('=======================================================');

        return {
          'success': true,
          'message':
              'Kode OTP simulasi telah dibuat untuk $cleanEmail (Periksa konsol/notifikasi).',
          'otp': _activeOtp,
          'isMock': true,
          'requiresSmtpConfig': true,
        };
      } else {
        return {
          'success': false,
          'requiresSmtpConfig': true,
          'message':
              'Pengiriman email belum aktif: Silakan masukkan 16 digit Google App Password di lib/constants/smtp_config.dart.',
          'isMock': false,
        };
      }
    }
  }

  /// Mengirim ulang kode OTP ke email yang sama
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    return sendOtp(email: email);
  }

  /// Memverifikasi kode OTP yang dimasukkan oleh pengguna.
  OtpVerificationStatus verifyOtp({required String enteredOtp}) {
    if (_currentEmail == null) {
      return OtpVerificationStatus.notSent;
    }

    final trimmed = enteredOtp.trim();
    if (trimmed.isEmpty || trimmed.length < 4) {
      return OtpVerificationStatus.invalid;
    }

    // Cek kadaluarsa (5 menit = 300 detik)
    if (_otpSentAt != null) {
      final difference = DateTime.now().difference(_otpSentAt!);
      if (difference.inMinutes >= 5) {
        debugPrint('[EmailOtpService] OTP telah kedaluwarsa.');
        return OtpVerificationStatus.expired;
      }
    }

    if (EmailOTP.isOtpExpired()) {
      return OtpVerificationStatus.expired;
    }

    final matchesPackage = EmailOTP.verifyOTP(otp: trimmed);
    final matchesActive = _activeOtp != null && _activeOtp == trimmed;

    if (matchesPackage || matchesActive) {
      debugPrint('[EmailOtpService] Verifikasi OTP berhasil.');
      if (_currentEmail != null) {
        markEmailVerified(_currentEmail!);
      }
      return OtpVerificationStatus.success;
    } else {
      debugPrint('[EmailOtpService] Kode OTP tidak sesuai.');
      return OtpVerificationStatus.invalid;
    }
  }

  /// Membersihkan sesi OTP setelah selesai digunakan
  void clear() {
    _currentEmail = null;
    _otpSentAt = null;
    _activeOtp = null;
    _verifiedEmails.clear();
  }
}
