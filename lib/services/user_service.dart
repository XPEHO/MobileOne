import 'package:MobileOne/dao/user_dao.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserService with ChangeNotifier {
  static User _user;
  final _prefService = GetIt.I.get<PreferencesService>();
  final _userDao = GetIt.I.get<UserDao>();

  User get user {
    return _user;
  }

  set user(User user) {
    _user = user;
    notifyListeners();
  }

  Future<String> deleteAccount(User user) async {
    try {
      await user.delete();
      return "success";
    } catch (e) {
      return e.code;
    }
  }

  Future<void> deleteUserData(String userUid) async {
    await _userDao.deleteUserData(userUid, user);
  }

  bool checkCurrentUser(String email, String password) {
    if (_prefService.getEmail() == email &&
        _prefService.getPassword() == password) {
      return true;
    }
    return false;
  }
}
