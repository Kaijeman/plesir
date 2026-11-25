import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final Color primaryColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final double elevation;
  final double fontSize;
  final EdgeInsetsGeometry? margin;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.primaryColor,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius = 14,
    this.elevation = 2,
    this.fontSize = 16,
    this.margin,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (icon != null) {
      return Container(
        width: double.infinity,
        height: height,
        margin: margin,
        child: ElevatedButton.icon(
          style: style,
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? Container(
            width: 20,
            height: 20,
            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : icon!,
          label: Text(
            label,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: height,
      margin: margin,
      child: ElevatedButton(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? Container(
          width: 24,
          height: 24,
          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
        )
            : Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
