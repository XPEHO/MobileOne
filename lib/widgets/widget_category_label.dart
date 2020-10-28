import 'package:MobileOne/data/categories.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/categories_provider.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class WidgetCategoryLabel extends StatefulWidget {
  final Categories category;
  final bool update;

  WidgetCategoryLabel(this.update, {this.category});

  @override
  WidgetCategoryLabelState createState() => WidgetCategoryLabelState();
}

class WidgetCategoryLabelState extends State<WidgetCategoryLabel> {
  var _colorsApp = GetIt.I.get<ColorService>();
  var _categoryProvider = GetIt.I.get<CategoriesProvider>();
  final _controller = new TextEditingController();
  String _categoryLabel;

  @override
  void initState() {
    super.initState();
    if (widget.category != null && widget.category.label != null) {
      _controller.text = widget.category.label;
      _categoryLabel = widget.category.label;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _categoryLabel = null;
    super.dispose();
  }

  void handleSubmittedLabel(String input) {
    _categoryLabel = input;
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      backgroundColor: WHITE,
      scrollable: true,
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLines: 1,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(40),
                ],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
                controller: _controller,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                  isDense: true,
                  hintText: getString(context, "category_label"),
                ),
                onChanged: (text) => handleSubmittedLabel(text),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FlatButton(
                    child: Icon(
                      Icons.check,
                      color: WHITE,
                    ),
                    color: _colorsApp.colorTheme,
                    onPressed: () {
                      if (_categoryLabel != null && _categoryLabel != "") {
                        if (widget.update && widget.category != null) {
                          _categoryProvider.updateCategory(
                              widget.category.id, _categoryLabel);
                        } else {
                          _categoryProvider.addCategory(_categoryLabel);
                        }
                        Navigator.of(context).pop();
                      } else {
                        Fluttertoast.showToast(
                            msg: getString(context, 'fill_category_label'));
                      }
                    },
                  ),
                ),
                widget.update
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FlatButton(
                          child: Icon(
                            Icons.delete,
                            color: WHITE,
                          ),
                          color: _colorsApp.colorTheme,
                          onPressed: () {
                            bool isCategoryDeletable = _categoryProvider
                                .isCategoryDeletable(widget.category.id);
                            if (isCategoryDeletable) {
                              _categoryProvider
                                  .deleteCategory(widget.category.id);
                              Navigator.of(context).pop();
                            } else {
                              Fluttertoast.showToast(
                                  msg: getString(
                                      context, 'cant_delete_category'));
                            }
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
