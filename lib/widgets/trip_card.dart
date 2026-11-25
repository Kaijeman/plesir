import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final String title;
  final String dateRange;
  final String duration;
  final Color primaryColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final double bottomMargin;
  final double iconRightMargin;
  final double shadowAlpha;
  final double shadowBlur;
  final Offset shadowOffset;

  const TripCard({
    super.key,
    required this.title,
    required this.dateRange,
    required this.duration,
    required this.primaryColor,
    required this.onTap,
    this.trailing,
    this.bottomMargin = 16,
    this.iconRightMargin = 12,
    this.shadowAlpha = 0.04,
    this.shadowBlur = 10,
    this.shadowOffset = const Offset(0, 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowAlpha),
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: iconRightMargin),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.explore_outlined, color: primaryColor, size: 28),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              duration,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  dateRange,
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
