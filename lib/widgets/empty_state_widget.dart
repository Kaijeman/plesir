import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? titleStyle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconSize = 72,
    this.iconColor,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? Colors.grey.shade400,
        ),
        Padding(
          padding: EdgeInsets.only(top: subtitle != null ? 16 : 12, bottom: subtitle != null ? 8 : 0),
          child: Text(
            title,
            style: titleStyle ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
      ],
    );
  }
}
