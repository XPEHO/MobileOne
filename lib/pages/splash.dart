import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final colorService = GetIt.I.get<ColorService>();
  final _userService = GetIt.I.get<UserService>();
  final _authenticationService = GetIt.I.get<AuthenticationService>();
  final _preferencesService = GetIt.I.get<PreferencesService>();
  AnimationController _controllerLogo;
  Animation<Offset> _offsetAnimationLogo;

  bool _textVisible = false;

  @override
  void initState() {
    super.initState();
    _controllerLogo = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _offsetAnimationLogo = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllerLogo,
      curve: Curves.elasticInOut,
    ));
    _offsetAnimationLogo.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _textVisible = true;
        });
        Future.delayed(Duration(milliseconds: 400), () => openNextScreen());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controllerLogo.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorService.colorTheme,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SlideTransition(
              position: _offsetAnimationLogo,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset('assets/images/square-logo.png',
                    width: 100, height: 100),
              ),
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 400),
              opacity: _textVisible ? 1.0 : 0.0,
              child: Text(
                getString(context, "splash_text"),
                style: TextStyle(
                  color: colorService.greyColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 400),
              opacity: _textVisible ? 1.0 : 0.0,
              child: Text(
                getString(context, "app_name"),
                style: TextStyle(
                  color: colorService.greyColor,
                  fontSize: 32.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> openNextScreen() async {
    if (_preferencesService.getEmail() != null) {
      bool autologin = false;
      if (_preferencesService.isEmailPasswordMode()) {
        _userService.user = await _authenticationService.signIn(
            _preferencesService.getEmail(), _preferencesService.getPassword());
        autologin = true;
      } else if (_preferencesService.isGoogleMode()) {
        _userService.user = await _authenticationService.googleSignInSilently();
        autologin = true;
      }
      if (_userService.user != null) {
        openMainPage();
      }
      return autologin;
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          "/authentication", (Route<dynamic> route) => false);
    }
    return false;
  }

  void openMainPage() {
    (_userService.user.isEmailVerified == false)
        ? Navigator.of(context).pushNamedAndRemoveUntil(
            '/profile', (Route<dynamic> route) => false)
        : Navigator.of(context).pushNamedAndRemoveUntil(
            '/mainPage', (Route<dynamic> route) => false);
  }
}
