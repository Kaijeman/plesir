import '../utils/formatters.dart';
import 'sqlite_service.dart';
import 'supabase_service.dart';

class SyncService {
  final SupabaseService _supabaseService = SupabaseService();
  final SqliteService _sqliteService = SqliteService();

  Future<void> syncAll() async {
    if (_supabaseService.currentUserId == null) return;
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

    final cloudTrips = await _supabaseService.getTrips();
    for (final item in cloudTrips) {
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
  }
}
