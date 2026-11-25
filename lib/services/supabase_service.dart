import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getTrips() async {
    final response = await _client
        .from('trips')
        .select('id, judul, tgl_mulai, tgl_selesai, durasi, created_at')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getTripById(String id) async {
    return await _client
        .from('trips')
        .select('id, judul, tgl_mulai, tgl_selesai, durasi, created_at')
        .eq('id', id)
        .maybeSingle();
  }

  Future<void> upsertTrip(Map<String, dynamic> tripData) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client.from('trips').upsert({
      'id': tripData['id'],
      'user_id': userId,
      'judul': tripData['judul'],
      'tgl_mulai': tripData['tgl_mulai'],
      'tgl_selesai': tripData['tgl_selesai'],
      'durasi': tripData['durasi'],
      'created_at': tripData['created_at'],
    });
  }

  Future<void> updateTrip(String id, Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    await _client.from('trips').update(data).eq('id', id);
  }

  Future<void> deleteTrip(String id) async {
    if (currentUserId == null) return;
    await _client.from('trips').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getActivitiesByTrip(String tripId) async {
    final response = await _client
        .from('activities')
        .select('id, trip_id, hari_ke, jam_mulai, jam_selesai, tempat, kategori, biaya, catatan, created_at')
        .eq('trip_id', tripId)
        .order('hari_ke', ascending: true)
        .order('jam_mulai', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllActivities() async {
    final response = await _client
        .from('activities')
        .select('id, trip_id, hari_ke, jam_mulai, jam_selesai, tempat, kategori, biaya, catatan, created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> upsertActivity(Map<String, dynamic> activityData) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client.from('activities').upsert({
      'id': activityData['id'],
      'trip_id': activityData['trip_id'],
      'user_id': userId,
      'hari_ke': activityData['hari_ke'],
      'jam_mulai': activityData['jam_mulai'],
      'jam_selesai': activityData['jam_selesai'],
      'tempat': activityData['tempat'],
      'kategori': activityData['kategori'],
      'biaya': activityData['biaya'],
      'catatan': activityData['catatan'],
      'created_at': activityData['created_at'],
    });
  }

  Future<void> updateActivity(String id, Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    await _client.from('activities').update(data).eq('id', id);
  }

  Future<void> deleteActivity(String id) async {
    if (currentUserId == null) return;
    await _client.from('activities').delete().eq('id', id);
  }
}
