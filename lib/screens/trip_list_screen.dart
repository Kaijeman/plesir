import 'package:flutter/material.dart';
import '../controllers/trip_controller.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/trip_card.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final TripController _controller = TripController();

  Future<void> _confirmDelete(Map<String, dynamic> trip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Perjalanan?'),
        content: Text('Yakin ingin menghapus "${trip['judul']}" beserta seluruh aktivitasnya?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.deleteTrip(trip['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${trip['judul']} dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Rencana Perjalanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _controller.refreshNotifier,
        builder: (context, _, _) {
          return FutureBuilder<List<Map<String, dynamic>>>(
          future: _controller.getTrips(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryColor));
            } else if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: EmptyStateWidget(
                  icon: Icons.flight_takeoff_outlined,
                  title: 'Belum ada rencana perjalanan',
                  subtitle: 'Tekan tombol + di bawah untuk membuat',
                ),
              );
            }

            final trips = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCard(
                  title: trip['judul'] ?? '',
                  dateRange: '${trip['tgl_mulai']} - ${trip['tgl_selesai']}',
                  duration: trip['durasi'] ?? '',
                  primaryColor: primaryColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/trip-detail', arguments: trip['id']);
                  },
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmDelete(trip),
                    ),
                  ),
                );
              },
            );
          },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () {
          Navigator.pushNamed(context, '/trip-form');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Rencana', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
