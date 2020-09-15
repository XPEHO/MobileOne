import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/widgets/widget_share_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  group('Share contact tests', () {
    test('Share contact widget should work with a name', () {
      //GIVEN

      //WHEN
      WidgetShareContact _widget = WidgetShareContact(
        name: "test",
      );

      //THEN
      expect(_widget != null, true);
      expect(_widget.name, "test");
    });

    test('Share contact widget should work with an email', () {
      //GIVEN

      //WHEN
      WidgetShareContact _widget = WidgetShareContact(
        email: "test@test.test",
      );

      //THEN
      expect(_widget != null, true);
      expect(_widget.email, "test@test.test");
    });

    test('Share contact widget should work with an email and a name', () {
      //GIVEN

      //WHEN
      WidgetShareContact _widget = WidgetShareContact(
        email: "test@test.test",
        name: "test",
      );

      //THEN
      expect(_widget != null, true);
      expect(_widget.email, "test@test.test");
      expect(_widget.name, "test");
    });

    test('Share contact widget should work without an email and a name', () {
      //GIVEN

      //WHEN
      WidgetShareContact _widget = WidgetShareContact();

      //THEN
      expect(_widget != null, true);
    });
  });
}
