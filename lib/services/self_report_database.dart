import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../data/app_taxonomy.dart';
import 'self_report_store.dart';

class SelfReportDatabase {
  SelfReportDatabase._();

  static final SelfReportDatabase instance = SelfReportDatabase._();

  static const String _databaseName = 'healthph_self_reports_v2.db';
  static const int _databaseVersion = 2;
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
      onUpgrade: _upgradeDatabase,
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
        symptom_ids TEXT,
        symptoms TEXT NOT NULL,
        possible_condition_id TEXT,
        possible_condition TEXT NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        geocoded_address TEXT
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN symptom_ids TEXT');
      await db.execute(
        'ALTER TABLE $_tableName ADD COLUMN possible_condition_id TEXT',
      );
    }
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

    final rows = await db.query(_tableName, orderBy: 'created_at DESC');

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
      'symptom_ids': jsonEncode(report.symptomIds),
      'symptoms': jsonEncode(report.symptoms),
      'possible_condition_id': report.possibleConditionId,
      'possible_condition': report.possibleCondition,
      'notes': report.notes,
      'created_at': report.createdAt.toIso8601String(),
      'latitude': report.latitude,
      'longitude': report.longitude,
      'geocoded_address': report.geocodedAddress,
    };
  }

  SelfReport _mapToReport(Map<String, dynamic> map) {
    final symptomLabels = _decodeStringList(map['symptoms']);
    final symptomIds = _decodeStringList(map['symptom_ids']);
    final normalizedSymptomIds = symptomIds.isNotEmpty
        ? symptomIds
        : AppTaxonomy.idsForLabels(AppTaxonomy.symptoms, symptomLabels);
    final normalizedSymptomLabels = symptomLabels.isNotEmpty
        ? symptomLabels
        : AppTaxonomy.labelsFor(AppTaxonomy.symptoms, normalizedSymptomIds);
    final possibleConditionLabel = map['possible_condition'] as String;
    final storedPossibleConditionId = (map['possible_condition_id'] as String?)
        ?.trim();
    final possibleConditionId =
        storedPossibleConditionId != null &&
            storedPossibleConditionId.isNotEmpty
        ? storedPossibleConditionId
        : AppTaxonomy.idForLabel(
            AppTaxonomy.possibleConditions,
            possibleConditionLabel,
          );

    return SelfReport(
      region: map['region'] as String,
      province: map['province'] as String,
      city: map['city'] as String,
      barangay: map['barangay'] as String,
      symptomIds: normalizedSymptomIds,
      symptoms: normalizedSymptomLabels,
      possibleConditionId: possibleConditionId,
      possibleCondition: possibleConditionLabel,
      notes: map['notes'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      geocodedAddress: map['geocoded_address'] as String?,
    );
  }

  List<String> _decodeStringList(Object? value) {
    if (value == null) return [];

    final decoded = jsonDecode(value as String);
    if (decoded is! List) return [];

    return decoded.map((item) => item.toString()).toList();
  }
}
