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

    // Create Lyric table with SQLite compatible syntax
    await db.execute('''
      CREATE TABLE IF NOT EXISTS "Lyric" (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        "contentText" TEXT,
        url TEXT NOT NULL,
        language TEXT NOT NULL DEFAULT 'mg',
        "createdBy" TEXT NOT NULL,
        "isSynced" INTEGER NOT NULL DEFAULT 0,
        "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TEXT NOT NULL
      )
    ''');

    // Create Artist table with SQLite compatible syntax
    await db.execute('''
      CREATE TABLE IF NOT EXISTS "Artist" (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bio TEXT,
        url TEXT,
        slug TEXT NOT NULL,
        "imageUrl" TEXT,
        "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TEXT NOT NULL
      )
    ''');

    // Create index on Artist name
    await db.execute('''
      CREATE INDEX IF NOT EXISTS "Artist_name_idx" ON "Artist" (name)
    ''');

    // Create Song table with foreign keys
    await db.execute('''
      CREATE TABLE IF NOT EXISTS "Song" (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        duration INTEGER,
        slug TEXT NOT NULL,
        "trackNumber" INTEGER,
        views INTEGER DEFAULT 0,
        "lyricId" INTEGER UNIQUE,
        "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TEXT NOT NULL,
        FOREIGN KEY ("lyricId") REFERENCES "Lyric"(id) ON UPDATE CASCADE ON DELETE SET NULL
      )
    ''');

    // Create the favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL
        -- add more fields as needed
      )
    ''');

    // Create the junction table for Artist to Song many-to-many relationship
    await db.execute('''
      CREATE TABLE IF NOT EXISTS "_ArtistToSong" (
        "A" INTEGER NOT NULL REFERENCES "Artist"(id) ON UPDATE CASCADE ON DELETE CASCADE,
        "B" INTEGER NOT NULL REFERENCES "Song"(id) ON UPDATE CASCADE ON DELETE CASCADE,
        PRIMARY KEY ("A", "B")
      )
    ''');

    // Create index on B column of the junction table
    await db.execute('''
      CREATE INDEX IF NOT EXISTS "_ArtistToSong_B_index" ON "_ArtistToSong" ("B")
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
