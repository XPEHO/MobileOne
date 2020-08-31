import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class DeletionConfirmationPopupWidget extends StatefulWidget {
  State<StatefulWidget> createState() => DeletionConfirmationPopupWidgetState();
}

class DeletionConfirmationPopupWidgetState
    extends State<DeletionConfirmationPopupWidget> {
  final _userService = GetIt.I.get<UserService>();
  final _prefService = GetIt.I.get<PreferencesService>();
  var _authService = GetIt.I.get<AuthenticationService>();
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();

  final _formKey = GlobalKey<FormState>();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  String _email;
  String _password;
  IconData _iconVisibility = Icons.visibility_off;
  bool _passwordVisibility = true;
  bool _isVerificationCorrect = true;

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
    return AlertDialog(
      content: SingleChildScrollView(
        child: buildForm(context),
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
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(getString(context, "verify_your_account")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
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
                        color: BLACK,
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
              ),
              _isVerificationCorrect
                  ? Container()
                  : Text(
                      getString(context, "invalid_email_password"),
                      style: TextStyle(color: RED),
                    ),
              RaisedButton(
                key: Key("verify_account_button"),
                color: _colorsApp.buttonColor,
                textColor: Colors.white,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    var result =
                        _userService.checkCurrentUser(_email, _password);
                    if (result) {
                      if (!_isVerificationCorrect) {
                        setState(() {
                          _isVerificationCorrect = true;
                        });
                      }
                      confirmAccountDeletion().then((value) {
                        if (value) {
                          reconnectUser(_userService.user);
                        }
                      });
                    } else {
                      setState(() {
                        _isVerificationCorrect = false;
                      });
                    }
                  }
                },
                child: Text(getString(context, 'verify_account')),
              ),
            ],
          ),
        ));
  }

  Future<bool> confirmAccountDeletion() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(getString(context, 'confirm_account_deletion')),
          actions: <Widget>[
            FlatButton(
                key: Key("confirmAccountDeletion"),
                onPressed: () {
                  result = true;
                  Navigator.of(context).pop();
                },
                child: Text(getString(context, 'delete_account'))),
            FlatButton(
              key: Key("cancelAccountDeletion"),
              onPressed: () {
                result = false;
                Navigator.of(context).pop();
              },
              child: Text(getString(context, 'cancel_deletion')),
            ),
          ],
        );
      },
    );
    return result;
  }

  reconnectUser(FirebaseUser user) async {
    String result = await _authService.reconnectUser(
        user, user.email, _prefService.getPassword());
    switch (result) {
      case "success":
        deleteAccount(user);
        break;
      case "ERROR_USER_DISABLED":
        Fluttertoast.showToast(msg: getString(context, 'user_disabled'));
        break;
      case "ERROR_USER_NOT_FOUND":
        Fluttertoast.showToast(msg: getString(context, 'user_not_found'));
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        Fluttertoast.showToast(msg: getString(context, 'changing_not_allowed'));
        break;
      case "ERROR_INVALID_CREDENTIAL":
        Fluttertoast.showToast(msg: getString(context, 'invalid_credential'));
        break;
      case "ERROR_WRONG_PASSWORD":
        Fluttertoast.showToast(msg: getString(context, 'wrong_password'));
        break;
      default:
        Fluttertoast.showToast(msg: getString(context, 'default_error'));
    }
  }

  deleteAccount(FirebaseUser user) async {
    String userUid = user.uid;
    await _userService.deleteUserData(userUid);
    String result = await _userService.deleteAccount(user);
    switch (result) {
      case "success":
        _prefService.sharedPreferences.remove("email");
        _prefService.sharedPreferences.remove("password");
        _prefService.sharedPreferences.remove("mode");
        Fluttertoast.showToast(
          msg: getString(context, 'debug_account_deleted'),
        );
        Navigator.of(context).pop();
        openAuthenticationPage();
        _userService.user = null;
        break;
      case "ERROR_REQUIRES_RECENT_LOGIN":
        Fluttertoast.showToast(msg: getString(context, 'recent_login_needed'));
        break;
      case "ERROR_INVALID_CREDENTIAL":
        Fluttertoast.showToast(msg: getString(context, 'invalid_credential'));
        break;
      case "ERROR_USER_DISABLED":
        Fluttertoast.showToast(msg: getString(context, 'user_disabled'));
        break;
      case "ERROR_USER_NOT_FOUND":
        Fluttertoast.showToast(msg: getString(context, 'user_not_found'));
        break;
      default:
        Fluttertoast.showToast(
          msg: getString(context, 'default_error'),
        );
    }
    _analytics.sendAnalyticsEvent("delete_account");
  }

  void openAuthenticationPage() {
    _prefService.sharedPreferences.remove("email");
    _prefService.sharedPreferences.remove("password");
    _prefService.sharedPreferences.remove("mode");
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/authentication', (Route<dynamic> route) => false);
    _userService.user = null;
    _analytics.sendAnalyticsEvent("logout");
  }
}
