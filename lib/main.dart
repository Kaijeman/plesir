import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/trip_list_screen.dart';
import 'screens/trip_form_screen.dart';
import 'screens/trip_detail_screen.dart'; // Import
import 'screens/activity_form_screen.dart'; // Import

void main() {
  runApp(const PlesirApp());
}

class PlesirApp extends StatelessWidget {
  const PlesirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plesir',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B6043)),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/trip-list': (context) => const TripListScreen(),
        '/trip-form': (context) => const TripFormScreen(),
        '/trip-detail': (context) => const TripDetailScreen(), // Rute baru
        '/activity-form': (context) => const ActivityFormScreen(), // Rute baru
      },
    );
  }
}
