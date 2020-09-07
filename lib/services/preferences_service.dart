import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  SharedPreferences _sharedPreferences;

  void initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  get sharedPreferences {
    return _sharedPreferences;
  }

  setString(key, value) {
    _sharedPreferences.setString(key, value);
  }

  setBool(key, value) {
    _sharedPreferences.setBool(key, value);
  }

  bool get enableNotifications {
    if (getBool("enableNotifications") == null ||
        getBool("enableNotifications") == true) {
      return true;
    } else {
      return false;
    }
  }

  set enableNotifications(bool value) {
    _sharedPreferences.setBool("enableNotifications", value);
  }

  getString(key) => _sharedPreferences.getString(key);

  getBool(key) => _sharedPreferences.getBool(key);

  getMode() => getString("mode");

  isGoogleMode() => getMode() == "google";

  isEmailPasswordMode() => getMode() == "emailpassword";

  getEmail() => getString("email");

  getPassword() => getString("password");
}
