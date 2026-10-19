import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToTripList() async {
    await Navigator.pushNamed(context, '/trip-list');
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mencari rencana perjalanan: "$query"')),
      );
      _navigateToTripList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Halo, Pengelana! 👋',
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mau plesir ke mana\nhari ini?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 32),

                // Search Bar Interaktif
                Container(
                  width: screenWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search, // Mengubah tombol Enter di keyboard HP jadi tombol Search
                    onChanged: (value) => setState(() => _searchQuery = value),
                    onSubmitted: (value) => _handleSearch(value), // Berpindah saat menekan Search di keyboard
                    decoration: InputDecoration(
                      hintText: 'Cari destinasi wisata...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      icon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.grey),
                        onPressed: () => _handleSearch(_searchController.text),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                const Text('Kategori Populer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Jejeran Kategori Interaktif
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryItem(Icons.landscape, 'Gunung', context),
                    _buildCategoryItem(Icons.beach_access, 'Pantai', context),
                    _buildCategoryItem(Icons.location_city, 'Kota', context),
                    _buildCategoryItem(Icons.forest, 'Hutan', context),
                  ],
                ),
                const SizedBox(height: 40),

                // Tombol Akses Utama
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _navigateToTripList,
                    child: const Text('Lihat Semua Rencana Perjalanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Komponen Kategori yang dibungkus InkWell agar bisa diklik
  Widget _buildCategoryItem(IconData icon, String title, BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menampilkan kategori: $title')),
        );
        _navigateToTripList();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
