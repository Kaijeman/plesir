import '../services/supabase_service.dart';

class TripController {
  final SupabaseService _service = SupabaseService();

  Future<List<Map<String, dynamic>>> getTrips() async {
    try {
      final rawData = await _service.getTrips();
      return rawData.map((item) => _formatTripItem(item)).toList();
    } catch (e) {
      throw Exception('Gagal memuat data perjalanan: $e');
    }
  }

  Future<Map<String, dynamic>> getHomeOverview() async {
    try {
      final trips = await getTrips();
      if (trips.isEmpty) {
        return {'total_trips': 0, 'latest_trips': [], 'upcoming': null};
      }

      final recentTrips = trips.take(3).toList();

      final upcomingTrip = trips.length > 1 ? trips[1] : trips.first;

      return {
        'total_trips': trips.length,
        'latest_trips': recentTrips,
        'upcoming': upcomingTrip,
      };
    } catch (e) {
      throw Exception('Gagal memuat ringkasan beranda: $e');
    }
  }

  Map<String, dynamic> _formatTripItem(Map<String, dynamic> item) {
    return {
      'id': item['id']?.toString() ?? '',
      'judul': item['judul'] ?? 'Tanpa Judul',
      'tgl_mulai': item['tgl_mulai'] ?? '-',
      'tgl_selesai': item['tgl_selesai'] ?? '-',
      'durasi': item['durasi'] ?? '-',
    };
  }
}
