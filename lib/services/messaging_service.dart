Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    //final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    //final dynamic notification = message['notification'];
  }

  // Or do other work.
}
