import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/share_service.dart';
import 'package:MobileOne/services/loyalty_cards_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements FirebaseUser {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockAuthResult extends Mock implements AuthResult {}

class AnalyticsServiceMock extends Mock implements AnalyticsService {}

class ColorServiceMock extends Mock implements ColorService {}

class ShareServiceMock extends Mock implements ShareService {}

class LoyaltyCardsProviderMock extends Mock implements LoyaltyCardsProvider {}

class LoyaltyCardsServiceMock extends Mock implements LoyaltyCardsService {}

final service = AuthenticationService();

void main() {
  group('googleSignIn behaviors', () {
    //Google
    final _googleSignIn = MockGoogleSignIn();
    final _account = MockGoogleSignInAccount();
    final _authentication = MockGoogleSignInAuthentication();

    // Firebase
    final _firebaseAuth = MockFirebaseAuth();
    final _authResult = MockAuthResult();
    final _expectedUser = MockUser();

    GetIt.I.registerSingleton<GoogleSignIn>(_googleSignIn);
    GetIt.I.registerSingleton<FirebaseAuth>(_firebaseAuth);

    final _analyticsService = AnalyticsServiceMock();
    GetIt.I.registerSingleton<AnalyticsService>(_analyticsService);

    final _colorService = ColorServiceMock();
    GetIt.I.registerSingleton<ColorService>(_colorService);
    final _loyaltycardsProvider = LoyaltyCardsProviderMock();
    GetIt.I.registerSingleton<LoyaltyCardsProvider>(_loyaltycardsProvider);
    final _loyaltycardsService = LoyaltyCardsServiceMock();
    GetIt.I.registerSingleton<LoyaltyCardsService>(_loyaltycardsService);

    final _shareService = ShareServiceMock();
    GetIt.I.registerSingleton<ShareService>(_shareService);

    /*test('googleSignIn error', () async {
      //GIVEN
      // Google
      when(_googleSignIn.signIn()).thenThrow(PlatformException(code: "ERROR"));

      //WHEN
      final user = await service.googleSignIn();

      //THEN
      expect(user, null);
    });

    test('googleSignIn abort', () async {
      //GIVEN
      // Google
      when(_googleSignIn.signIn()).thenThrow(PlatformException(code: "ABORT"));

      //WHEN
      final user = await service.googleSignIn();

      //THEN
      expect(user, null);
    });*/

    test('googleSignIn successful', () async {
      //GIVEN
      // Google
      when(_googleSignIn.signIn())
          .thenAnswer((realInvocation) => Future.value(_account));

      when(_account.authentication)
          .thenAnswer((realInvocation) => Future.value(_authentication));

      // Firebase
      when(_firebaseAuth.signInWithCredential(any))
          .thenAnswer((realInvocation) => Future.value(_authResult));

      when(_authResult.user).thenReturn(_expectedUser);

      //WHEN
      final user = await service.googleSignIn();

      //THEN
      expect(user, _expectedUser);
    });
  });
}
