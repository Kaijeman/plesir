class AppFormatters {
  static const List<String> _shortMonths = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static String toIsoDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime parseDateSafe(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);

    final parts = raw.trim().split(' ');
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final monthIdx = _shortMonths.indexOf(parts[1]);
      final year = int.tryParse(parts[2]) ?? DateTime.now().year;
      return DateTime(year, monthIdx > 0 ? monthIdx : 1, day);
    }
    return DateTime.now();
  }

  static String formatDisplayDate(String raw) {
    final dt = parseDateSafe(raw);
    return '${dt.day} ${_shortMonths[dt.month]} ${dt.year}';
  }

  static String formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i;
      buffer.write(str[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp $buffer';
  }

  static Map<String, dynamic> formatTripItem(Map<String, dynamic> item) {
    final rawStart = item['tgl_mulai']?.toString() ?? '';
    final rawEnd = item['tgl_selesai']?.toString() ?? '';
    return {
      'id': item['id']?.toString() ?? '',
      'judul': item['judul'] ?? 'Tanpa Judul',
      'tgl_mulai': formatDisplayDate(rawStart),
      'tgl_selesai': formatDisplayDate(rawEnd),
      'tgl_mulai_dt': parseDateSafe(rawStart),
      'tgl_selesai_dt': parseDateSafe(rawEnd),
      'durasi': item['durasi'] ?? '-',
    };
  }
}
