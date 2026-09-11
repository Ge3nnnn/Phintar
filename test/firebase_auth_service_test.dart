import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phintar/services/firebase_auth_service.dart';

void main() {
  group('FirebaseAuthService Email Validation', () {
    test('valid email formats return true', () {
      expect(FirebaseAuthService.isValidEmail('test@example.com'), isTrue);
      expect(FirebaseAuthService.isValidEmail('user.name@domain.co.id'), isTrue);
      expect(FirebaseAuthService.isValidEmail('student123@phintar.edu'), isTrue);
      expect(FirebaseAuthService.isValidEmail('  user@gmail.com  '), isTrue);
    });

    test('invalid email formats return false', () {
      expect(FirebaseAuthService.isValidEmail(''), isFalse);
      expect(FirebaseAuthService.isValidEmail('   '), isFalse);
      expect(FirebaseAuthService.isValidEmail('invalid'), isFalse);
      expect(FirebaseAuthService.isValidEmail('invalid@'), isFalse);
      expect(FirebaseAuthService.isValidEmail('@domain.com'), isFalse);
      expect(FirebaseAuthService.isValidEmail('user@domain'), isFalse);
      expect(FirebaseAuthService.isValidEmail('user@.com'), isFalse);
      expect(FirebaseAuthService.isValidEmail('user name@domain.com'), isFalse);
    });
  });

  group('FirebaseAuthService Error Messages', () {
    test('maps invalid-email correctly', () {
      final error = FirebaseAuthException(code: 'invalid-email');
      final message = FirebaseAuthService.getErrorMessage(error);
      expect(message, contains('Format alamat email tidak valid'));
    });

    test('maps user-not-found correctly', () {
      final error = FirebaseAuthException(code: 'user-not-found');
      final message = FirebaseAuthService.getErrorMessage(error);
      expect(message, contains('tidak ditemukan'));
    });

    test('maps wrong-password and invalid-credential correctly', () {
      final error1 = FirebaseAuthException(code: 'wrong-password');
      final error2 = FirebaseAuthException(code: 'invalid-credential');
      expect(FirebaseAuthService.getErrorMessage(error1), contains('salah'));
      expect(FirebaseAuthService.getErrorMessage(error2), contains('salah'));
    });

    test('maps email-already-in-use correctly', () {
      final error = FirebaseAuthException(code: 'email-already-in-use');
      final message = FirebaseAuthService.getErrorMessage(error);
      expect(message, contains('sudah terdaftar'));
    });

    test('maps invalid-action-code and expired-action-code correctly', () {
      final errorInvalid = FirebaseAuthException(code: 'invalid-action-code');
      expect(
        FirebaseAuthService.getErrorMessage(errorInvalid),
        contains('Kode atau tautan verifikasi salah'),
      );

      final errorExpired = FirebaseAuthException(code: 'expired-action-code');
      expect(
        FirebaseAuthService.getErrorMessage(errorExpired),
        contains('kedaluwarsa'),
      );
    });
  });

  group('FirebaseAuthService extractActionCode', () {
    test('extracts oobCode parameter from full Firebase action URL', () {
      const url =
          'https://phintar-edu-6cd66.firebaseapp.com/__/auth/action?mode=resetPassword&oobCode=SAMPLE_RESET_CODE_123&apiKey=AIzaSy...';
      expect(
        FirebaseAuthService.extractActionCode(url),
        equals('SAMPLE_RESET_CODE_123'),
      );
    });

    test('extracts oobCode when formatted with substring', () {
      const text = 'Reset link: oobCode=ABC_XYZ_999&continue=true';
      expect(
        FirebaseAuthService.extractActionCode(text),
        equals('ABC_XYZ_999'),
      );
    });

    test('returns clean trimmed code when code itself is passed', () {
      const directCode = '  ABCDEFGHIJKLMN12345  ';
      expect(
        FirebaseAuthService.extractActionCode(directCode),
        equals('ABCDEFGHIJKLMN12345'),
      );
    });

    test('returns empty string on empty input', () {
      expect(FirebaseAuthService.extractActionCode(''), equals(''));
      expect(FirebaseAuthService.extractActionCode('   '), equals(''));
    });
  });
}
