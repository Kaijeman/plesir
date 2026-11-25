import 'package:flutter/material.dart';
import '../controllers/trip_controller.dart';
import '../widgets/day_schedule_card.dart';
import '../widgets/empty_state_widget.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final TripController _controller = TripController();
  String? _tripId;
  bool _isInit = true;
  late Future<Map<String, dynamic>> _tripDetailsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _tripId = args;
      } else if (args is Map<String, dynamic>) {
        _tripId = args['id']?.toString();
      }
      _tripDetailsFuture = _fetchTripDetails();
      _isInit = false;
    }
  }

  void _refreshData() {
    setState(() {
      _tripDetailsFuture = _fetchTripDetails();
    });
  }

  Future<Map<String, dynamic>> _fetchTripDetails() {
    if (_tripId == null || _tripId!.isEmpty) {
      return Future.error('ID perjalanan tidak valid.');
    }
    return _controller.getTripDetails(_tripId!);
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 8;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return TimeOfDay(hour: h, minute: m);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Detail Perjalanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
      future: _tripDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Data tidak ditemukan.'));
        }

        final tripData = snapshot.data!;
        final List hariList = tripData['hari'];

        final activeHariList = hariList.where((hari) {
          final List aktivitas = hari['aktivitas'];
          return aktivitas.isNotEmpty;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.map_rounded, color: primaryColor, size: 28),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tripData['judul'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/trip-form',
                                  arguments: {
                                    'isEdit': true,
                                    'id': tripData['id'],
                                    'judul': tripData['judul'],
                                    'tgl_mulai': tripData['tgl_mulai_dt'],
                                    'tgl_selesai': tripData['tgl_selesai_dt'],
                                  },
                                );
                                if (result == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Rencana perjalanan berhasil diperbarui!')),
                                  );
                                  _refreshData();
                                }
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${tripData['tgl_mulai']} - ${tripData['tgl_selesai']} (${hariList.length} Hari)',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Est.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          tripData['total_biaya'],
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 12),
              child: Text(
                'Jadwal Aktivitas Harian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            if (activeHariList.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  child: EmptyStateWidget(
                    icon: Icons.event_note_outlined,
                    iconSize: 48,
                    iconColor: Colors.grey,
                    title: 'Belum ada aktivitas yang dijadwalkan.',
                    titleStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeHariList.length,
                itemBuilder: (context, index) {
                  final hari = activeHariList[index] as Map<String, dynamic>;
                  return DayScheduleCard(
                    hari: hari,
                    primaryColor: primaryColor,
                    onEditActivity: (akt) async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/activity-form',
                        arguments: {
                          'isEdit': true,
                          'id': akt['id'],
                          'trip_id': tripData['id'],
                          'total_hari': tripData['total_hari'],
                          'hari_ke': hari['hari_ke'],
                          'tempat': akt['tempat'],
                          'kategori': akt['kategori'],
                          'biaya': akt['biaya_raw'].toString(),
                          'catatan': akt['catatan'],
                          'startTime': _parseTime(akt['jam_mulai']),
                          'endTime': _parseTime(akt['jam_selesai']),
                        },
                      );
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Aktivitas ${akt['tempat']} berhasil diperbarui!')),
                        );
                        _refreshData();
                      }
                    },
                    onDeleteActivity: (akt) async {
                      await _controller.deleteActivity(akt['id']);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${akt['tempat']} dihapus')),
                        );
                        _refreshData();
                      }
                    },
                  );
                },
              ),
          ],
        );
      },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () async {
          if (_tripId == null) return;
          final tripInfo = await _tripDetailsFuture;
          if (!context.mounted) return;
          final result = await Navigator.pushNamed(
            context,
            '/activity-form',
            arguments: {
              'isEdit': false,
              'trip_id': _tripId,
              'total_hari': tripInfo['total_hari'] ?? 1,
            },
          );
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aktivitas berhasil ditambahkan!')),
            );
            _refreshData();
          }
        },
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Tambah Aktivitas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
