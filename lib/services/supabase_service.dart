import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTrips() async {
    final response = await _client
        .from('trips')
        .select('id, judul, tgl_mulai, tgl_selesai, durasi')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getUpcomingTrip() async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final response = await _client
        .from('trips')
        .select('id, judul, tgl_mulai, tgl_selesai, durasi')
        .gte('tgl_mulai', todayStr)
        .order('tgl_mulai', ascending: true)
        .limit(1)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getLatestTrip() async {
    final response = await _client
        .from('trips')
        .select('id, judul, tgl_mulai, tgl_selesai, durasi')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }
}
