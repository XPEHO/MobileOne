import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import '../localization/localization.dart';

String emailRegexp =
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const int PASSWORD_MINIMAL_LENGHT = 6;

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  var _analytics = GetIt.I.get<AnalyticsService>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _confirmPasswordController = new TextEditingController();
  var _colorsApp = GetIt.I.get<ColorService>();
  String _email;
  String _password;
  String _confirmPassword;
  IconData _iconPasswordVisibility = Icons.visibility_off;
  bool _passwordVisibility = true;
  IconData _iconConfirmPasswordVisibility = Icons.visibility_off;
  bool _confirmPasswordVisibility = true;

  final _authService = GetIt.I.get<AuthenticationService>();

  @override
  initState() {
    _analytics.setCurrentPage("isOnregisterPage");
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void handleSubmittedConfirmPassword(String input) {
    _confirmPassword = input;
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
      backgroundColor: _colorsApp.colorTheme,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  getString(context, 'register_page_text'),
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
                    buildEmail(context),
                    buildPassword(context),
                    buildConfirmPassword(context),
                    buildRaisedButton(context),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      color: TRANSPARENT,
                      onPressed: () => openAuthenticationPage(context),
                      child: Text(
                        getString(context, 'authentication_page_button'),
                        style: TextStyle(
                          color: WHITE,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      child: TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return getString(context, 'fill_email');
          }
          if (RegExp(emailRegexp).hasMatch(value)) {
            return null;
          } else {
            return getString(context, 'wrong_email');
          }
        },
        key: Key("email_label"),
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
    );
  }

  Row buildPassword(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return getString(context, 'fill_password');
                }
                if (_password.length < PASSWORD_MINIMAL_LENGHT) {
                  return getString(context, 'too_short_password');
                }
                return null;
              },
              key: Key("password_label"),
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
        )
      ],
    );
  }

  Row buildConfirmPassword(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return getString(context, 'fill_confirm_password');
                }
                if (_password != _confirmPassword) {
                  return getString(context, 'password_not_confirmed');
                }
                return null;
              },
              key: Key("confirm_password_label"),
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TRANSPARENT),
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                  labelText: getString(context, 'confirm_password_label'),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              controller: _confirmPasswordController,
              obscureText: _confirmPasswordVisibility,
              onChanged: (text) => handleSubmittedConfirmPassword(text),
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

  RaisedButton buildRaisedButton(BuildContext context) {
    return RaisedButton(
      key: Key("create_account_button"),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          createAccount();
          _analytics.sendAnalyticsEvent("account_registred");
        }
      },
      child: Text(getString(context, 'create_account')),
    );
  }

  Future<void> createAccount() async {
    String result = await _authService.register(_email, _password);
    switch (result) {
      case "success":
        Fluttertoast.showToast(
            msg: getString(context, 'successful_registration'));
        openAuthenticationPage(context);
        break;
      case "format_error":
        Fluttertoast.showToast(msg: getString(context, 'format_error'));
        break;
      case "email_already_exist":
        Fluttertoast.showToast(msg: getString(context, 'email_already_exist'));
        break;
    }
  }

  void openAuthenticationPage(context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}
