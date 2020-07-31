import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final _authService = GetIt.I.get<FirebaseAuth>();
  final _googleService = GetIt.I.get<GoogleSignIn>();

  Future<FirebaseUser> googleSignInSilently() async {
    final GoogleSignInAccount googleUser =
        await _googleService.signInSilently();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return (await _authService.signInWithCredential(credential)).user;
    }
    return null;
  }

  Future<FirebaseUser> googleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleService.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return (await _authService.signInWithCredential(credential)).user;
  }

  Future<FirebaseUser> signIn(String email, String password) async {
    FirebaseUser _user = (await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
    return _user;
  }

  Future<String> register(String email, String password) async {
    try {
      await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } catch (e) {
      if (e.code == "ERROR_INVALID_EMAIL") {
        return "format_error";
      } else if (e.code == "ERROR_EMAIL_ALREADY_IN_USE") {
        return "email_already_exist";
      } else {
        return e.message;
      }
    }
  }

  Future<bool> sendVerificationEmail(FirebaseUser _user) async {
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

  Future<void> signOut(FirebaseUser user) async {
    await _authService.signOut();
    user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("email");
    prefs.remove("password");
    prefs.remove("mode");
  }

  Future<String> changePassword(FirebaseUser user, String password) async {
    try {
      await user.updatePassword(password);
      return "success";
    } catch (e) {
      return e.code;
    }
  }
}
