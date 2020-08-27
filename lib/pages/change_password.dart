import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

const int PASSWORD_MINIMAL_LENGHT = 6;

class ChangePassword extends StatefulWidget {
  ChangePassword({Key key}) : super(key: key);

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  var _analytics = GetIt.I.get<AnalyticsService>();
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = new TextEditingController();
  final _confirmNewPasswordController = new TextEditingController();
  String _newPassword;
  String _confirmNewPassword;
  var _authService = GetIt.I.get<AuthenticationService>();
  var _preferencesService = GetIt.I.get<PreferencesService>();
  var _userService = GetIt.I.get<UserService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  IconData _iconPasswordVisibility = Icons.visibility_off;
  bool _passwordVisibility = true;
  IconData _iconConfirmPasswordVisibility = Icons.visibility_off;
  bool _confirmPasswordVisibility = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void handleSubmittedConfirmNewPassword(String input) {
    _confirmNewPassword = input;
  }

  void handleSubmittedNewPassword(String input) {
    _newPassword = input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: WHITE,
                  ),
                  onPressed: () {
                    openProfilPage();
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    getString(context, 'change_password_page_text'),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: WHITE,
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildNewPassword(context),
                      buildConfirmNewPassword(context),
                      buildChangePasswordButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  RaisedButton buildChangePasswordButton(BuildContext context) {
    return RaisedButton(
      key: Key("change_password_button"),
      color: _colorsApp.buttonColor,
      textColor: WHITE,
      onPressed: () {
        if (_formKey.currentState.validate()) {
          changePassword();
          _analytics.sendAnalyticsEvent("change_password");
        }
      },
      child: Text(getString(context, 'confirm_password_changing')),
    );
  }

  Row buildNewPassword(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: TextFormField(
              autocorrect: false,
              enableSuggestions: false,
              validator: (value) {
                if (value.isEmpty) {
                  return getString(context, 'fill_new_password');
                }
                if (_newPassword.length < PASSWORD_MINIMAL_LENGHT) {
                  return getString(context, 'too_short_new_password');
                }
                return null;
              },
              key: Key("new_password_label"),
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TRANSPARENT),
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                  labelText: getString(context, 'new_password_label'),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              controller: _newPasswordController,
              obscureText: _passwordVisibility,
              onChanged: (text) => handleSubmittedNewPassword(text),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            color: WHITE,
            icon: Icon(_iconPasswordVisibility),
            onPressed: () {
              setState(() {
                _passwordVisibility
                    ? _iconPasswordVisibility = Icons.visibility
                    : _iconPasswordVisibility = Icons.visibility_off;
                _passwordVisibility
                    ? _passwordVisibility = false
                    : _passwordVisibility = true;
              });
            },
          ),
        ),
      ],
    );
  }

  Row buildConfirmNewPassword(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: TextFormField(
              autocorrect: false,
              enableSuggestions: false,
              validator: (value) {
                if (value.isEmpty) {
                  return getString(context, 'fill_confirm_new_password');
                }
                if (_newPassword != _confirmNewPassword) {
                  return getString(context, 'new_password_not_confirmed');
                }
                return null;
              },
              key: Key("confirm_new_password_label"),
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TRANSPARENT),
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                  labelText: getString(context, 'confirm_new_password_label'),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              controller: _confirmNewPasswordController,
              obscureText: _confirmPasswordVisibility,
              onChanged: (text) => handleSubmittedConfirmNewPassword(text),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            color: WHITE,
            icon: Icon(_iconConfirmPasswordVisibility),
            onPressed: () {
              setState(() {
                _confirmPasswordVisibility
                    ? _iconConfirmPasswordVisibility = Icons.visibility
                    : _iconConfirmPasswordVisibility = Icons.visibility_off;
                _confirmPasswordVisibility
                    ? _confirmPasswordVisibility = false
                    : _confirmPasswordVisibility = true;
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> reconnectUser() async {
    FocusScope.of(context).unfocus();
    String result = await _authService.reconnectUser(_userService.user,
        _userService.user.email, _preferencesService.getPassword());
    switch (result) {
      case "success":
        await changePassword();
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
        Fluttertoast.showToast(
            msg: getString(context, 'change_password_error'));
    }
  }

  Future<void> changePassword() async {
    String result =
        await _authService.changePassword(_userService.user, _newPassword);
    switch (result) {
      case "success":
        await _preferencesService.setString('password', _newPassword);
        Fluttertoast.showToast(msg: getString(context, 'password_changed'));
        Navigator.pop(context);
        break;
      case "ERROR_WEAK_PASSWORD":
        Fluttertoast.showToast(msg: getString(context, 'password_too_weak'));
        break;
      case "ERROR_USER_DISABLED":
        Fluttertoast.showToast(msg: getString(context, 'user_disabled'));
        break;
      case "ERROR_USER_NOT_FOUND":
        Fluttertoast.showToast(msg: getString(context, 'user_not_found'));
        break;
      case "ERROR_REQUIRES_RECENT_LOGIN":
        Fluttertoast.showToast(msg: getString(context, 'recent_login_needed'));
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        Fluttertoast.showToast(msg: getString(context, 'changing_not_allowed'));
        break;
      default:
        Fluttertoast.showToast(
            msg: getString(context, 'change_password_error'));
    }
  }

  void openProfilPage() {
    Navigator.pop(context);
  }
}
