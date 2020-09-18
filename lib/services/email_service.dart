import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/rest/email_rest_client.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class EmailService {
  final _emailRestClient = GetIt.I.get<EmailRestClient>();

  sendEmail(BuildContext context, String emailTo) async {
    String jsonCredentials =
        await rootBundle.loadString('assets/messaging/email.json');
    Map<String, dynamic> _credentials = json.decode(jsonCredentials);

    String text = getString(context, "email_text");
    String title = getString(context, "subscribe_to_simplist");

    String jsonBody = json.encode({
      "Messages": [
        {
          "From": {"Email": "xpeho.mobile@gmail.com", "Name": "XPEHO"},
          "To": [
            {"Email": "$emailTo"}
          ],
          "Subject": "$title",
          "TextPart": "$text",
          "HTMLPart": "$text",
        }
      ]
    });

    String username = _credentials["username"];
    String password = _credentials["password"];

    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    _emailRestClient.sendEmail(basicAuth, jsonBody);
  }
}
