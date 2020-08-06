import 'package:flutter/material.dart';

class Arguments {
  static Arguments _instance = Arguments._();

  Arguments._();

  static set proxy(Arguments instance) {
    _instance = instance;
  }

  static dynamic value(BuildContext context) => _instance.get(context);

  dynamic get(BuildContext context) =>
      ModalRoute.of(context).settings.arguments;
}
