import 'package:flutter/material.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  // Simulasi asinkron mengambil data hari_perjalanan dan detail_aktivitas
  Future<Map<String, dynamic>> _fetchTripDetails() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'judul': 'Liburan ke Bali',
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
              'catatan': 'Sewa mobil di kedatangan'
            },
            {
              'jam': '11:00 - 14:00',
              'tempat': 'Pantai Kuta',
              'kategori': 'Pantai',
              'biaya': 'Rp 50.000',
              'catatan': 'Makan siang di sekitar pantai'
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
              'catatan': 'Beli tiket online'
            },
          ]
        }
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Itinerary', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchTripDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final tripData = snapshot.data!;
          final List hariList = tripData['hari'];

          return DefaultTabController(
            length: hariList.length,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    isScrollable: true,
                    labelColor: Theme.of(context).colorScheme.primary,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: hariList.map<Widget>((hari) {
                      return Tab(
                        text: 'Hari ${hari['hari_ke']}\n(${hari['tgl_spesifik']})',
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: hariList.map<Widget>((hari) {
                      final List aktivitasList = hari['aktivitas'];
                      if (aktivitasList.isEmpty) {
                        return const Center(child: Text('Belum ada aktivitas di hari ini.'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: aktivitasList.length,
                        itemBuilder: (context, index) {
                          final akt = aktivitasList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        akt['jam'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          akt['kategori'],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    akt['tempat'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Estimasi Biaya: ${akt['biaya']}'),
                                  if (akt['catatan'] != null && akt['catatan'].isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Catatan: ${akt['catatan']}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/activity-form');
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aktivitas berhasil ditambahkan!')),
            );
            setState(() {});
          }
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Tambah Aktivitas'),
      ),
    );
  }
}
