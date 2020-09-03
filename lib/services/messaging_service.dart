import 'dart:async';
import 'dart:convert';

import 'package:MobileOne/dao/messaging_dao.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class MessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _messagingDao = GetIt.I.get<MessagingDao>();
  String _appToken;

  String get appToken => _appToken;

  setAppToken(String token) {
    _appToken = token;
  }

  configureMessaging() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        debugPrint("onResume: $message");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});

    await _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setAppToken(token);
    });
  }

  setUserAppToken(String userEmail) async {
    await _messagingDao.setUserAppToken(userEmail, _appToken);
  }

  Future<String> getServerToken() async {
    String data =
        await rootBundle.loadString('assets/messaging/cloud_messaging.json');
    Map<String, dynamic> _result = json.decode(data);

    return _result["serverToken"];
  }

  setNotification(
      {@required String destEmail,
      @required String title,
      @required String body}) async {
    String appToken = await _messagingDao.getUserAppToken(destEmail);

    if (appToken != null) {
      await sendNotification(title, body, appToken);
    }
  }

  Future<Map<String, dynamic>> sendNotification(
      String title, String message, String appToken) async {
    String _serverToken = await getServerToken();

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$message',
            'title': '$title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': appToken,
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    return completer.future;
  }
}
