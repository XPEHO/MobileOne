import 'package:MobileOne/pages/openedListPage.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class ItemsListProviderMock extends Mock implements ItemsListProvider {}

main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('itemsListProvider', () {
    var _itemsProvider = ItemsListProviderMock();
    GetIt.I.registerSingleton<ItemsListProvider>(_itemsProvider);
    var _openedListPageState = OpenedListPageState();

    test('item dismissible should call deleteItemInList method', () async {
      //GIVEN

      //WHEN
      _openedListPageState.deleteItemFromList("");

      //THEN
      verify(await _itemsProvider.deleteItemInList(any));
    });
  });
}
