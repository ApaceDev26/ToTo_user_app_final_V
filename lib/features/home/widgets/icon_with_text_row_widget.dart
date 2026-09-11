import 'package:toto_user/util/dimensions.dart';
import 'package:flutter/material.dart';

class IconWithTextRowWidget extends StatelessWidget {
  const IconWithTextRowWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.style,
    this.color,
    this.iconSize,
  });

  final IconData icon;
  final String text;
  final TextStyle style;
  final Color? color;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 22),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(text, style: style),
      ],
    );
  }
}

class ImageWithTextRowWidget extends StatelessWidget {
  const ImageWithTextRowWidget({
    super.key,
    required this.widget,
    required this.text,
    required this.style,
    this.textWidget,
  });

  final Widget widget;
  final String text;
  final TextStyle style;
  final Widget? textWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget,
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        textWidget ?? Text(text, style: style),
      ],
    );
  }
}
