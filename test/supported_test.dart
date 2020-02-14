// Import the test package and Counter class
import 'package:MobileOne/localization/supported.dart';
import 'package:test/test.dart';

void main() {
  group('Supported languages', () {
    test('fr should be supported', () {
      expect(getSupportedLanguages().contains('fr'), true);
    });

    test('en should be supported', () {
      expect(getSupportedLanguages().contains('en'), true);
    });

    test('es should not be supported', () {
      expect(getSupportedLanguages().contains('es'), false);
    });
  });
}
