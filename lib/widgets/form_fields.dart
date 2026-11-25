import 'package:flutter/material.dart';

InputDecoration buildAppInputDecoration({
  required String hintText,
  required IconData icon,
  required Color primaryColor,
  double iconBottomPadding = 0,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
    prefixIcon: iconBottomPadding > 0
        ? Padding(
      padding: EdgeInsets.only(bottom: iconBottomPadding),
      child: Icon(icon, color: primaryColor, size: 22),
    )
        : Icon(icon, color: primaryColor, size: 22),
    filled: true,
    fillColor: const Color(0xFFF8F9FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryColor, width: 1.5),
    ),
  );
}

class AppPickerField extends StatelessWidget {
  final String label;
  final String displayText;
  final bool hasValue;
  final IconData icon;
  final Color primaryColor;
  final VoidCallback onTap;

  const AppPickerField({
    super.key,
    required this.label,
    required this.displayText,
    required this.hasValue,
    required this.icon,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                        color: hasValue ? Colors.black87 : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, size: 18, color: primaryColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
