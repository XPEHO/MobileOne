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
  } else {
    return 1;
  }
}
