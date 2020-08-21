import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/items_page.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/share_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

Widget buildTestableWidget(Widget widget) {
  return MaterialApp(
      supportedLocales: getSupportedLocales(),
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }

        return supportedLocales.first;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: widget);
}

class ItemsListProviderMock extends Mock implements ItemsListProvider {}

class ImagePickerMock extends Mock implements ImagePicker {}

class ImageServiceMock extends Mock implements ImageService {}

class MockArguments extends Mock implements Arguments {}

class AnalyticsServiceMock extends Mock implements AnalyticsService {}

class ColorServiceMock extends Mock implements ColorService {}

class ShareServiceMock extends Mock implements ShareService {}

void main() {
  setSupportedLocales([Locale("fr", "FR")]);

  testWidgets("Take a picture of an item", (WidgetTester tester) async {
    // GIVEN

    final _itemsListMock = ItemsListProviderMock();
    GetIt.I.registerSingleton<ItemsListProvider>(_itemsListMock);
    final _imageService = ImageServiceMock();
    GetIt.I.registerSingleton<ImageService>(_imageService);
    final _imagePicker = ImagePickerMock();
    GetIt.I.registerSingleton<ImagePicker>(_imagePicker);
    final _analyticsService = AnalyticsServiceMock();
    GetIt.I.registerSingleton<AnalyticsService>(_analyticsService);

    final _colorService = ColorServiceMock();
    GetIt.I.registerSingleton<ColorService>(_colorService);
    final _shareService = ShareServiceMock();
    GetIt.I.registerSingleton<ShareService>(_shareService);

    final mockArguments = MockArguments();
    Arguments.proxy = mockArguments;
    when(mockArguments.get(any)).thenReturn(ItemArguments(
      listUuid: "",
      buttonName: "",
      itemUuid: "",
    ));

    when(_imagePicker.getImage(
            source: ImageSource.camera,
            imageQuality: 30,
            maxWidth: 720,
            maxHeight: 720))
        .thenAnswer((_) => Future.value(PickedFile("")));

    when(_imageService.pickCamera(30, 720, 720))
        .thenAnswer((_) => Future.value(PickedFile("")));

    //WHEN
    await tester.pumpWidget(buildTestableWidget(EditItemPage()));
    await tester.pumpAndSettle(Duration(seconds: 1));

    await tester.tap(find.byKey(Key("item_picture_button")));
    await tester.pumpAndSettle(Duration(seconds: 1));

    // THEN
    verify(_imageService.pickCamera(30, 720, 720));
  });
}
