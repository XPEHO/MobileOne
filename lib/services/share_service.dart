import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ShareService with ChangeNotifier {
  String _number;

  String get numberOfItemShared {
    return _number;
  }

  set numberOfItemShare(String number) {
    _number = number;
    notifyListeners();
  }

  List<Contact> filterContacts(List<Contact> _contactsList, String text) {
    List<Contact> _filteredContactsList = [];
    _filteredContactsList.addAll(_contactsList);
    if (text != null) {
      _filteredContactsList.retainWhere((contact) {
        if (contact.displayName != null) {
          String searchTerm = text.toLowerCase();
          String contactName = contact.displayName.toLowerCase();
          return contactName.contains(searchTerm);
        } else {
          return false;
        }
      });
    }
    return _filteredContactsList;
  }
}
