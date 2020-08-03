import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

String emailRegexp =
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const int PASSWORD_MINIMAL_LENGHT = 6;

class ChangePassword extends StatefulWidget {
  ChangePassword({Key key}) : super(key: key);

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = new TextEditingController();
  final _confirmNewPasswordController = new TextEditingController();
  String _newPassword;
  String _confirmNewPassword;
  var _authService = GetIt.I.get<AuthenticationService>();
  var _userService = GetIt.I.get<UserService>();

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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    openProfilPage(context);
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
      color: BLUE,
      textColor: WHITE,
      onPressed: () {
        if (_formKey.currentState.validate()) {
          changePassword();
        }
      },
      child: Text(getString(context, 'confirm_password_changing')),
    );
  }

  Container buildNewPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.width * 0.2,
      child: TextFormField(
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
        obscureText: true,
        onChanged: (text) => handleSubmittedNewPassword(text),
      ),
    );
  }

  Container buildConfirmNewPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.width * 0.2,
      child: TextFormField(
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
        obscureText: true,
        onChanged: (text) => handleSubmittedConfirmNewPassword(text),
      ),
    );
  }

  Future<void> changePassword() async {
    FocusScope.of(context).unfocus();
    String result =
        await _authService.changePassword(_userService.user, _newPassword);
    switch (result) {
      case "success":
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

  void openProfilPage(context) {
    Navigator.pop(context);
  }
}
