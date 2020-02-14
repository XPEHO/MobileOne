import 'package:flutter/material.dart';

List<Locale> getSupportedLocaled() {
  return [
    const Locale('en', 'US'),
    const Locale('fr', 'FR'),
  ];
}

List<String> getSupportedLanguages() {
  return getSupportedLocaled().map((locale) => locale.languageCode).toList();
}
