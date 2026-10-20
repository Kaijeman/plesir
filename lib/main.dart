import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'screens/trip_list_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/trip_form_screen.dart';
import 'screens/activity_form_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const PlesirApp());
  });
}

class PlesirApp extends StatelessWidget {
  const PlesirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plesir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B6043),
          primary: const Color(0xFF4B6043),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/trip-list': (context) => const TripListScreen(),
        '/trip-detail': (context) => const TripDetailScreen(),
        '/trip-form': (context) => const TripFormScreen(),
        '/activity-form': (context) => const ActivityFormScreen(),
      },
    );
  }
}
