import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transformation.dart';

class TransformationRepository {
  static Database? _database;
  static const String _tableName = 'transformations';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recode.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        theme TEXT NOT NULL,
        intensityBefore INTEGER NOT NULL,
        intensityAfter INTEGER NOT NULL,
        userNote TEXT,
        submodalitiesBeforeDistance REAL NOT NULL,
        submodalitiesBeforeBrightness REAL NOT NULL,
        submodalitiesBeforeSize REAL NOT NULL,
        submodalitiesBeforeColorValue INTEGER NOT NULL,
        submodalitiesBeforeClarity REAL NOT NULL,
        submodalitiesBeforeSoundLevel TEXT NOT NULL,
        submodalitiesAfterDistance REAL NOT NULL,
        submodalitiesAfterBrightness REAL NOT NULL,
        submodalitiesAfterSize REAL NOT NULL,
        submodalitiesAfterColorValue INTEGER NOT NULL,
        submodalitiesAfterClarity REAL NOT NULL,
        submodalitiesAfterSoundLevel TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransformation(Transformation transformation) async {
    final db = await database;
    return await db.insert(_tableName, transformation.toMap());
  }

  Future<List<Transformation>> getAllTransformations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transformation.fromMap(maps[i]));
  }

  Future<List<Transformation>> getTransformationsByTheme(String theme) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'theme = ?',
      whereArgs: [theme],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transformation.fromMap(maps[i]));
  }

  Future<int> updateTransformation(Transformation transformation) async {
    final db = await database;
    return await db.update(
      _tableName,
      transformation.toMap(),
      where: 'id = ?',
      whereArgs: [transformation.id],
    );
  }

  Future<int> deleteTransformation(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTransformations() async {
    final db = await database;
    await db.delete(_tableName);
  }

  Future<Map<String, int>> getStatistics() async {
    final transformations = await getAllTransformations();

    int totalSessions = transformations.length;
    int totalImprovement = 0;
    Map<String, int> themeCount = {};

    for (var t in transformations) {
      totalImprovement += (t.intensityBefore - t.intensityAfter);
      themeCount[t.theme] = (themeCount[t.theme] ?? 0) + 1;
    }

    return {
      'totalSessions': totalSessions,
      'averageImprovement': totalSessions > 0 ? totalImprovement ~/ totalSessions : 0,
      ...themeCount,
    };
  }
}
