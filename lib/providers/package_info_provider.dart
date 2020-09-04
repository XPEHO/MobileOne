import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class PackageInfoProvider extends ChangeNotifier {
  PackageInfo _packageInfo;

  PackageInfo get packageInfo => _packageInfo;

  Future<void> setPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    notifyListeners();
  }
}
