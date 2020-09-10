import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final _authService = GetIt.I.get<FirebaseAuth>();
  final _googleService = GetIt.I.get<GoogleSignIn>();
  final _userService = GetIt.I.get<UserService>();
  var _analytics = GetIt.I.get<AnalyticsService>();
  Future<User> googleSignInSilently() async {
    final GoogleSignInAccount googleUser =
        await _googleService.signInSilently();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return (await _authService.signInWithCredential(credential)).user;
    }
    return null;
  }

  Future<User> googleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleService.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return (await _authService.signInWithCredential(credential)).user;
  }

  Future<String> signIn(String email, String password) async {
    _analytics.loging();
    try {
      UserCredential result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _userService.user = result.user;
    } catch (e) {
      return e.code;
    }
    return "success";
  }

  Future<String> register(String email, String password) async {
    try {
      await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e.code == "invalid-email") {
        return "format_error";
      } else if (e.code == "email-already-in-use") {
        return "email_already_exist";
      } else {
        return e.message;
      }
    }
    return "success";
  }

  Future<bool> sendVerificationEmail(User _user) async {
    _analytics.sendAnalyticsEvent("email_verification");
    try {
      await _user.sendEmailVerification();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
      return "success";
    } catch (e) {
      if (e.code == "ERROR_INVALID_EMAIL") {
        return "format_error";
      } else if (e.code == "ERROR_USER_NOT_FOUND") {
        return "email_does_not_exist";
      } else {
        return e.message;
      }
    }
  }

  Future<void> signOut(User user) async {
    await _authService.signOut();
    user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("email");
    prefs.remove("password");
    prefs.remove("mode");
  }

  Future<String> changePassword(User user, String password) async {
    try {
      await user.updatePassword(password);
      return "success";
    } catch (e) {
      return e.code;
    }
  }

  Future<String> reconnectUser(User user, String email, String password) async {
    AuthCredential credentials = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    try {
      await user.reauthenticateWithCredential(credentials);
      return "success";
    } catch (e) {
      return e.code;
    }
  }
}
