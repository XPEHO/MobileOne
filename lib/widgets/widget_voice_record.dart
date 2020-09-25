import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:speech_to_text/speech_to_text.dart';

class WidgetVoiceRecord extends StatefulWidget {
  final SpeechToText speech;

  WidgetVoiceRecord({this.speech});

  @override
  WidgetVoiceRecordState createState() => WidgetVoiceRecordState();
}

class WidgetVoiceRecordState extends State<WidgetVoiceRecord> {
  var _colorsApp = GetIt.I.get<ColorService>();
  String _recordResult;

  @override
  void initState() {
    super.initState();
    listenRecord();
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      backgroundColor: _colorsApp.buttonColor,
      scrollable: true,
      content: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.mic,
              color: WHITE,
              size: 36,
            ),
            Text(
              _recordResult != null
                  ? _recordResult
                  : getString(context, "talk"),
              style: TextStyle(color: WHITE),
            ),
            FlatButton(
              child: Icon(
                Icons.check,
                color: _colorsApp.buttonColor,
              ),
              color: WHITE,
              onPressed: () async {
                Navigator.of(context).pop(_recordResult);
              },
            )
          ],
        ),
      ),
    );
  }

  listenRecord() async {
    await widget.speech.listen(
      partialResults: true,
      onResult: (result) {
        setState(() {
          _recordResult = result.recognizedWords;
        });
      },
    );
  }
}
