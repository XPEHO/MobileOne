import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/item_page.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

class StorageReferenceMock extends Mock implements StorageReference {}

class StorageUploadTaskMock extends Mock implements StorageUploadTask {}

class AnalyticsServiceMock extends Mock implements AnalyticsService {}

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
    final _storageReference = StorageReferenceMock();
    final _storageUploadTask = StorageUploadTaskMock();
    final _analyticsService = AnalyticsServiceMock();
    GetIt.I.registerSingleton<AnalyticsService>(_analyticsService);

    final mockArguments = MockArguments();
    Arguments.proxy = mockArguments;
    when(mockArguments.get(any)).thenReturn(ItemArguments(
      listUuid: "",
      buttonName: "",
      itemUuid: "",
    ));

    when(_imagePicker.getImage(source: ImageSource.camera)).thenAnswer(
        (_) => Future.value(PickedFile("assets/images/facebook_f.png")));

    when(_imageService.pickCamera()).thenAnswer(
        (_) => Future.value(PickedFile("assets/images/facebook_f.png")));

    when(_imageService.uploadFile(any, any)).thenReturn(_storageReference);

    when(_storageReference.putFile(any)).thenReturn(_storageUploadTask);

    when(_storageReference.getDownloadURL())
        .thenAnswer((_) => Future.value(""));

    //WHEN
    await tester.pumpWidget(buildTestableWidget(EditItemPage()));
    await tester.pumpAndSettle(Duration(seconds: 1));

    await tester.tap(find.byKey(Key("item_picture_button")));
    await tester.pumpAndSettle(Duration(seconds: 1));

    // THEN
    verify(_imageService.pickCamera());
  });
}
