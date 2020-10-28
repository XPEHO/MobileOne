import 'package:MobileOne/data/categories.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/categories_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/widget_category_label.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoriesPageState();
  }
}

class CategoriesPageState extends State<CategoriesPage> {
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();

  @override
  void initState() {
    _analytics.setCurrentPage("isOnCategoriesPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<CategoriesProvider>(),
      child: Consumer<CategoriesProvider>(
          builder: (context, categoriesProvider, child) {
        return Builder(builder: (BuildContext context) {
          return content(categoriesProvider.getCategories(context));
        });
      }),
    );
  }

  Widget content(List<Categories> categories) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: _colorsApp.colorTheme,
      body: SafeArea(
        child: buildCategories(categories),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        getString(context, "categories_title"),
        style: TextStyle(color: WHITE),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: WHITE),
          onPressed: () {
            buildPopUp(false);
          },
        ),
      ],
      backgroundColor: _colorsApp.colorTheme,
    );
  }

  Container buildCategories(List<Categories> categories) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: categories.length,
        itemBuilder: (BuildContext ctxt, int index) {
          List<TextEditingController> controllerList =
              List.generate(categories.length, (index) {
            return TextEditingController();
          });
          controllerList[index].text = categories[index].label;
          return categoryTile(categories[index], controllerList[index]);
        },
      ),
    );
  }

  ListTile categoryTile(Categories category, TextEditingController controller) {
    return ListTile(
      tileColor: WHITE,
      leading: Text(category.label),
      trailing: category.isDefaultCategory
          ? IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.grey,
              ),
              onPressed: () {
                Fluttertoast.showToast(
                    msg: getString(context, 'cant_edit_category'));
              },
            )
          : IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.black,
              ),
              onPressed: () {
                buildPopUp(true, category: category);
              },
            ),
    );
  }

  Future<void> buildPopUp(bool update, {Categories category}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          if (category != null) {
            return WidgetCategoryLabel(
              update,
              category: category,
            );
          } else {
            return WidgetCategoryLabel(update);
          }
        });
  }
}
