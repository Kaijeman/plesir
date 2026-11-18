import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/sqlite_service.dart';
import 'trip_controller.dart';

class AuthController {
  final AuthService _authService = AuthService();
  final TripController _tripController = TripController();
  final SqliteService _sqliteService = SqliteService();

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => currentUser != null;

  String get userName {
    final meta = currentUser?.userMetadata;
    return meta?['full_name'] ?? meta?['name'] ?? 'Pengelana Plesir';
  }

  String get userEmail => currentUser?.email ?? 'user@gmail.com';

  String? get userAvatarUrl => currentUser?.userMetadata?['avatar_url'];

  Future<void> loginWithGoogle() async {
    final response = await _authService.signInWithGoogle();
    if (response.user != null) {
      await _tripController.syncAllData();
    }
  }

  Future<void> syncNow() async {
    await _tripController.syncAllData();
  }

  Future<void> logout() async {
    await _authService.signOut();
    await _sqliteService.clearAllLocalData();
    _tripController.notifyDataChanged();
  }
}
