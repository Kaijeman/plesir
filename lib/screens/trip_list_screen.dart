import 'package:flutter/material.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  // Simulasi asinkron mengambil data dari database (misal: SQLite/API)
  Future<List<Map<String, String>>> _fetchTrips() async {
    // Simulasi loading selama 1.5 detik
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    // Data tiruan berdasarkan ERD tabel 'perjalanan'
    return [
      {'judul': 'Liburan ke Bali', 'tgl_mulai': '25 Okt 2026', 'tgl_selesai': '30 Okt 2026'},
      {'judul': 'Pendakian Semeru', 'tgl_mulai': '12 Nov 2026', 'tgl_selesai': '15 Nov 2026'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rencana Perjalanan Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // FutureBuilder untuk menangani state asinkron (loading, error, success)
      body: FutureBuilder<List<Map<String, String>>>(
        future: _fetchTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada rencana perjalanan.'));
          }

          final trips = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.flight_takeoff, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(trip['judul']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('${trip['tgl_mulai']} - ${trip['tgl_selesai']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // Nantinya ini akan memanggil fungsi asinkron untuk menghapus data di DB
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${trip['judul']} dihapus')),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/trip-detail');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Menunggu kembalian dari halaman Form (menggunakan await)
          final result = await Navigator.pushNamed(context, '/trip-form');

          // Jika proses simpan di form berhasil dan mengirim flag 'true'
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rencana perjalanan berhasil disimpan!')),
            );
            // Nantinya di sini kita panggil fungsi untuk me-refresh data dari database
            setState(() {});
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Rencana'),
      ),
    );
  }
}
