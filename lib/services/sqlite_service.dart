import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'plesir_local.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE trips (
            id TEXT PRIMARY KEY,
            judul TEXT NOT NULL,
            tgl_mulai TEXT NOT NULL,
            tgl_selesai TEXT NOT NULL,
            durasi TEXT NOT NULL,
            created_at TEXT NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE activities (
            id TEXT PRIMARY KEY,
            trip_id TEXT NOT NULL,
            hari_ke INTEGER NOT NULL DEFAULT 1,
            jam_mulai TEXT NOT NULL,
            jam_selesai TEXT NOT NULL,
            tempat TEXT NOT NULL,
            kategori TEXT NOT NULL,
            biaya INTEGER NOT NULL DEFAULT 0,
            catatan TEXT,
            created_at TEXT NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<List<Map<String, Object?>>> getTripsLocal() async {
    final db = await database;
    return await db.query(
      'trips',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, Object?>?> getTripByIdLocal(String id) async {
    final db = await database;
    final res = await db.query(
      'trips',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> upsertTripLocal(Map<String, dynamic> trip) async {
    final db = await database;
    await db.insert(
      'trips',
      trip,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTripLocal(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('trips', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> softDeleteTripLocal(String id) async {
    final db = await database;
    await db.update('trips', {'is_deleted': 1, 'is_synced': 0}, where: 'id = ?', whereArgs: [id]);
    await db.update('activities', {'is_deleted': 1, 'is_synced': 0}, where: 'trip_id = ?', whereArgs: [id]);
  }

  Future<void> hardDeleteTripLocal(String id) async {
    final db = await database;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getActivitiesByTripLocal(String tripId) async {
    final db = await database;
    return await db.query(
      'activities',
      where: 'trip_id = ? AND is_deleted = ?',
      whereArgs: [tripId, 0],
      orderBy: 'hari_ke ASC, jam_mulai ASC',
    );
  }

  Future<List<Map<String, Object?>>> getAllActiveActivitiesLocal() async {
    final db = await database;
    return await db.query(
      'activities',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );
  }

  Future<void> upsertActivityLocal(Map<String, dynamic> activity) async {
    final db = await database;
    await db.insert(
      'activities',
      activity,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateActivityLocal(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('activities', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> softDeleteActivityLocal(String id) async {
    final db = await database;
    await db.update('activities', {'is_deleted': 1, 'is_synced': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> hardDeleteActivityLocal(String id) async {
    final db = await database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getUnsyncedTrips() async {
    final db = await database;
    return await db.query('trips', where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<List<Map<String, Object?>>> getUnsyncedActivities() async {
    final db = await database;
    return await db.query('activities', where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<void> clearAllLocalData() async {
    final db = await database;
    await db.delete('activities');
    await db.delete('trips');
  }
}
