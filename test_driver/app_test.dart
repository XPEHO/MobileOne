import 'package:MobileOne/pages/authentication-page.dart';
import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:test/test.dart';
import 'package:flutter_driver/flutter_driver.dart';

void main() {
  group("Auth tests", () {
    FlutterDriver driver;
    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Create an account', () async {
      await driver.tap(find.byValueKey("register_page_button"));
      await driver.tap(find.byValueKey("email_label"));
      await driver.enterText("test@test.test");
      await driver.tap(find.byValueKey("password_label"));
      await driver.enterText("test123");
      await driver.tap(find.byValueKey("confirm_password_label"));
      await driver.enterText("test123");
      await driver.tap(find.byValueKey("create_account_button"));
      String value =
          await driver.getText(find.byValueKey("authentication_page_text"));

      expect(value, "Login to your account");
    });

    test('Sign in this account', () async {
      await driver.tap(find.byValueKey("auth_email_label"));
      await driver.enterText("test@test.test");
      await driver.tap(find.byValueKey("auth_password_label"));
      await driver.enterText("test123");
      await driver.tap(find.byValueKey("sign_in_button"));
    });
    test('bottom bar navigation', () async {
      await driver.tap(find.byValueKey(KEY_CARD_PAGE));
      await driver.tap(find.byValueKey(KEY_LISTS_PAGE));
      await driver.tap(find.byValueKey(KEY_SHARE_PAGE));
      await driver.tap(find.byValueKey(KEY_PROFILE_PAGE));
    });

    test('Delete this account', () async {
      await driver.tap(find.byValueKey(KEY_PROFILE_PAGE));
      await driver.tap(find.byValueKey(KEY_DELETE_ACCOUNT));
      String value = await driver.getText(find.byValueKey(KEY_AUTH_PAGE_TEXT));

      expect(value, "Login to your account");
    });
  });
}
