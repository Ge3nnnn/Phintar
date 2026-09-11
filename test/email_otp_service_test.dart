import 'package:flutter_test/flutter_test.dart';
import 'package:phintar/services/email_otp_service.dart';

void main() {
  setUp(() {
    EmailOtpService.initialize();
    EmailOtpService().clear();
  });

  tearDown(() {
    EmailOtpService().clear();
  });

  group('EmailOtpService Tests', () {
    test('sendOtp with empty email should fail', () async {
      final service = EmailOtpService();
      final result = await service.sendOtp(email: '');

      expect(result['success'], isFalse);
      expect(result['message'], contains('tidak boleh kosong'));
    });

    test('sendOtp in mock mode generates a valid 6-digit OTP', () async {
      final service = EmailOtpService();
      final result = await service.sendOtp(email: 'siswa@phintar.edu');

      expect(result['success'], isTrue);
      expect(result['otp'], isNotNull);

      final otp = result['otp'] as String;
      expect(otp.length, equals(6));
      expect(int.tryParse(otp), isNotNull);
      expect(service.currentEmail, equals('siswa@phintar.edu'));
    });

    test('verifyOtp returns success when OTP matches', () async {
      final service = EmailOtpService();
      final result = await service.sendOtp(email: 'user@example.com');
      final otp = result['otp'] as String;

      final status = service.verifyOtp(enteredOtp: otp);
      expect(status, equals(OtpVerificationStatus.success));
    });

    test('verifyOtp returns invalid when OTP is wrong', () async {
      final service = EmailOtpService();
      await service.sendOtp(email: 'user@example.com');

      final status = service.verifyOtp(enteredOtp: '000000');
      expect(status, equals(OtpVerificationStatus.invalid));
    });

    test('verifyOtp returns invalid for short or empty OTP', () async {
      final service = EmailOtpService();
      await service.sendOtp(email: 'user@example.com');

      expect(
        service.verifyOtp(enteredOtp: ''),
        equals(OtpVerificationStatus.invalid),
      );
      expect(
        service.verifyOtp(enteredOtp: '123'),
        equals(OtpVerificationStatus.invalid),
      );
    });

    test('verifyOtp returns notSent if no OTP was dispatched', () {
      final service = EmailOtpService();
      final status = service.verifyOtp(enteredOtp: '123456');
      expect(status, equals(OtpVerificationStatus.notSent));
    });

    test('clear() properly resets active OTP state', () async {
      final service = EmailOtpService();
      await service.sendOtp(email: 'test@phintar.id');
      expect(service.currentEmail, isNotNull);

      service.clear();
      expect(service.currentEmail, isNull);
      expect(service.currentOtpForTesting, isNull);
    });

    test(
      'isEmailVerified tracks verified emails after successful OTP verification',
      () async {
        final service = EmailOtpService();
        final result = await service.sendOtp(email: 'siswa@phintar.edu');
        final otp = result['otp'] as String;

        expect(service.isEmailVerified('siswa@phintar.edu'), isFalse);
        final status = service.verifyOtp(enteredOtp: otp);
        expect(status, equals(OtpVerificationStatus.success));
        expect(service.isEmailVerified('siswa@phintar.edu'), isTrue);
        expect(
          service.isEmailVerified('SISWA@PHINTAR.EDU'),
          isTrue,
        ); // case-insensitive
      },
    );
  });
}
