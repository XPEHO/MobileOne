import 'package:flutter/material.dart';

class BubbleButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final Color color;
  final Color iconColor;

  BubbleButton({
    @required this.icon,
    this.color = Colors.red,
    @required this.onPressed,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 36,
      child: Material(
        borderRadius: BorderRadius.circular(36.0),
        color: color,
        elevation: 4.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(36.0),
          splashColor: Colors.orange,
          onTap: () => onPressed(),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
