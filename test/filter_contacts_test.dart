import 'package:MobileOne/services/share_service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Filter contacts", () {
    //Given

    final service = ShareService();
    List<Contact> list = [
      Contact(displayName: "test", emails: {Item(value: "test@test.test")}),
      Contact(displayName: "second test"),
      Contact(),
      Contact(emails: {Item(value: "test@test.test")}),
    ];

    //When
    List<Contact> result = service.filterContacts(list, "second");

    //Then
    expect(result == null, false);
    expect(result.isNotEmpty, true);
    expect(
        result.singleWhere((element) => element.displayName == "second test") !=
            null,
        true);
    expect(result.length, 1);
  });
}
