import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/login_screen.dart';
import '../screens/trip_list_screen.dart';
import '../screens/trip_detail_screen.dart';
import '../screens/trip_form_screen.dart';
import '../screens/activity_form_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String tripList = '/trip-list';
  static const String tripDetail = '/trip-detail';
  static const String tripForm = '/trip-form';
  static const String activityForm = '/activity-form';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const MainScreen(),
    login: (context) => const LoginScreen(),
    tripList: (context) => const TripListScreen(),
    tripDetail: (context) => const TripDetailScreen(),
    tripForm: (context) => const TripFormScreen(),
    activityForm: (context) => const ActivityFormScreen(),
  };
}
