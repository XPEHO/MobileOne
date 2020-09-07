import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/messaging_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final _colorsApp = GetIt.I.get<ColorService>();
  final _preferencesService = GetIt.I.get<PreferencesService>();
  final _messagingService = GetIt.I.get<MessagingService>();
  final _userService = GetIt.I.get<UserService>();

  bool _enableNotifications = true;

  @override
  void initState() {
    _enableNotifications = _preferencesService.enableNotifications;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      appBar: AppBar(
        shadowColor: TRANSPARENT,
        backgroundColor: _colorsApp.colorTheme,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    getString(context, 'settings'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: WHITE,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      getString(context, 'notifications'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: WHITE,
                      ),
                    ),
                    Switch(
                      value: _enableNotifications,
                      onChanged: (value) {
                        setState(() {
                          onSharedWishlistChange(value);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onSharedWishlistChange(bool value) {
    _enableNotifications = value;
    _preferencesService.enableNotifications = value;
    if (value) {
      _messagingService.setUserAppToken(_userService.user.email);
    } else {
      _messagingService.deleteUserAppToken(_userService.user.email);
    }
  }

  void openProfilPage() {
    Navigator.pop(context);
  }
}
