import 'package:MobileOne/dao/categories_dao.dart';
import 'package:MobileOne/data/categories.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class CategoriesService {
  final CategoriesDao dao = GetIt.I.get<CategoriesDao>();
  final UserService userService = GetIt.I.get<UserService>();
  List<Categories> _categories = [];

  List<Categories> getCategories() => _categories;

  Future<List<Categories>> fetchCategories(BuildContext context) async {
    _categories.add(
        Categories.fromMap(null, getString(context, "null_category"), true));
    List<Map<String, dynamic>> map =
        await dao.getCategories(userService.user.uid);
    map.forEach((element) {
      switch (element["id"]) {
        case "78amWnyUJe3ekEs9FD53":
          _categories.add(Categories.fromMap(
              element["id"], getString(context, "recipy_category"), true));
          break;
        case "8jzs8g05JvvVQ87DI9wL":
          _categories.add(Categories.fromMap(
              element["id"], getString(context, "food_category"), true));
          break;
        default:
          _categories
              .add(Categories.fromMap(element["id"], element["label"], false));
          break;
      }
    });

    return _categories;
  }

  addCategory(String categoryLabel) async {
    final categoryUuid = Uuid().v4();
    await dao.addCategory(userService.user.uid, categoryUuid, categoryLabel);
    _categories = [];
  }

  updateCategory(String categoryUuid, String categoryLabel) async {
    await dao.updateCategory(userService.user.uid, categoryUuid, categoryLabel);
    _categories = [];
  }

  deleteCategory(String categoryUuid) async {
    await dao.deleteCategory(userService.user.uid, categoryUuid);
    _categories = [];
  }
}
