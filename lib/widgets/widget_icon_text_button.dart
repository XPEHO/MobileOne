import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconTextButton extends StatelessWidget {
  final Key key;
  final Color backgroundColor;
  final IconData iconData;
  final String iconAsset;
  final Color iconColor;
  final Function onPressed;
  final String text;
  final Color textColor;

  IconTextButton({
    this.key,
    this.iconData,
    this.iconAsset,
    @required this.onPressed,
    this.backgroundColor = Colors.black,
    this.iconColor = Colors.white,
    this.text = "",
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: this.backgroundColor,
      child: InkWell(
        onTap: () => this.onPressed(),
        child: Container(
          height: 76.0,
          width: 76.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                child: buildIcon(),
              ),
              this.text.isEmpty
                  ? Container()
                  : Text(
                      this.text,
                      style: TextStyle(
                        color: this.textColor,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIcon() {
    if (iconData != null) {
      return Icon(
        this.iconData,
        color: this.iconColor,
        size: 24,
      );
    }
    return SvgPicture.asset(
      iconAsset,
      color: WHITE,
      width: 24,
      height: 24,
    );
  }
}
