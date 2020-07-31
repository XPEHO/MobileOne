import 'package:flutter/material.dart';

class RectangleTextIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  RectangleTextIcon(this.label, this.icon, this.iconColor);

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            //  onTap: () => onPressed(),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}
