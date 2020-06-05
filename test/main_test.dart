import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/authentication-page.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUser extends Mock implements FirebaseUser {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockAuthResult extends Mock implements AuthResult {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  final _googleSignIn = MockGoogleSignIn();
  final _account = MockGoogleSignInAccount();
  final _authentication = MockGoogleSignInAuthentication();

  final _firebaseAuth = MockFirebaseAuth();
  final _authResult = MockAuthResult();
  final _expectedUser = MockUser();

  GetIt.I.registerSingleton<GoogleSignIn>(_googleSignIn);
  GetIt.I.registerSingleton<FirebaseAuth>(_firebaseAuth);
  GetIt.I.registerSingleton<AuthenticationService>(AuthenticationService());
  GetIt.I.registerSingleton<UserService>(UserService());

  test('Login skip tests google', () async {
    when(_googleSignIn.signIn())
        .thenAnswer((realInvocation) => Future.value(_account));

    when(_account.authentication)
        .thenAnswer((realInvocation) => Future.value(_authentication));

    when(_firebaseAuth.signInWithCredential(any))
        .thenAnswer((realInvocation) => Future.value(_authResult));

    when(_authResult.user).thenReturn(_expectedUser);

    SharedPreferences.setMockInitialValues({}); //set values here
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('mode', 'google');

    AuthenticationPageState authPageG = new AuthenticationPageState();
    authPageG.loginSkip().then((result) => expect(result, true));
  });

  test('Login skip tests email/password', () async {
    when(_account.authentication)
        .thenAnswer((realInvocation) => Future.value(_authentication));

    when(_firebaseAuth.signInWithCredential(any))
        .thenAnswer((realInvocation) => Future.value(_authResult));

    when(_authResult.user).thenReturn(_expectedUser);

    SharedPreferences.setMockInitialValues({}); //set values here
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("mode", "emailpassword");
    prefs.setString("email", "nouveau@new.new");
    prefs.setString("password", "test123");

    when(_firebaseAuth.signInWithEmailAndPassword(
            email: prefs.get("email"), password: prefs.get("password")))
        .thenAnswer((realInvocation) => Future.value(_authResult));
    when(_authResult.user).thenReturn(_expectedUser);

    AuthenticationPageState authPageF = new AuthenticationPageState();
    authPageF.loginSkip().then((result) => expect(result, true));
  });
}
