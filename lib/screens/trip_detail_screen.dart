import 'package:flutter/material.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Future<Map<String, dynamic>> _tripDetailsFuture = _fetchTripDetails();

  void _refreshData() {
    setState(() {
      _tripDetailsFuture = _fetchTripDetails();
    });
  }

  Future<Map<String, dynamic>> _fetchTripDetails() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'judul': 'Liburan ke Bali',
      'tgl_mulai': '25 Okt 2026',
      'tgl_selesai': '26 Okt 2026',
      'total_biaya': 'Rp 325.000',
      'hari': [
        {
          'hari_ke': 1,
          'tgl_spesifik': '25 Okt 2026',
          'aktivitas': [
            {
              'jam': '08:00 - 10:00',
              'tempat': 'Bandara Ngurah Rai',
              'kategori': 'Transportasi',
              'biaya': 'Rp 150.000',
              'catatan': 'Sewa mobil di area kedatangan'
            },
            {
              'jam': '11:00 - 14:00',
              'tempat': 'Pantai Kuta',
              'kategori': 'Pantai',
              'biaya': 'Rp 50.000',
              'catatan': 'Makan siang & santai di pantai'
            },
          ]
        },
        {
          'hari_ke': 2,
          'tgl_spesifik': '26 Okt 2026',
          'aktivitas': [
            {
              'jam': '09:00 - 12:00',
              'tempat': 'Garuda Wisnu Kencana',
              'kategori': 'Kota',
              'biaya': 'Rp 125.000',
              'catatan': 'Beli tiket online terlebih dahulu'
            },
          ]
        },
      ]
    };
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.map_rounded, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 14),
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
                                      'judul': tripData['judul'],
                                      'tgl_mulai': DateTime(2026, 10, 25),
                                      'tgl_selesai': DateTime(2026, 10, 26),
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
                          const SizedBox(height: 4),
                          Text(
                            '${tripData['tgl_mulai']} - ${tripData['tgl_selesai']} (${hariList.length} Hari)',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Est.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          tripData['total_biaya'],
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Jadwal Aktivitas Harian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (activeHariList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(Icons.event_note_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada aktivitas yang dijadwalkan.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeHariList.length,
                  itemBuilder: (context, index) {
                    final hari = activeHariList[index];
                    final List aktivitasList = hari['aktivitas'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.06),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.today_rounded, size: 18, color: primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Hari ${hari['hari_ke']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text(
                                      ' • ${hari['tgl_spesifik']}',
                                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${aktivitasList.length} Aktivitas',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),

                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: aktivitasList.length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (context, aktIndex) {
                              final akt = aktivitasList[aktIndex];
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.access_time_rounded, size: 15, color: primaryColor),
                                            const SizedBox(width: 6),
                                            Text(
                                              akt['jam'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            akt['kategori'],
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      akt['tempat'],
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Biaya: ${akt['biaya']}',
                                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                                              onPressed: () async {
                                                final result = await Navigator.pushNamed(
                                                  context,
                                                  '/activity-form',
                                                  arguments: {
                                                    'isEdit': true,
                                                    'tempat': akt['tempat'],
                                                    'kategori': akt['kategori'],
                                                    'biaya': akt['biaya'],
                                                    'catatan': akt['catatan'],
                                                    'startTime': const TimeOfDay(hour: 8, minute: 0),
                                                    'endTime': const TimeOfDay(hour: 10, minute: 0),
                                                  },
                                                );
                                                if (result == true && context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Aktivitas ${akt['tempat']} berhasil diperbarui!')),
                                                  );
                                                  _refreshData();
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('${akt['tempat']} dihapus')),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (akt['catatan'] != null && akt['catatan'].isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Catatan: ${akt['catatan']}',
                                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
          final result = await Navigator.pushNamed(context, '/activity-form');
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
