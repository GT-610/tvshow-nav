import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/link.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;
  static bool _initialized = false;

  DbHelper._init();

  Future<void> _initDatabaseFactory() async {
    if (_initialized) return;
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  String getDbPath() {
    final exePath = Platform.resolvedExecutable;
    return join(dirname(exePath), 'data.db');
  }

  Future<bool> dbExists() async {
    return File(getDbPath()).exists();
  }

  Future<void> initDatabase() async {
    await _initDatabaseFactory();
    final path = getDbPath();
    if (await File(path).exists()) return;
    await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDb,
    );
  }

  Future<Database> get database async {
    await _initDatabaseFactory();
    if (_database != null) return _database!;
    final path = getDbPath();
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDb,
    );
    return _database!;
  }

  Future<void> _onCreateDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        url TEXT NOT NULL
      )
    ''');
  }

  Future<List<TvLink>> getLinks() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('links');
    return List.generate(maps.length, (i) {
      return TvLink.fromMap(maps[i]);
    });
  }

  Future<TvLink> addLink(TvLink link) async {
    final db = await instance.database;
    final id = await db.insert('links', link.toMap());
    return TvLink(
      id: id,
      name: link.name,
      url: link.url,
    );
  }

  Future<int> updateLink(TvLink link) async {
    final db = await instance.database;
    return db.update(
      'links',
      link.toMap(),
      where: 'id = ?',
      whereArgs: [link.id],
    );
  }

  Future<int> deleteLink(int id) async {
    final db = await instance.database;
    return db.delete(
      'links',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
