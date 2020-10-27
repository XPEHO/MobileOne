import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/tutorial_service.dart';
import 'package:MobileOne/widgets/widget_about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get_it/get_it.dart';
import 'package:tutorial_coach_mark/target_focus.dart';

class CustomDrawer extends StatelessWidget {
  final BuildContext context;
  final List<TargetFocus> targets;
  final _colorsApp = GetIt.I.get<ColorService>();
  final _tutorialService = GetIt.I.get<TutorialService>();

  CustomDrawer({
    @required this.context,
    this.targets,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: [
                Text(getString(context, "app_name")),
                Image.asset(
                  "assets/images/square-logo.png",
                  width: 100,
                  height: 100,
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: _colorsApp.buttonColor,
            ),
          ),
          ListTile(
            title: Text(getString(context, "feedback_text")),
            onTap: () {
              sendFeedback();
            },
          ),
          ListTile(
            title: Text(
                getString(context, "about") + getString(context, "app_name")),
            onTap: () {
              aboutScreen();
            },
          ),
          targets != null
              ? ListTile(
                  title: Text(getString(context, "help_text")),
                  onTap: () {
                    showTutorial();
                  },
                )
              : Container(),
        ],
      ),
    );
  }

  sendFeedback() async {
    Navigator.pop(context);
    final Email email = Email(
      subject: getString(context, 'feedback'),
      recipients: ['xpeho.mobile@gmail.com'],
    );

    await FlutterEmailSender.send(email);
  }

  void aboutScreen() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AboutScreen();
        });
  }

  void showTutorial() {
    Navigator.pop(context);
    if (targets != null) {
      _tutorialService.showTutorial(targets, context);
    }
  }
}
