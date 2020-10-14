import 'dart:math';

import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CurvePainter extends CustomPainter {
  final Wishlist wishlist;

  CurvePainter(this.wishlist);

  var _wishlistProvider = GetIt.I.get<WishlistHeadProvider>();

  Color _color = Colors.white;

  getColor() {
    if (wishlist.color == null) {
      int generatedColor = generateColor();
      _color = HSLColor.fromColor(Color(generatedColor)).toColor();
      _wishlistProvider.setWishlistColor(wishlist.uuid, generatedColor, false);
    } else {
      _color = HSLColor.fromColor(Color(wishlist.color)).toColor();
    }
  }

  String generateRandomHexColor() {
    int length = 6;
    String chars = '0123456789ABCDEF';
    String hex = '#';
    while (length-- > 0) hex += chars[(Random().nextInt(16)) | 0];
    return hex;
  }

  int generateColor() {
    var hexColor = generateRandomHexColor();
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  @override
  void paint(Canvas canvas, Size size) {
    getColor();
    Path path = Path();
    Paint paint = Paint();

    path = Path();
    path.lineTo(0, size.height * 0.95);
    path.lineTo(size.height * 0.1, size.height * 0.9);
    path.lineTo(size.height * 0.15, size.height * 0.95);
    path.lineTo(size.height * 0.2, size.height * 0.9);
    path.lineTo(size.height * 0.25, size.height * 0.95);
    path.lineTo(size.height * 0.3, size.height * 0.9);
    path.lineTo(size.height * 0.35, size.height * 0.95);
    path.lineTo(size.height * 0.4, size.height * 0.9);
    path.lineTo(size.height * 0.45, size.height * 0.9);
    path.lineTo(size.height * 0.5, size.height * 0.95);
    path.lineTo(size.height * 0.55, size.height * 0.8);
    path.lineTo(size.height * 0.6, size.height * 0.9);
    path.lineTo(size.height * 0.65, size.height * 0.95);
    path.lineTo(size.height * 0.7, size.height * 0.9);
    path.lineTo(size.width, size.height * 0.95);
    path.lineTo(size.width, 0);

    path.close();

    paint.color = _color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
