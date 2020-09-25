import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/messaging_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/localization.dart';
import 'package:local_auth/local_auth.dart';

const KEY_AUTH_PAGE_TEXT = "authentication_page_text";

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

  var _userService = GetIt.I.get<UserService>();
  var _authenticationService = GetIt.I.get<AuthenticationService>();
  var _messagingService = GetIt.I.get<MessagingService>();
  var _preferencesService = GetIt.I.get<PreferencesService>();

  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();

  IconData _iconVisibility = Icons.visibility_off;
  bool _passwordVisibility = true;

  bool _isFingerprintAvailable = false;

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
  void initState() {
    _analytics.setCurrentPage("isOnAuthenticationPage");
    checkBiometricsExistence();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_preferencesService.getBool("isBiometricsEnable") != null &&
          _preferencesService.getBool("isBiometricsEnable") == true) {
        biometricsAuth();
      }
    });
  }

  checkBiometricsExistence() async {
    bool _isBiometricsAvailable =
        await LocalAuthentication().canCheckBiometrics;
    if (_isBiometricsAvailable) {
      List<BiometricType> _biometrics =
          await LocalAuthentication().getAvailableBiometrics();
      setState(() {
        _isFingerprintAvailable =
            _biometrics.contains(BiometricType.fingerprint);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      key: Key("authentication"),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    getString(context, 'authentication_page_text'),
                    key: Key(KEY_AUTH_PAGE_TEXT),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: WHITE,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Image.asset(
                    'assets/images/square-logo.png',
                    width: 100,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: buildForm(context),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Center(
                  child: Text(
                    getString(context, 'or'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: WHITE,
                    ),
                  ),
                ),
              ),
              buildGoogleButton(context),
              /*Flexible(
                flex: 1,
                child: buildFacebookButton(context),
              ),
              Flexible(
                flex: 1,
                child: buildTwitterButton(context),
              ),*/
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: buildBottomLinks(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Align buildBottomLinks(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            key: Key("register_page_button"),
            color: TRANSPARENT,
            onPressed: () => openRegisterPage(context),
            child: Text(
              getString(context, 'create_account'),
              style: TextStyle(
                color: WHITE,
              ),
            ),
          ),
          FlatButton(
            key: Key("forgotten_password_button"),
            color: TRANSPARENT,
            onPressed: () => openForgottenPasswordPage(context),
            child: Text(
              getString(context, 'forgotten_password'),
              style: TextStyle(
                color: WHITE,
              ),
            ),
          ),
        ],
      ),
    );
  }

  RaisedButton buildGoogleButton(BuildContext context) {
    return RaisedButton.icon(
      onPressed: () {},
      label: Text(
        getString(context, 'coming_soon'),
        style: TextStyle(color: GREY, fontWeight: FontWeight.bold),
      ),
      color: Colors.grey[600],
      icon: new Image.asset(
        'assets/images/Google_g.png',
        width: 20,
      ),
    );
    /*return RaisedButton.icon(
      onPressed: () => onGoogleButtonPressed(context),
      label: Text(
        getString(context, 'google'),
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
      ),
      color: WHITE,
      icon: new Image.asset(
        'assets/images/Google_g.png',
        width: 20,
      ),
    );*/
  }

  onGoogleButtonPressed(BuildContext context) async {
    _authenticationService.googleSignIn().then((User user) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('mode', "google");
      await setUserAppToken();
      _userService.user = user;
      Fluttertoast.showToast(msg: getString(context, 'google_signin'));
      openMainPage(context);
    }).catchError((e) => Fluttertoast.showToast(msg: e));
  }

  RaisedButton buildTwitterButton(BuildContext context) {
    return RaisedButton.icon(
      onPressed: () async {},
      label: Text(
        getString(context, 'twitter'),
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
      ),
      color: Colors.white,
      icon: new Image.asset(
        'assets/images/twitter.png',
        width: 20,
      ),
    );
  }

  RaisedButton buildFacebookButton(BuildContext context) {
    return RaisedButton.icon(
      onPressed: () async {},
      label: Text(
        getString(context, 'facebook'),
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
      ),
      color: Colors.white,
      icon: new Image.asset(
        'assets/images/facebook_f.png',
        width: 20,
      ),
    );
  }

  Form buildForm(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: TextFormField(
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.emailAddress,
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
                        borderSide: BorderSide(color: TRANSPARENT),
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
              Row(
                children: [
                  Flexible(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        bottom: 8.0,
                      ),
                      child: TextFormField(
                        autocorrect: false,
                        enableSuggestions: false,
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
                              borderSide: BorderSide(color: TRANSPARENT),
                            ),
                            filled: true,
                            fillColor: Colors.grey[300],
                            labelText: getString(context, 'password_label'),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        controller: _passwordController,
                        obscureText: _passwordVisibility,
                        onChanged: (text) => handleSubmittedPassword(text),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      color: WHITE,
                      icon: Icon(_iconVisibility),
                      onPressed: () {
                        setState(() {
                          _passwordVisibility
                              ? _iconVisibility = Icons.visibility
                              : _iconVisibility = Icons.visibility_off;
                          _passwordVisibility
                              ? _passwordVisibility = false
                              : _passwordVisibility = true;
                        });
                      },
                    ),
                  )
                ],
              ),
              RaisedButton(
                key: Key("sign_in_button"),
                color: _colorsApp.buttonColor,
                textColor: Colors.white,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    signInUser();
                  }
                },
                child: Text(getString(context, 'sign_in')),
              ),
            ],
          ),
        ));
  }

  Future<void> signInUser() async {
    String result = await _authenticationService.signIn(_email, _password);
    switch (result) {
      case "wrong-password":
        Fluttertoast.showToast(msg: getString(context, 'wrong_password'));
        break;
      case "user-not-found":
        Fluttertoast.showToast(msg: getString(context, 'no_user_found'));
        break;
      case "success":
        if (_isFingerprintAvailable &&
            _preferencesService.getString("biometricsEmail") == null &&
            _preferencesService.getString("biometricsPassword") == null &&
            _preferencesService.getBool("isBiometricsEnable") == null) {
          bool isBiometricsEnable = await openBiometricsCheck();
          await _preferencesService.setBool(
              "isBiometricsEnable", isBiometricsEnable);
        }
        debugPrint(_userService.user.toString());
        if (_userService.user != null) {
          if (_userService.user.emailVerified == false) {
            bool verif = await _authenticationService
                .sendVerificationEmail(_userService.user);
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
          await _preferencesService.setString('mode', "emailpassword");
          await _preferencesService.setString('email', _email);
          await _preferencesService.setString('password', _password);
          if (_preferencesService.getBool("isBiometricsEnable") != null &&
              _preferencesService.getBool("isBiometricsEnable") == true) {
            debugPrint("passed");
            await _preferencesService.setString(
                'biometricsPassword', _password);
            await _preferencesService.setString('biometricsEmail', _email);
          }

          await setUserAppToken();

          openMainPage(context);
          Fluttertoast.showToast(msg: getString(context, 'signed_in'));
        }
        break;
    }
  }

  openBiometricsCheck() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(getString(context, 'biometrics_check')),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(getString(context, 'biometrics_confirm'))),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(getString(context, 'biometrics_cancel')),
            ),
          ],
        );
      },
    );
  }

  biometricsAuth() async {
    if (_preferencesService.getString("biometricsEmail") != null &&
        _preferencesService.getString("biometricsPassword") != null) {
      try {
        IOSAuthMessages iosMessages = IOSAuthMessages(
          cancelButton: getString(context, "cancel_fingerprint_button"),
          goToSettingsButton: getString(context, "go_to_settings"),
          goToSettingsDescription: getString(context, "go_to_settings_desc"),
          lockOut: getString(context, "lockout_text"),
        );
        AndroidAuthMessages androidMessages = AndroidAuthMessages(
          cancelButton: getString(context, "cancel_fingerprint_button"),
          goToSettingsButton: getString(context, "go_to_settings"),
          goToSettingsDescription: getString(context, "go_to_settings_desc"),
          signInTitle: getString(context, "authentication_page_text"),
          fingerprintRequiredTitle: getString(context, "no_fingerprint_title"),
          fingerprintNotRecognized:
              getString(context, "fingerprint_not_recognized"),
        );
        bool authenticated =
            await LocalAuthentication().authenticateWithBiometrics(
                localizedReason: getString(
                  context,
                  "scan_to_auth",
                ),
                androidAuthStrings: androidMessages,
                iOSAuthStrings: iosMessages,
                useErrorDialogs: true,
                stickyAuth: true);
        if (authenticated) {
          _email = _preferencesService.getString("biometricsEmail");
          _password = _preferencesService.getString("biometricsPassword");
          signInUser();
        }
      } on PlatformException catch (e) {
        debugPrint("Biometrics auth error : " + e.message);
      }
    }
  }

  Future<void> setUserAppToken() async {
    if (_preferencesService.enableNotifications) {
      await _messagingService.setUserAppToken(_userService.user.email);
    }
  }

  void openRegisterPage(context) {
    Navigator.of(context).pushNamed('/registerPage');
  }

  void openMainPage(context) {
    (_userService.user.emailVerified == false)
        ? Navigator.of(context).pushNamedAndRemoveUntil(
            '/profile', (Route<dynamic> route) => false)
        : Navigator.of(context).pushNamedAndRemoveUntil(
            '/mainPage', (Route<dynamic> route) => false);
  }

  void openForgottenPasswordPage(context) {
    Navigator.of(context).pushNamed('/forgottenPasswordPage');
  }
}
