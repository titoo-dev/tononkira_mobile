// filepath: lib/data/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:developer' as dev;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    dev.log('DatabaseHelper initialized');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    dev.log('Database not initialized, initializing now');
    _database = await _initDB('tononkira.db');
    dev.log('Database initialized successfully');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    dev.log('Initializing database: $filePath');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    dev.log('Database path: $path');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    dev.log('Creating database tables (version: $version)');
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL
        -- add more fields as needed
      )
    ''');
    dev.log('Tables created successfully');
  }

  // Example: insert favorite
  Future<int> insertFavorite(Map<String, dynamic> row) async {
    dev.log('Inserting favorite: ${row.toString()}');
    final db = await instance.database;
    final id = await db.insert('favorites', row);
    dev.log('Favorite inserted with id: $id');
    return id;
  }

  // Example: get all favorites
  Future<List<Map<String, dynamic>>> getFavorites() async {
    dev.log('Fetching all favorites');
    final db = await instance.database;
    final results = await db.query('favorites');
    dev.log('Fetched ${results.length} favorites');
    return results;
  }
}
