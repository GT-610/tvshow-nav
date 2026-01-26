import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/link.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb('tvshow.db');
    return _database!;
  }

  Future<Database> _initDb(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDb,
    );
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
