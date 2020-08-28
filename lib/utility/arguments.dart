class ShareArguments {
  var previousList;
  bool isOnlyOneStep;
  ShareArguments({this.previousList, this.isOnlyOneStep});
}

class ItemArguments {
  String buttonName;
  String listUuid;
  String itemUuid;
  ItemArguments({this.buttonName, this.listUuid, this.itemUuid});
}

class OpenedListArguments {
  String listUuid;
  bool isGuest;
  OpenedListArguments({this.listUuid, this.isGuest});
}
