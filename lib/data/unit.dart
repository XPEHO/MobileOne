import 'package:MobileOne/localization/localization.dart';
import 'package:flutter/material.dart';

String toStringUnit(BuildContext context, int id) {
  switch (id) {
    case 1:
      return getString(context, 'item_unit');
      break;
    case 2:
      return getString(context, 'item_liters');
      break;
    case 3:
      return getString(context, 'item_grams');
      break;
    case 4:
      return getString(context, 'item_kilos');
      break;
    case 5:
      return getString(context, "item_packs");
      break;
    case 6:
      return getString(context, "item_boxes");
      break;
    case 7:
      return getString(context, "item_bottles");
      break;
    case 8:
      return getString(context, "item_cans");
      break;
    case 9:
      return getString(context, "item_cartons");
      break;
    default:
      return getString(context, 'item_unit');
      break;
  }
}

int toUnitId(BuildContext context, String label) {
  if (label == getString(context, 'item_unit')) {
    return 1;
  } else if (label == getString(context, 'item_liters')) {
    return 2;
  } else if (label == getString(context, 'item_grams')) {
    return 3;
  } else if (label == getString(context, 'item_kilos')) {
    return 4;
  } else if (label == getString(context, "item_packs")) {
    return 5;
  } else if (label == getString(context, "item_boxes")) {
    return 6;
  } else if (label == getString(context, "item_bottles")) {
    return 7;
  } else if (label == getString(context, "item_cans")) {
    return 8;
  } else if (label == getString(context, "item_cartons")) {
    return 9;
  } else {
    return 1;
  }
}
