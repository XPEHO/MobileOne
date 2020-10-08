import 'package:flutter/material.dart';

class BubbleButton extends StatelessWidget {
  final Function onPressed;
  final Widget icon;
  final Color color;
  final double height;
  final double width;
  final double topLeft;
  final double topRight;
  final double bottomRight;
  final double bottomLeft;

  BubbleButton({
    @required this.icon,
    this.color = Colors.red,
    @required this.onPressed,
    this.height = 36,
    this.width = 36,
    this.topLeft = 36,
    this.topRight = 36,
    this.bottomRight = 36,
    this.bottomLeft = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Material(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeft),
          topRight: Radius.circular(topRight),
          bottomRight: Radius.circular(bottomRight),
          bottomLeft: Radius.circular(bottomLeft),
        ),
        color: color,
        elevation: 4.0,
        child: InkWell(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft),
            topRight: Radius.circular(topRight),
            bottomRight: Radius.circular(bottomRight),
            bottomLeft: Radius.circular(bottomLeft),
          ),
          splashColor: Colors.orange,
          onTap: () => onPressed(),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
