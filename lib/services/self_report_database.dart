import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'self_report_store.dart';

class SelfReportDatabase {
  SelfReportDatabase._();

  static final SelfReportDatabase instance = SelfReportDatabase._();

  static const String _databaseName = 'healthph_self_reports_v2.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'self_reports';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );

    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        region TEXT NOT NULL,
        province TEXT NOT NULL,
        city TEXT NOT NULL,
        barangay TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        possible_condition TEXT NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        geocoded_address TEXT
      )
    ''');
  }

  Future<int> insertReport(SelfReport report) async {
    final db = await database;

    return db.insert(
      _tableName,
      _reportToMap(report),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SelfReport>> getReports() async {
    final db = await database;

    final rows = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );

    return rows.map(_mapToReport).toList();
  }

  Future<int> deleteReportByCreatedAt(DateTime createdAt) async {
    final db = await database;

    return db.delete(
      _tableName,
      where: 'created_at = ?',
      whereArgs: [createdAt.toIso8601String()],
    );
  }

  Future<int> clearReports() async {
    final db = await database;
    return db.delete(_tableName);
  }

  Future<void> close() async {
    final db = _database;
    if (db == null) return;

    await db.close();
    _database = null;
  }

  Map<String, dynamic> _reportToMap(SelfReport report) {
    return {
      'region': report.region,
      'province': report.province,
      'city': report.city,
      'barangay': report.barangay,
      'symptoms': jsonEncode(report.symptoms),
      'possible_condition': report.possibleCondition,
      'notes': report.notes,
      'created_at': report.createdAt.toIso8601String(),
      'latitude': report.latitude,
      'longitude': report.longitude,
      'geocoded_address': report.geocodedAddress,
    };
  }

  SelfReport _mapToReport(Map<String, dynamic> map) {
    return SelfReport(
      region: map['region'] as String,
      province: map['province'] as String,
      city: map['city'] as String,
      barangay: map['barangay'] as String,
      symptoms: List<String>.from(jsonDecode(map['symptoms'] as String)),
      possibleCondition: map['possible_condition'] as String,
      notes: map['notes'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      geocodedAddress: map['geocoded_address'] as String?,
    );
  }
}