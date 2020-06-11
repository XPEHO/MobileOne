import 'package:MobileOne/pages/authentication-page.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class UserServiceMock extends Mock implements UserService {}

class AuthenticationServiceMock extends Mock implements AuthenticationService {}

class PreferencesServiceMock extends Mock implements PreferencesService {}

main() {
  group('login skip', () {
    GetIt.I.registerSingleton<UserService>(UserServiceMock());

    var _authService = AuthenticationServiceMock();
    GetIt.I.registerSingleton<AuthenticationService>(_authService);

    var _prefService = PreferencesServiceMock();
    GetIt.I.registerSingleton<PreferencesService>(_prefService);

    var _authenticationPageState = AuthenticationPageState();

    test('login skip should automatically log in on user/pwd mode', () async {
      //GIVEN

      when(_prefService.isEmailPasswordMode()).thenReturn(true);

      var _email = "toto.titi@tutu.com";
      when(_prefService.getEmail()).thenReturn(_email);

      var _password = "1234567";
      when(_prefService.getPassword()).thenReturn(_password);

      //WHEN
      var result = await _authenticationPageState.loginSkip();

      //THEN
      expect(true, result);
      verify(_authService.signIn(_email, _password));
      verifyNever(_authService.googleSignInSilently());
    });

    test('login skip should automatically log in on google mode', () async {
      //GIVEN

      when(_prefService.isEmailPasswordMode()).thenReturn(false);
      when(_prefService.isGoogleMode()).thenReturn(true);

      //WHEN
      var result = await _authenticationPageState.loginSkip();

      //THEN
      expect(true, result);
      verifyNever(_authService.signIn(any, any));
      verify(_authService.googleSignInSilently());
    });

    test('login skip should not skip if no mode registered', () async {
      //GIVEN

      when(_prefService.isEmailPasswordMode()).thenReturn(false);
      when(_prefService.isGoogleMode()).thenReturn(false);

      //WHEN
      var result = await _authenticationPageState.loginSkip();

      //THEN
      expect(false, result);
      verifyNever(_authService.signIn(any, any));
      verifyNever(_authService.googleSignInSilently());
    });
  });
}
