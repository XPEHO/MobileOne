import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> googleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return (await _auth.signInWithCredential(credential)).user;
  }

  Future<FirebaseUser> signIn(String email, String password) async {
      FirebaseUser _user = (await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).user;
      return _user;
  }

  Future<String> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
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

  void signOut(FirebaseUser user) async {
    await _auth.signOut();
    user = null;
  }
}