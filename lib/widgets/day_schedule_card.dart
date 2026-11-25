import 'package:flutter/material.dart';

class DayScheduleCard extends StatelessWidget {
  final Map<String, dynamic> hari;
  final Color primaryColor;
  final Future<void> Function(Map<String, dynamic> akt) onEditActivity;
  final Future<void> Function(Map<String, dynamic> akt) onDeleteActivity;

  const DayScheduleCard({
    super.key,
    required this.hari,
    required this.primaryColor,
    required this.onEditActivity,
    required this.onDeleteActivity,
  });

  @override
  Widget build(BuildContext context) {
    final List aktivitasList = hari['aktivitas'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.today_rounded, size: 18, color: primaryColor),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Hari ${hari['hari_ke']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      ' • ${hari['tgl_spesifik']}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
                Text(
                  '${aktivitasList.length} Aktivitas',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: aktivitasList.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, aktIndex) {
              final akt = aktivitasList[aktIndex] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 15, color: primaryColor),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                akt['jam'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            akt['kategori'],
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
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: Text(
                        akt['tempat'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Biaya: ${akt['biaya']}',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        Row(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                              onPressed: () => onEditActivity(akt),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                onPressed: () => onDeleteActivity(akt),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (akt['catatan'] != null && akt['catatan'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Catatan: ${akt['catatan']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
