// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('MobileOne App', () {
    final textFinder = find.byValueKey('hello_message');
    final secondPageTextFinder = find.byValueKey('second_page_text');
    final buttonFinder = find.byValueKey('page2_btn');

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

    test('Says hello at start', () async {
      // Then, verify the counter text is incremented by 1.
      expect(await driver.getText(textFinder), "Hello XPEHO");
    });

    test('Open the second page', () async {
      // First, tap the button.
      await driver.tap(buttonFinder);

      // Then, verify the counter text is incremented by 1.
      expect(await driver.getText(secondPageTextFinder),
          "this is the second page");
    });
  });
}
