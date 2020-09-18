import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/email_service.dart';
import 'package:MobileOne/services/messaging_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareProvider with ChangeNotifier {
  final wishlistService = GetIt.I.get<WishlistService>();
  final _messagingService = GetIt.I.get<MessagingService>();
  final _userService = GetIt.I.get<UserService>();
  final _emailService = GetIt.I.get<EmailService>();

  List get ownerLists {
    final ownerLists = wishlistService.ownerLists;
    if (ownerLists == null) {
      wishlistService.fetchOwnerLists().then((value) => notifyListeners());
    }
    return ownerLists;
  }

  Map<String, dynamic> get shareLists {
    Map<String, dynamic> shareLists = wishlistService.getSharelist();
    if (shareLists == null) {
      wishlistService.fetchShareLists().whenComplete(() => notifyListeners());
    }
    return shareLists;
  }

  shareAList(String email, String listUuid, BuildContext context) async {
    bool userExist = await _userService.checkUserExistence(email);
    addSharedToDataBase(email, listUuid);
    addGuestToDataBase(email, listUuid);
    if (userExist) {
      _messagingService.setNotification(
          destEmail: email,
          title: getString(context, "share_notif_title"),
          body:
              _userService.user.email + getString(context, "share_notif_body"));
    } else {
      _emailService.sendEmail(context, email);
    }
  }

  addSharedToDataBase(String sharedWith, String liste) async {
    wishlistService.addSharedToDataBase(sharedWith, liste);
    notifyListeners();
  }

  addGuestToDataBase(String email, String listUuid) async {
    wishlistService.addGuestToDataBase(email, listUuid);
    notifyListeners();
  }

  deleteShared(String listUuid, String email) async {
    wishlistService.deleteShared(listUuid, email);
    notifyListeners();
  }
}
