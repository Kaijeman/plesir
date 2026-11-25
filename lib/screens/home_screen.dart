import 'package:flutter/material.dart';
import '../controllers/trip_controller.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TripController _controller = TripController();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: _controller.refreshNotifier,
          builder: (context, _, _) {
            return FutureBuilder<Map<String, dynamic>>(
            future: _controller.getHomeOverview(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              } else if (snapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
              }

              final overview = snapshot.data ?? {
                'total_trips': 0,
                'total_biaya': 'Rp 0',
                'latest_trips': [],
                'upcoming': null,
              };
              final upcomingTrip = overview['upcoming'] as Map<String, dynamic>?;
              final recentTrips = (overview['latest_trips'] as List<dynamic>?) ?? [];
              final totalTrips = overview['total_trips'] ?? 0;
              final totalBiaya = overview['total_biaya'] ?? 'Rp 0';

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        'Halo, Pengelana!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, const Color(0xFF33432D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Rencana Terdekat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Text(
                              upcomingTrip != null ? upcomingTrip['judul'] : 'Belum Ada Rencana',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, color: Colors.white70, size: 16),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    upcomingTrip != null
                                        ? '${upcomingTrip['tgl_mulai']} - ${upcomingTrip['tgl_selesai']} (${upcomingTrip['durasi']})'
                                        : 'Buat rencana perjalanan pertamamu',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                if (upcomingTrip != null) {
                                  Navigator.pushNamed(
                                    context,
                                    '/trip-detail',
                                    arguments: upcomingTrip['id'],
                                  );
                                } else {
                                  Navigator.pushNamed(context, '/trip-form');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              child: Text(
                                upcomingTrip != null ? 'Lihat Detail Perjalanan' : '+ Buat Rencana',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(top: 28, bottom: 12),
                      child: Text(
                        'Ringkasan Perjalanan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.map_rounded,
                              title: 'Total Trip',
                              value: '$totalTrips Rencana',
                              primaryColor: primaryColor,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: _buildStatCard(
                                icon: Icons.account_balance_wallet_rounded,
                                title: 'Est. Total Biaya',
                                value: totalBiaya,
                                primaryColor: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rencana Terbaru',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, size: 28),
                            color: primaryColor,
                            onPressed: () {
                              Navigator.pushNamed(context, '/trip-form');
                            },
                          ),
                        ],
                      ),
                    ),

                    if (recentTrips.isNotEmpty)
                      ...recentTrips.map((trip) {
                        return TripCard(
                          title: trip['judul'] ?? 'Tanpa Judul',
                          dateRange: '${trip['tgl_mulai']} - ${trip['tgl_selesai']}',
                          duration: trip['durasi'] ?? '-',
                          primaryColor: primaryColor,
                          bottomMargin: 12,
                          iconRightMargin: 16,
                          shadowAlpha: 0.03,
                          shadowBlur: 8,
                          shadowOffset: const Offset(0, 3),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () {
                            Navigator.pushNamed(context, '/trip-detail', arguments: trip['id'] ?? '');
                          },
                        );
                      })
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Belum ada rencana perjalanan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
