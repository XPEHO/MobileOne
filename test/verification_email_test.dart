import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class AnalyticsServiceMock extends Mock implements AnalyticsService {}

class MockUser extends Mock implements User {}

final service = AuthenticationService();

void main() {
  group('Verification email sending', () {
    final _firebaseAuth = MockFirebaseAuth();
    final _googleSignIn = MockGoogleSignIn();
    final _firebaseUser = MockUser();

    GetIt.I.registerSingleton<FirebaseAuth>(_firebaseAuth);
    GetIt.I.registerSingleton<User>(_firebaseUser);

    GetIt.I.registerSingleton<GoogleSignIn>(_googleSignIn);

    final _analyticsService = AnalyticsServiceMock();
    GetIt.I.registerSingleton<AnalyticsService>(_analyticsService);
    test('Email sent successfully', () async {
      //GIVEN
      bool _result;

      //WHEN
      _result = await service.sendVerificationEmail(_firebaseUser);
      //THEN
      expect(_result, true);
    });
  });
}
