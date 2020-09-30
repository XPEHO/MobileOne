import 'package:permission_handler/permission_handler.dart';

Future<PermissionStatus> getContactPermission() async {
  PermissionStatus permissionStatus = await Permission.contacts.status;
  if (permissionStatus != PermissionStatus.granted &&
      permissionStatus != PermissionStatus.restricted) {
    permissionStatus = await Permission.contacts.request();
    return permissionStatus ?? PermissionStatus.undetermined;
  } else {
    return permissionStatus;
  }
}
