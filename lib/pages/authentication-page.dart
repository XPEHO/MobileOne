import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import '../localization/localization.dart';

class AuthenticationPage extends StatefulWidget {
  AuthenticationPage({Key key}) : super(key: key);

  @override
  AuthenticationPageState createState() => AuthenticationPageState();
}

class AuthenticationPageState extends State<AuthenticationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  String _email;
  String _password;

  final _authService = GetIt.I.get<AuthenticationService>();
  final _userService = GetIt.I.get<UserService>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void handleSubmittedPassword(String input) {
    _password = input;
  }

  void handleSubmittedEmail(String input) {
    _email = input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(flex: 1, child: Container()),
                Flexible(
                  flex: 5,
                  child: Text(
                    getString(context, 'authentication_page_text'),
                    key: Key("authentication_page_text"),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  flex: 9,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width - 10,
                          height: 90,
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return getString(context, 'fill_email');
                              }
                              return null;
                            },
                            key: Key("auth_email_label"),
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                filled: true,
                                fillColor: Colors.grey[300],
                                labelText: getString(context, 'email_label'),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            controller: _emailController,
                            onChanged: (text) => handleSubmittedEmail(text),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 10,
                          height: 90,
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return getString(context, 'fill_password');
                              }
                              return null;
                            },
                            key: Key("auth_password_label"),
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                filled: true,
                                fillColor: Colors.grey[300],
                                labelText: getString(context, 'password_label'),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            controller: _passwordController,
                            obscureText: true,
                            onChanged: (text) => handleSubmittedPassword(text),
                          ),
                        ),
                        RaisedButton(
                          key: Key("sign_in_button"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              signInUser();
                            }
                          },
                          child: Text(getString(context, 'sign_in')),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Text(
                    getString(context, 'or'),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: RaisedButton.icon(
                    onPressed: () async {
                      _authService.googleSignIn().then((FirebaseUser user) {
                        _userService.user = user;
                        Fluttertoast.showToast(
                            msg: getString(context, 'google_signin'));
                        openMainPage(context);
                      }).catchError((e) => Fluttertoast.showToast(msg: e));
                    },
                    label: Text(
                      getString(context, 'google'),
                      style: TextStyle(
                          color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    color: Colors.white,
                    icon: new Image.asset(
                      'assets/images/Google_g.png',
                      width: 20,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: RaisedButton.icon(
                    onPressed: () async {},
                    label: Text(
                      getString(context, 'facebook'),
                      style: TextStyle(
                          color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    color: Colors.white,
                    icon: new Image.asset(
                      'assets/images/facebook_f.png',
                      width: 20,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: RaisedButton.icon(
                    onPressed: () async {},
                    label: Text(
                      getString(context, 'twitter'),
                      style: TextStyle(
                          color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    color: Colors.white,
                    icon: new Image.asset(
                      'assets/images/twitter.png',
                      width: 20,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        key: Key("register_page_button"),
                        color: Colors.transparent,
                        onPressed: () => openRegisterPage(context),
                        child: Text(
                          getString(context, 'create_account'),
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      FlatButton(
                        key: Key("forgotten_password_button"),
                        color: Colors.transparent,
                        onPressed: () => null,
                        child: Text(
                          getString(context, 'forgotten_password'),
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInUser() async {
    try {
      _userService.user = await _authService.signIn(_email, _password);
      if (_userService.user != null) {
        if (_userService.user.isEmailVerified == false) {
          bool verif =
              await _authService.sendVerificationEmail(_userService.user);
          switch (verif) {
            case true:
              Fluttertoast.showToast(
                  msg: getString(context, 'verification_email_sent'));
              break;
            case false:
              Fluttertoast.showToast(
                  msg: getString(context, 'verification_email_error'));
              break;
          }
        }
        openMainPage(context);
        Fluttertoast.showToast(msg: getString(context, 'signed_in'));
      }
    } catch (e) {
      switch (e.code) {
        case "ERROR_WRONG_PASSWORD":
          Fluttertoast.showToast(msg: getString(context, 'wrong_password'));
          break;
        case "ERROR_USER_NOT_FOUND":
          Fluttertoast.showToast(msg: getString(context, 'no_user_found'));
          break;
      }
    }
  }

  void openRegisterPage(context) {
    Navigator.of(context).pushNamed('/registerPage');
  }

  void openMainPage(context) {
    Navigator.of(context).pushNamed(
      '/mainpage',
    );
  }
}
