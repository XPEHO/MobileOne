import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import '../localization/localization.dart';

class ForgottenPasswordPage extends StatefulWidget {
  ForgottenPasswordPage({Key key}) : super(key: key);

  @override
  ForgottenPasswordPageState createState() => ForgottenPasswordPageState();
}

class ForgottenPasswordPageState extends State<ForgottenPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = new TextEditingController();
  String _email;

  final _authService = GetIt.I.get<AuthenticationService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void handleSubmittedEmail(String input) {
    _email = input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _colorsApp.colorTheme,
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
                      getString(context, 'forgotten_password_page_text'),
                      key: Key("forgotten_password_page_text"),
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: WHITE,
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
                              key: Key("reset_password_email_label"),
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
                          RaisedButton(
                            color: _colorsApp.buttonColor,
                            key: Key("forgotten_password_button"),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                resetPassword();
                              }
                            },
                            child: Text(
                              getString(context, 'reset_password'),
                              style: TextStyle(color: WHITE),
                            ),
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
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> resetPassword() async {
    String result = await _authService.resetPassword(_email);
    switch (result) {
      case "success":
        Fluttertoast.showToast(
            msg: getString(context, 'reset_password_email_sent'));
        openAuthenticationPage(context);
        break;
      case "format_error":
        Fluttertoast.showToast(msg: getString(context, 'format_error'));
        break;
      case "email_does_not_exist":
        Fluttertoast.showToast(msg: getString(context, 'no_user_found'));
        break;
    }
  }

  void openAuthenticationPage(context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}
