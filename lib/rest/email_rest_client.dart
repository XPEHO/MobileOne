import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailRestClient {
  sendEmail(String basicAuth, String jsonBody) async {
    http
        .post(
      "https://api.mailjet.com/v3.1/send",
      headers: <String, String>{
        'authorization': basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonBody,
    )
        .catchError((e) {
      debugPrint(e.toString());
    });
  }
}
