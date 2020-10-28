import 'package:MobileOne/data/categories.dart';
import 'package:MobileOne/services/categories_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoriesProvider with ChangeNotifier {
  final categoriesService = GetIt.I.get<CategoriesService>();
  final wishlistService = GetIt.I.get<WishlistService>();

  List<Categories> getCategories(BuildContext context) {
    List<Categories> categories = categoriesService.getCategories();
    if (categories.isEmpty) {
      categoriesService.fetchCategories(context).then((value) {
        if (value != null) {
          categories = value;
        }
        notifyListeners();
      });
    }
    return categories;
  }

  addCategory(String categoryLabel) async {
    await categoriesService.addCategory(categoryLabel);
    notifyListeners();
  }

  updateCategory(String categoryUuid, String categoryLabel) async {
    await categoriesService.updateCategory(categoryUuid, categoryLabel);
    notifyListeners();
  }

  bool isCategoryDeletable(String categoryUuid) {
    return wishlistService.isCategoryDeletable(categoryUuid);
  }

  deleteCategory(String categoryUuid) async {
    await categoriesService.deleteCategory(categoryUuid);
    notifyListeners();
  }
}
