import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class AnalyticsServiceMock extends Mock implements AnalyticsService {}

class ColorServiceMock extends Mock implements ColorService {}

final service = AuthenticationService();

void main() {
  group('Forgotten password', () {
    final _firebaseAuth = MockFirebaseAuth();
    final _googleSignIn = MockGoogleSignIn();

    GetIt.I.registerSingleton<FirebaseAuth>(_firebaseAuth);
    GetIt.I.registerSingleton<GoogleSignIn>(_googleSignIn);

    final _analyticsService = AnalyticsServiceMock();
    GetIt.I.registerSingleton<AnalyticsService>(_analyticsService);

    final _colorService = ColorServiceMock();
    GetIt.I.registerSingleton<ColorService>(_colorService);

    test('Email sent successfully', () async {
      //GIVEN
      String _result;
      //WHEN
      _result = await service.resetPassword("test@test.test");
      //THEN
      expect(_result, "success");
    });

    test('Bad email format', () async {
      //GIVEN
      String _result;
      //WHEN
      when(_firebaseAuth.sendPasswordResetEmail(email: "test@test"))
          .thenThrow(PlatformException(code: "ERROR_INVALID_EMAIL"));

      _result = await service.resetPassword("test@test");
      //THEN
      expect(_result, "format_error");
    });

    test('Email not found', () async {
      //GIVEN
      String _result;
      //WHEN
      when(_firebaseAuth.sendPasswordResetEmail(email: "test@test.test"))
          .thenThrow(PlatformException(code: "ERROR_USER_NOT_FOUND"));

      _result = await service.resetPassword("test@test.test");
      //THEN
      expect(_result, "email_does_not_exist");
    });
  });
}
