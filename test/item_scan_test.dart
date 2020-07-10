import 'dart:convert';
import 'dart:ui';

import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/widgets/widget_popup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class ItemsListProviderMock extends Mock implements ItemsListProvider {}

main() {
  group('Items scan tests', () {
    setSupportedLocales([Locale('fr', 'FR')]);
    var _itemsProvider = ItemsListProviderMock();
    GetIt.I.registerSingleton<ItemsListProvider>(_itemsProvider);
    final _editItemPopupState = EditItemPopupState("", "", "");
    test('Item label should be set to scanned item name', () async {
      //GIVEN
      var response = await http.get(
          "https://world.openfoodfacts.org/api/v0/product/3168930005476.json");
      Map<String, dynamic> article = jsonDecode(response.body);

      //WHEN
      if (article["product"] != null) {
        _editItemPopupState.itemNameController.text =
            article["product"]["product_name"].toString() +
                " - " +
                article["product"]["brands"].toString();
      }

      //THEN
      expect(_editItemPopupState.itemNameController.text,
          "3D's bugles goût bacon - Benenuts,Pepsico");
    });

    test('Item image should be set to scanned item image', () async {
      //GIVEN
      var response = await http.get(
          "https://world.openfoodfacts.org/api/v0/product/3168930005476.json");
      Map<String, dynamic> article = jsonDecode(response.body);

      //WHEN
      if (article["product"] != null) {
        _editItemPopupState.imageLink =
            article["product"]["image_small_url"].toString();
      }

      //THEN
      expect(_editItemPopupState.imageLink,
          "https://static.openfoodfacts.org/images/products/316/893/000/5476/front_fr.13.200.jpg");
    });

    test('An error should appear when an item is unknown', () async {
      //GIVEN
      var response = await http
          .get("https://world.openfoodfacts.org/api/v0/product/31476.json");
      Map<String, dynamic> article = jsonDecode(response.body);

      //WHEN
      if (article["product"] == null) {
        _editItemPopupState.alert =
            "Malheureusement, nous ne parvenons pas à trouver cet article";
      }

      //THEN
      expect(_editItemPopupState.alert,
          "Malheureusement, nous ne parvenons pas à trouver cet article");
    });
  });
}
