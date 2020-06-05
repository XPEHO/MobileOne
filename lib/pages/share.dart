import 'package:MobileOne/localization/localization.dart';
import 'package:flutter/material.dart';

class Share extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(getString(context, "shared"))));
  }
}
