import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/package_info_provider.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  State<StatefulWidget> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  final _packageProvider = GetIt.I.get<PackageInfoProvider>();

  @override
  void initState() {
    _packageProvider.setPackageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _packageProvider,
      child: Consumer<PackageInfoProvider>(
          builder: (context, packageInfoProvider, child) {
        if (_packageProvider.packageInfo == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return AlertDialog(
              title: Text(getString(context, "about") +
                  _packageProvider.packageInfo.appName),
              actions: [
                FlatButton(
                  child: Text(getString(context, "leave_about_screen")),
                  onPressed: Navigator.of(context).pop,
                ),
              ],
              content: aboutApp(context));
        }
      }),
    );
  }

  aboutApp(BuildContext context) {
    return Wrap(
      children: [
        Text(
          getString(context, "name_of_app") +
              _packageProvider.packageInfo.appName,
        ),
        Text(getString(context, "version") +
            _packageProvider.packageInfo.version),
        Text(
          getString(context, "company") + getString(context, "company_name"),
        ),
        Row(
          children: [
            Text(
              getString(context, "website"),
            ),
            InkWell(
              child: Text(getString(context, "xpeho_website"),
                  style: TextStyle(
                      color: BLUE, decoration: TextDecoration.underline)),
              onTap: () async {
                if (await canLaunch("https://xpeho.fr")) {
                  launch("https://xpeho.fr");
                } else {
                  Fluttertoast.showToast(
                      msg: getString(context, 'cant_launch_url'));
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
