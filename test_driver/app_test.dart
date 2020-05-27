import "package:test/test.dart";
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

      await Future<Null>.delayed(Duration(seconds: 2));
      expect(value, "Login to your account");
    });

    test('Sign in this account', () async {
      await driver.tap(find.byValueKey("auth_email_label"));
      await driver.enterText("test@test.test");
      await driver.tap(find.byValueKey("auth_password_label"));
      await driver.enterText("test123");
      await driver.tap(find.byValueKey("sign_in_button"));
      //String value = await driver.getText(find.byValueKey("Lists"));

      //await Future<Null>.delayed(Duration(seconds: 2));
      //expect(value, "My Lists");
    });

    test('Delete this account', () async {
      await driver.tap(find.byValueKey("Profile"));
      await driver.tap(find.byValueKey("debug_delete_account_button"));
      String value =
          await driver.getText(find.byValueKey("authentication_page_text"));

      await Future<Null>.delayed(Duration(seconds: 2));
      expect(value, "Login to your account");
    });
  });
}
