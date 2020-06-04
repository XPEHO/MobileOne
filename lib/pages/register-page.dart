import 'package:MobileOne/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import '../localization/localization.dart';

String emailRegexp = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const int PASSWORD_MINIMAL_LENGHT = 6;

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _confirmPasswordController = new TextEditingController();
  String _email;
  String _password;
  String _confirmPassword;

  final _authService = GetIt.I.get<AuthenticationService>();

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
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                Flexible(
                  flex: 1,
                  child: Text(getString(context, 'register_page_text'), 
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  flex: 8,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width - 10,
                          height: 90,
                          child : TextFormField(
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
                                borderSide: BorderSide(color: Colors.transparent),
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
                          child : TextFormField(
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
                                borderSide: BorderSide(color: Colors.transparent),
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
                        Container(
                          width: MediaQuery.of(context).size.width - 10,
                          height: 90,
                          child : TextFormField(
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
                                borderSide: BorderSide(color: Colors.transparent),
                              ),
                              filled: true,
                              fillColor: Colors.grey[300],
                              labelText: getString(context, 'confirm_password_label'),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                            controller: _confirmPasswordController,
                            obscureText: true,
                            onChanged: (text) => handleSubmittedConfirmPassword(text),
                          ),
                        ),
                        RaisedButton(
                          key: Key("create_account_button"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              createAccount();
                            }
                          },
                          child: Text(getString(context, 'create_account')),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        color: Colors.transparent,
                        onPressed: () => openAuthenticationPage(context),
                        child: Text(getString(context, 'authentication_page_button'), 
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

  Future<void> createAccount() async {
    String result = await _authService.register(_email, _password);
    switch (result) {
      case "success":
        Fluttertoast.showToast(msg: getString(context, 'successful_registration'));
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