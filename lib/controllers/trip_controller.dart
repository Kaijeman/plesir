import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/notification_service.dart';
import '../services/sqlite_service.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../utils/formatters.dart';

class TripController {
  static final TripController _instance = TripController._internal();
  factory TripController() => _instance;
  TripController._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final SqliteService _sqliteService = SqliteService();
  final NotificationService _notificationService = NotificationService();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = const Uuid();

  final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  void notifyDataChanged() => refreshNotifier.value++;
  bool get isLoggedIn => _supabaseService.currentUserId != null;

  Future<void> _onDataMutated() async {
    await _notificationService.rescheduleAll();
    notifyDataChanged();
  }

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
              'tgl_mulai': item['tgl_mulai'] ?? AppFormatters.toIsoDate(DateTime.now()),
              'tgl_selesai': item['tgl_selesai'] ?? AppFormatters.toIsoDate(DateTime.now()),
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
      return rawData.map(AppFormatters.formatTripItem).toList();
    } catch (e) {
      throw Exception('Gagal memuat data perjalanan: $e');
    }
  }

  Future<Map<String, dynamic>> getHomeOverview() async {
    final trips = await getTrips();
    if (trips.isEmpty) {
      return {'total_trips': 0, 'total_biaya': 'Rp 0', 'latest_trips': [], 'upcoming': null};
    }

    int totalBiaya = 0;
    try {
      final activities = isLoggedIn
          ? await _supabaseService.getAllActivities()
          : await _sqliteService.getAllActiveActivitiesLocal();
      for (final act in activities) {
        totalBiaya += (act['biaya'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {
      for (final act in await _sqliteService.getAllActiveActivitiesLocal()) {
        totalBiaya += (act['biaya'] as num?)?.toInt() ?? 0;
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Map<String, dynamic>? upcomingTrip;
    Duration? minDiff;

    for (final trip in trips) {
      final diff = (trip['tgl_mulai_dt'] as DateTime).difference(today);
      if (diff.inDays >= 0 && (minDiff == null || diff < minDiff)) {
        minDiff = diff;
        upcomingTrip = trip;
      }
    }

    return {
      'total_trips': trips.length,
      'total_biaya': AppFormatters.formatRupiah(totalBiaya),
      'latest_trips': trips.take(3).toList(),
      'upcoming': upcomingTrip ?? trips.first,
    };
  }

  Future<String> createTrip({
    required String judul,
    required DateTime tglMulai,
    required DateTime tglSelesai,
  }) async {
    final newId = _uuid.v4();
    final days = (tglSelesai.difference(tglMulai).inDays + 1).clamp(1, 365);
    final payload = {
      'id': newId,
      'judul': judul.trim(),
      'tgl_mulai': AppFormatters.toIsoDate(tglMulai),
      'tgl_selesai': AppFormatters.toIsoDate(tglSelesai),
      'durasi': '$days Hari',
      'created_at': DateTime.now().toIso8601String(),
    };

    await _sqliteService.upsertTripLocal({...payload, 'is_synced': 0, 'is_deleted': 0});
    if (isLoggedIn) {
      try {
        await _supabaseService.upsertTrip(payload);
        await _sqliteService.updateTripLocal(newId, {'is_synced': 1});
      } catch (_) {}
    }
    await _onDataMutated();
    return newId;
  }

  Future<void> updateTrip({
    required String id,
    required String judul,
    required DateTime tglMulai,
    required DateTime tglSelesai,
  }) async {
    final days = (tglSelesai.difference(tglMulai).inDays + 1).clamp(1, 365);
    final updated = {
      'judul': judul.trim(),
      'tgl_mulai': AppFormatters.toIsoDate(tglMulai),
      'tgl_selesai': AppFormatters.toIsoDate(tglSelesai),
      'durasi': '$days Hari',
    };

    await _sqliteService.updateTripLocal(id, {...updated, 'is_synced': 0});
    if (isLoggedIn) {
      try {
        await _supabaseService.updateTrip(id, updated);
        await _sqliteService.updateTripLocal(id, {'is_synced': 1});
      } catch (_) {}
    }
    await _onDataMutated();
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
    await _onDataMutated();
  }

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

    if (rawTrip == null) throw Exception('Data perjalanan tidak ditemukan.');

    final startDt = AppFormatters.parseDateSafe(rawTrip['tgl_mulai'] ?? '');
    final endDt = AppFormatters.parseDateSafe(rawTrip['tgl_selesai'] ?? '');
    final totalDays = (endDt.difference(startDt).inDays + 1).clamp(1, 365);

    int totalBiaya = 0;
    for (final act in rawActivities) {
      totalBiaya += (act['biaya'] as num?)?.toInt() ?? 0;
    }

    final hariList = List.generate(totalDays, (idx) {
      final dayNum = idx + 1;
      final dayDt = startDt.add(Duration(days: idx));
      final dayActivities = rawActivities
          .where((a) => ((a['hari_ke'] as num?)?.toInt() ?? 1) == dayNum)
          .map((a) {
        final biayaInt = (a['biaya'] as num?)?.toInt() ?? 0;
        final jamMulai = a['jam_mulai']?.toString() ?? '08:00';
        final jamSelesai = a['jam_selesai']?.toString() ?? '10:00';
        return {
          'id': a['id'].toString(),
          'hari_ke': dayNum,
          'jam': '$jamMulai - $jamSelesai',
          'jam_mulai': jamMulai,
          'jam_selesai': jamSelesai,
          'tempat': a['tempat'] ?? '',
          'kategori': a['kategori'] ?? 'Kota',
          'biaya': AppFormatters.formatRupiah(biayaInt),
          'biaya_raw': biayaInt,
          'catatan': a['catatan'] ?? '',
        };
      }).toList();

      return {
        'hari_ke': dayNum,
        'tgl_spesifik': AppFormatters.formatDisplayDate(AppFormatters.toIsoDate(dayDt)),
        'aktivitas': dayActivities,
      };
    });

    return {
      'id': rawTrip['id'].toString(),
      'judul': rawTrip['judul'] ?? 'Tanpa Judul',
      'tgl_mulai': AppFormatters.formatDisplayDate(rawTrip['tgl_mulai'] ?? ''),
      'tgl_selesai': AppFormatters.formatDisplayDate(rawTrip['tgl_selesai'] ?? ''),
      'tgl_mulai_dt': startDt,
      'tgl_selesai_dt': endDt,
      'total_hari': totalDays,
      'total_biaya': AppFormatters.formatRupiah(totalBiaya),
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
      'created_at': DateTime.now().toIso8601String(),
    };

    await _sqliteService.upsertActivityLocal({...payload, 'is_synced': 0, 'is_deleted': 0});
    if (isLoggedIn) {
      try {
        await _supabaseService.upsertActivity(payload);
        await _sqliteService.updateActivityLocal(newId, {'is_synced': 1});
      } catch (_) {}
    }
    await _onDataMutated();
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

    await _sqliteService.updateActivityLocal(id, {...updated, 'is_synced': 0});
    if (isLoggedIn) {
      try {
        await _supabaseService.updateActivity(id, updated);
        await _sqliteService.updateActivityLocal(id, {'is_synced': 1});
      } catch (_) {}
    }
    await _onDataMutated();
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
    await _onDataMutated();
  }

  Future<void> syncAllData() async {
    await _syncService.syncAll();
    await _onDataMutated();
  }
}
