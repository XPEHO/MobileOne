import 'package:flutter/material.dart';

List<Locale> _supportedLocales = [
  const Locale('en', 'US'),
  const Locale('fr', 'FR'),
];

void setSupportedLocales(List<Locale> locales) {
  _supportedLocales = locales;
}

List<Locale> getSupportedLocales() {
  return _supportedLocales;
}

List<String> getSupportedLanguages() {
  return getSupportedLocales().map((locale) => locale.languageCode).toList();
}
