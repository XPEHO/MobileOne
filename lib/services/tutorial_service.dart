import 'package:MobileOne/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/custom_target_position.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  TutorialCoachMark tutorialCoachMark;

  void showTutorial(List<TargetFocus> targets, BuildContext context) {
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      textSkip: getString(context, "skip_tutorial"),
      alignSkip: Alignment.bottomLeft,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        debugPrint("Tutorial as ended");
      },
      onClickTarget: (target) {
        debugPrint("Used target : " + target.toString());
      },
      onClickSkip: () {
        debugPrint("Tutorial skipped");
      },
    )..show();
  }

  TargetFocus createTarget({
    @required String identifier,
    GlobalKey key,
    @required String title,
    @required String text,
    double positionBottom,
    double positionTop,
    double positionLeft,
    TargetPosition position,
    Color textColor = Colors.white,
  }) {
    return TargetFocus(
      identify: identifier,
      keyTarget: key,
      targetPosition: position,
      contents: [
        ContentTarget(
            align: AlignContent.custom,
            customPosition: CustomTargetPosition(
              bottom: positionBottom,
              top: positionTop,
              left: positionLeft,
            ),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title != null ? title : "",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      text != null ? text : "",
                      style: TextStyle(color: textColor),
                    ),
                  )
                ],
              ),
            ))
      ],
    );
  }
}
