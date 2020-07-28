import 'package:flutter/material.dart';

class BubbleButton extends StatelessWidget {
  final Function onPressed;
  final Widget icon;
  final Color color;
  final double height;
  final double width;

  BubbleButton({
    @required this.icon,
    this.color = Colors.red,
    @required this.onPressed,
    this.height = 36,
    this.width = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Material(
        borderRadius: BorderRadius.circular(36.0),
        color: color,
        elevation: 4.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(36.0),
          splashColor: Colors.orange,
          onTap: () => onPressed(),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
