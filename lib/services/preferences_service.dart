import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  SharedPreferences _sharedPreferences;

  void initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  getString(key) => _sharedPreferences.getString(key);

  getMode() => getString("mode");

  isGoogleMode() => getMode() == "google";

  isEmailPasswordMode() => getMode() == "emailpassword";

  getEmail() => getString("email");

  getPassword() => getString("password");
}