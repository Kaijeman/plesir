import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/sqlite_service.dart';
import '../services/supabase_service.dart';

class TripController {
  static final TripController _instance = TripController._internal();
  factory TripController() => _instance;
  TripController._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final SqliteService _sqliteService = SqliteService();
  final Uuid _uuid = const Uuid();

  // Pemicu auto-refresh lintas tab (HomeScreen & TripListScreen)
  final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  void notifyDataChanged() {
    refreshNotifier.value++;
  }

  bool get isLoggedIn => _supabaseService.currentUserId != null;

  // ==================== FORMATTERS ====================

  static const List<String> _shortMonths = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  String toIsoDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DateTime parseDateSafe(String raw) {
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

  String formatDisplayDate(String raw) {
    final dt = parseDateSafe(raw);
    return '${dt.day} ${_shortMonths[dt.month]} ${dt.year}';
  }

  String formatRupiah(int amount) {
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

  // ==================== TRIPS CRUD ====================

  Future<List<Map<String, dynamic>>> getTrips() async {
    try {
      List<Map<String, dynamic>> rawData;

      if (isLoggedIn) {
        try {
          rawData = await _supabaseService.getTrips();
          for (final item in rawData) {
            await _sqliteService.upsertTripLocal({
              'id': item['id'].toString(),
              'judul': item['judul'] ?? 'Tanpa Judul',
              'tgl_mulai': item['tgl_mulai'] ?? toIsoDate(DateTime.now()),
              'tgl_selesai': item['tgl_selesai'] ?? toIsoDate(DateTime.now()),
              'durasi': item['durasi'] ?? '1 Hari',
              'created_at': item['created_at'] ?? DateTime.now().toIso8601String(),
              'is_synced': 1,
              'is_deleted': 0,
            });
          }
        } catch (_) {
          rawData = await _sqliteService.getTripsLocal();
        }
      } else {
        rawData = await _sqliteService.getTripsLocal();
      }

      return rawData.map(_formatTripItem).toList();
    } catch (e) {
      throw Exception('Gagal memuat data perjalanan: $e');
    }
  }

  Future<Map<String, dynamic>> getHomeOverview() async {
    final trips = await getTrips();
    if (trips.isEmpty) {
      return {
        'total_trips': 0,
        'total_biaya': 'Rp 0',
        'latest_trips': [],
        'upcoming': null,
      };
    }

    // Hitung total estimasi biaya seluruh aktivitas
    int totalBiaya = 0;
    try {
      final activities = isLoggedIn
          ? await _supabaseService.getAllActivities()
          : await _sqliteService.getAllActiveActivitiesLocal();
      for (final act in activities) {
        totalBiaya += (act['biaya'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {
      final localActs = await _sqliteService.getAllActiveActivitiesLocal();
      for (final act in localActs) {
        totalBiaya += (act['biaya'] as num?)?.toInt() ?? 0;
      }
    }

    // Cari Rencana Terdekat (hari ini atau masa depan paling dekat)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Map<String, dynamic>? upcomingTrip;
    Duration? minDiff;

    for (final trip in trips) {
      final startDt = trip['tgl_mulai_dt'] as DateTime;
      final diff = startDt.difference(today);
      if (diff.inDays >= 0) {
        if (minDiff == null || diff < minDiff) {
          minDiff = diff;
          upcomingTrip = trip;
        }
      }
    }
    upcomingTrip ??= trips.first;

    return {
      'total_trips': trips.length,
      'total_biaya': formatRupiah(totalBiaya),
      'latest_trips': trips.take(3).toList(),
      'upcoming': upcomingTrip,
    };
  }

  Future<void> createTrip({
    required String judul,
    required DateTime tglMulai,
    required DateTime tglSelesai,
  }) async {
    final newId = _uuid.v4();
    final daysCount = tglSelesai.difference(tglMulai).inDays + 1;
    final durasi = '${daysCount < 1 ? 1 : daysCount} Hari';
    final nowIso = DateTime.now().toIso8601String();

    final payload = {
      'id': newId,
      'judul': judul.trim(),
      'tgl_mulai': toIsoDate(tglMulai),
      'tgl_selesai': toIsoDate(tglSelesai),
      'durasi': durasi,
      'created_at': nowIso,
    };

    await _sqliteService.upsertTripLocal({
      ...payload,
      'is_synced': 0,
      'is_deleted': 0,
    });

    if (isLoggedIn) {
      try {
        await _supabaseService.upsertTrip(payload);
        await _sqliteService.updateTripLocal(newId, {'is_synced': 1});
      } catch (_) {}
    }

    notifyDataChanged();
  }

  Future<void> updateTrip({
    required String id,
    required String judul,
    required DateTime tglMulai,
    required DateTime tglSelesai,
  }) async {
    final daysCount = tglSelesai.difference(tglMulai).inDays + 1;
    final durasi = '${daysCount < 1 ? 1 : daysCount} Hari';

    final updated = {
      'judul': judul.trim(),
      'tgl_mulai': toIsoDate(tglMulai),
      'tgl_selesai': toIsoDate(tglSelesai),
      'durasi': durasi,
    };

    await _sqliteService.updateTripLocal(id, {
      ...updated,
      'is_synced': 0,
    });

    if (isLoggedIn) {
      try {
        await _supabaseService.updateTrip(id, updated);
        await _sqliteService.updateTripLocal(id, {'is_synced': 1});
      } catch (_) {}
    }

    notifyDataChanged();
  }

  Future<void> deleteTrip(String id) async {
    if (isLoggedIn) {
      try {
        await _supabaseService.deleteTrip(id);
        await _sqliteService.hardDeleteTripLocal(id);
      } catch (_) {
        await _sqliteService.softDeleteTripLocal(id);
      }
    } else {
      await _sqliteService.hardDeleteTripLocal(id);
    }

    notifyDataChanged();
  }

  // ==================== TRIP DETAIL & ACTIVITIES CRUD ====================

  Future<Map<String, dynamic>> getTripDetails(String tripId) async {
    Map<String, dynamic>? rawTrip;
    List<Map<String, dynamic>> rawActivities = [];

    if (isLoggedIn) {
      try {
        rawTrip = await _supabaseService.getTripById(tripId);
        rawActivities = await _supabaseService.getActivitiesByTrip(tripId);
      } catch (_) {
        rawTrip = await _sqliteService.getTripByIdLocal(tripId);
        rawActivities = await _sqliteService.getActivitiesByTripLocal(tripId);
      }
    } else {
      rawTrip = await _sqliteService.getTripByIdLocal(tripId);
      rawActivities = await _sqliteService.getActivitiesByTripLocal(tripId);
    }

    if (rawTrip == null) {
      throw Exception('Data perjalanan tidak ditemukan.');
    }

    final startDt = parseDateSafe(rawTrip['tgl_mulai'] ?? '');
    final endDt = parseDateSafe(rawTrip['tgl_selesai'] ?? '');
    final totalDays = (endDt.difference(startDt).inDays + 1).clamp(1, 365);

    int totalBiaya = 0;
    for (final act in rawActivities) {
      totalBiaya += (act['biaya'] as num?)?.toInt() ?? 0;
    }

    // Susun struktur per hari untuk TripDetailScreen
    final List<Map<String, dynamic>> hariList = [];
    for (int i = 1; i <= totalDays; i++) {
      final currentDayDt = startDt.add(Duration(days: i - 1));
      final dayActivities = rawActivities
          .where((a) => ((a['hari_ke'] as num?)?.toInt() ?? 1) == i)
          .map((a) {
        final biayaInt = (a['biaya'] as num?)?.toInt() ?? 0;
        final jamMulai = a['jam_mulai']?.toString() ?? '08:00';
        final jamSelesai = a['jam_selesai']?.toString() ?? '10:00';
        return {
          'id': a['id'].toString(),
          'hari_ke': i,
          'jam': '$jamMulai - $jamSelesai',
          'jam_mulai': jamMulai,
          'jam_selesai': jamSelesai,
          'tempat': a['tempat'] ?? '',
          'kategori': a['kategori'] ?? 'Kota',
          'biaya': formatRupiah(biayaInt),
          'biaya_raw': biayaInt,
          'catatan': a['catatan'] ?? '',
        };
      }).toList();

      hariList.add({
        'hari_ke': i,
        'tgl_spesifik': formatDisplayDate(toIsoDate(currentDayDt)),
        'aktivitas': dayActivities,
      });
    }

    return {
      'id': rawTrip['id'].toString(),
      'judul': rawTrip['judul'] ?? 'Tanpa Judul',
      'tgl_mulai': formatDisplayDate(rawTrip['tgl_mulai'] ?? ''),
      'tgl_selesai': formatDisplayDate(rawTrip['tgl_selesai'] ?? ''),
      'tgl_mulai_dt': startDt,
      'tgl_selesai_dt': endDt,
      'total_hari': totalDays,
      'total_biaya': formatRupiah(totalBiaya),
      'hari': hariList,
    };
  }

  Future<void> createActivity({
    required String tripId,
    required int hariKe,
    required String jamMulai,
    required String jamSelesai,
    required String tempat,
    required String kategori,
    required int biaya,
    String? catatan,
  }) async {
    final newId = _uuid.v4();
    final nowIso = DateTime.now().toIso8601String();

    final payload = {
      'id': newId,
      'trip_id': tripId,
      'hari_ke': hariKe,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'tempat': tempat.trim(),
      'kategori': kategori,
      'biaya': biaya,
      'catatan': catatan?.trim() ?? '',
      'created_at': nowIso,
    };

    await _sqliteService.upsertActivityLocal({
      ...payload,
      'is_synced': 0,
      'is_deleted': 0,
    });

    if (isLoggedIn) {
      try {
        await _supabaseService.upsertActivity(payload);
        await _sqliteService.updateActivityLocal(newId, {'is_synced': 1});
      } catch (_) {}
    }

    notifyDataChanged();
  }

  Future<void> updateActivity({
    required String id,
    required int hariKe,
    required String jamMulai,
    required String jamSelesai,
    required String tempat,
    required String kategori,
    required int biaya,
    String? catatan,
  }) async {
    final updated = {
      'hari_ke': hariKe,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'tempat': tempat.trim(),
      'kategori': kategori,
      'biaya': biaya,
      'catatan': catatan?.trim() ?? '',
    };

    await _sqliteService.updateActivityLocal(id, {
      ...updated,
      'is_synced': 0,
    });

    if (isLoggedIn) {
      try {
        await _supabaseService.updateActivity(id, updated);
        await _sqliteService.updateActivityLocal(id, {'is_synced': 1});
      } catch (_) {}
    }

    notifyDataChanged();
  }

  Future<void> deleteActivity(String id) async {
    if (isLoggedIn) {
      try {
        await _supabaseService.deleteActivity(id);
        await _sqliteService.hardDeleteActivityLocal(id);
      } catch (_) {
        await _sqliteService.softDeleteActivityLocal(id);
      }
    } else {
      await _sqliteService.hardDeleteActivityLocal(id);
    }

    notifyDataChanged();
  }

  // ==================== SYNC ENGINE (GUEST -> CLOUD) ====================

  Future<void> syncAllData() async {
    if (!isLoggedIn) return;

    // 1. Sinkronkan trips yang belum terunggah / terhapus offline
    final unsyncedTrips = await _sqliteService.getUnsyncedTrips();
    for (final trip in unsyncedTrips) {
      final id = trip['id'].toString();
      if ((trip['is_deleted'] as int? ?? 0) == 1) {
        await _supabaseService.deleteTrip(id);
        await _sqliteService.hardDeleteTripLocal(id);
      } else {
        await _supabaseService.upsertTrip(trip);
        await _sqliteService.updateTripLocal(id, {'is_synced': 1});
      }
    }

    // 2. Sinkronkan activities yang belum terunggah / terhapus offline
    final unsyncedActs = await _sqliteService.getUnsyncedActivities();
    for (final act in unsyncedActs) {
      final id = act['id'].toString();
      if ((act['is_deleted'] as int? ?? 0) == 1) {
        await _supabaseService.deleteActivity(id);
        await _sqliteService.hardDeleteActivityLocal(id);
      } else {
        await _supabaseService.upsertActivity(act);
        await _sqliteService.updateActivityLocal(id, {'is_synced': 1});
      }
    }

    // 3. Tarik data terbaru dari cloud ke cache SQLite
    final cloudTrips = await _supabaseService.getTrips();
    for (final item in cloudTrips) {
      await _sqliteService.upsertTripLocal({
        'id': item['id'].toString(),
        'judul': item['judul'] ?? 'Tanpa Judul',
        'tgl_mulai': item['tgl_mulai'] ?? toIsoDate(DateTime.now()),
        'tgl_selesai': item['tgl_selesai'] ?? toIsoDate(DateTime.now()),
        'durasi': item['durasi'] ?? '1 Hari',
        'created_at': item['created_at'] ?? DateTime.now().toIso8601String(),
        'is_synced': 1,
        'is_deleted': 0,
      });
    }

    final cloudActs = await _supabaseService.getAllActivities();
    for (final act in cloudActs) {
      await _sqliteService.upsertActivityLocal({
        'id': act['id'].toString(),
        'trip_id': act['trip_id'].toString(),
        'hari_ke': (act['hari_ke'] as num?)?.toInt() ?? 1,
        'jam_mulai': act['jam_mulai'] ?? '08:00',
        'jam_selesai': act['jam_selesai'] ?? '10:00',
        'tempat': act['tempat'] ?? '',
        'kategori': act['kategori'] ?? 'Kota',
        'biaya': (act['biaya'] as num?)?.toInt() ?? 0,
        'catatan': act['catatan'] ?? '',
        'created_at': act['created_at'] ?? DateTime.now().toIso8601String(),
        'is_synced': 1,
        'is_deleted': 0,
      });
    }

    notifyDataChanged();
  }

  Map<String, dynamic> _formatTripItem(Map<String, dynamic> item) {
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
