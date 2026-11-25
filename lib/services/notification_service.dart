import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/formatters.dart';
import 'sqlite_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final SqliteService _sqliteService = SqliteService();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _isInitialized = true;
  }

  void _configureLocalTimezone() {
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    if (offsetHours == 7) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } else if (offsetHours == 8) {
      tz.setLocalLocation(tz.getLocation('Asia/Makassar'));
    } else if (offsetHours == 9) {
      tz.setLocalLocation(tz.getLocation('Asia/Jayapura'));
    }
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_isInitialized) await init();
    if (!scheduledTime.isAfter(DateTime.now())) return;

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'plesir_itinerary_channel',
      'Pengingat Perjalanan & Aktivitas',
      channelDescription: 'Notifikasi jadwal perjalanan dan aktivitas harian Plesir',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> rescheduleAll() async {
    try {
      await cancelAll();
      final trips = await _sqliteService.getTripsLocal();
      final activities = await _sqliteService.getAllActiveActivitiesLocal();

      int notifId = 1;
      final Map<String, DateTime> tripStartMap = {};

      for (final trip in trips) {
        final tripId = trip['id'].toString();
        final judul = trip['judul']?.toString() ?? 'Perjalanan';
        final startDt = AppFormatters.parseDateSafe(trip['tgl_mulai']?.toString() ?? '');
        tripStartMap[tripId] = startDt;

        final hMinusOne = DateTime(startDt.year, startDt.month, startDt.day - 1, 8, 0);
        await scheduleReminder(
          id: notifId++,
          title: 'Besok Perjalanan Dimulai!',
          body: 'Rencana "$judul" dimulai besok. Pastikan perlengkapanmu sudah siap.',
          scheduledTime: hMinusOne,
        );
      }

      for (final act in activities) {
        final tripId = act['trip_id']?.toString() ?? '';
        final startDt = tripStartMap[tripId];
        if (startDt == null) continue;

        final hariKe = (act['hari_ke'] as num?)?.toInt() ?? 1;
        final jamMulai = act['jam_mulai']?.toString() ?? '08:00';
        final jamSelesai = act['jam_selesai']?.toString() ?? '';
        final tempat = act['tempat']?.toString() ?? 'Aktivitas';

        final timeParts = jamMulai.split(':');
        final hour = int.tryParse(timeParts[0]) ?? 8;
        final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;

        final actDate = startDt.add(Duration(days: (hariKe - 1).clamp(0, 365)));
        final actStartTime = DateTime(actDate.year, actDate.month, actDate.day, hour, minute);
        final reminderTime = actStartTime.subtract(const Duration(minutes: 30));

        await scheduleReminder(
          id: notifId++,
          title: '30 Menit Lagi: $tempat',
          body: 'Jadwal aktivitas pukul $jamMulai${jamSelesai.isNotEmpty ? " - $jamSelesai" : ""}.',
          scheduledTime: reminderTime,
        );
      }
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (!_isInitialized) await init();
    await _plugin.cancelAll();
  }
}
