import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlist_item_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/bubble_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class Quantity extends StatelessWidget {
  final _analytics = GetIt.I.get<AnalyticsService>();

  final WishlistItemProvider provider;
  final FocusNode _focusNode;
  final TextEditingController _editingController;

  Quantity(this.provider, this._focusNode, this._editingController) {
    _editingController.text = provider.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BubbleButton(
          icon: Icon(Icons.remove, color: WHITE),
          color: Colors.lime[600],
          onPressed: () => decrementCounter(provider),
          width: 48,
          height: 48,
          topLeft: 48,
          topRight: 0,
          bottomRight: 0,
          bottomLeft: 48,
        ),
        Container(
          width: 100,
          child: TextField(
            focusNode: _focusNode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(5),
            ],
            style: TextStyle(
              fontSize: 18,
            ),
            key: Key("item_count_label"),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: TRANSPARENT),
                borderRadius: BorderRadius.circular(0.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.lime[600],
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              filled: true,
              fillColor: Colors.grey[300],
              hintText: getString(context, 'item_count'),
            ),
            keyboardType: TextInputType.number,
            controller: _editingController,
            onChanged: (text) => provider.quantity = int.parse(text),
          ),
        ),
        BubbleButton(
          icon: Icon(Icons.add, color: WHITE),
          color: Colors.lime[600],
          onPressed: () => incrementCounter(provider),
          width: 48,
          height: 48.0,
          topLeft: 0,
          topRight: 48.0,
          bottomLeft: 0,
          bottomRight: 48.0,
        )
      ],
    );
  }

  void decrementCounter(WishlistItemProvider provider) {
    if (provider.canDecrement()) {
      _analytics.sendAnalyticsEvent("decrement_counter_quantity");
      provider.decreaseQuantity();
    }
  }

  void incrementCounter(WishlistItemProvider provider) {
    _analytics.sendAnalyticsEvent("increment_counter_quantity");
    provider.increaseQuantity();
  }
}
