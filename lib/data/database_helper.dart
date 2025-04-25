// filepath: lib/data/database_helper.dart
import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'dart:developer' as dev;

import 'package:tononkira_mobile/models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const kDbFileName = 'tononkira.db';
  static const kDbSongTableName = 'Song';
  static const kDbLyricTableName = 'Lyric';
  static const kDbArtistTableName = 'Artist';
  static const kDbArtistToSongTableName = '_ArtistToSong';
  static final AsyncMemoizer _memoizer = AsyncMemoizer();

  // Progress tracking variables
  double _importProgress = 0.0;
  String _importStatus = "Not started";
  bool _isImporting = false;

  // Getters for progress tracking
  double get importProgress => _importProgress;
  String get importStatus => _importStatus;
  bool get isImporting => _isImporting;

  // Stream controller for real-time progress updates
  final _progressController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get progressStream => _progressController.stream;

  DatabaseHelper._init() {
    dev.log('DatabaseHelper initialized');
  }

  void dispose() {
    _progressController.close();
  }

  void _updateProgress(double progress, String status) {
    _importProgress = progress;
    _importStatus = status;
    _progressController.add({
      'progress': _importProgress,
      'status': _importStatus,
      'isImporting': _isImporting,
    });
    dev.log(
      'Import progress: ${(progress * 100).toStringAsFixed(1)}% - $status',
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    dev.log('Database not initialized, initializing now');

    await _memoizer.runOnce(() async {
      _database = await _initDB(kDbFileName);
    });
    dev.log('Database initialized successfully');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    dev.log('Initializing database: $filePath');
    final dbFolder = await getDatabasesPath();

    if (!await Directory(dbFolder).exists()) {
      dev.log('Creating database folder: $dbFolder');
      await Directory(dbFolder).create(recursive: true);
    }

    final dbPath = join(dbFolder, filePath);
    dev.log('Database path: $dbPath');

    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    dev.log('Creating database tables (version: $version)');

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

    // Create index on Artist name
    await db.execute('''
      CREATE INDEX IF NOT EXISTS "Artist_name_idx" ON "Artist" (name)
    ''');

    // Create Song table with foreign keys
    await db.execute('''
      CREATE TABLE IF NOT EXISTS "Song" (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        slug TEXT NOT NULL,
        "trackNumber" INTEGER,
        views INTEGER DEFAULT 0,
        "lyricId" INTEGER,
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

  // Import data from SQL script files in assets folder with progress tracking
  Future<void> importDataFromSQL(String assetsPath) async {
    dev.log('Starting data import from SQL script files');

    if (_isImporting) {
      dev.log('Import already in progress');
      return;
    }

    _isImporting = true;
    _updateProgress(0.0, "Starting import");

    final db = await instance.database;

    // Start a transaction for better performance and atomicity
    try {
      // Import Artist data - 25% of total progress
      _updateProgress(0.0, "Importing artists");
      await _importDataFromSQLScript(db, '$assetsPath/Artist.sql', 0.0, 0.25);
      _updateProgress(0.25, "Artists imported successfully");

      // Import Lyric data - 25% of total progress
      _updateProgress(0.25, "Importing lyrics");
      await _importDataFromSQLScript(db, '$assetsPath/Lyric.sql', 0.25, 0.25);
      _updateProgress(0.5, "Lyrics imported successfully");

      // Import Song data - 25% of total progress
      _updateProgress(0.5, "Importing songs");
      await _importDataFromSQLScript(db, '$assetsPath/Song.sql', 0.5, 0.25);
      _updateProgress(0.75, "Songs imported successfully");

      // Import ArtistToSong relations - 25% of total progress
      _updateProgress(0.75, "Importing artist-song relationships");
      await _importDataFromSQLScript(
        db,
        '$assetsPath/_ArtistToSong.sql',
        0.75,
        0.25,
      );
      _updateProgress(1.0, "Data import completed successfully");

      dev.log('Data import completed successfully');
    } catch (e) {
      _updateProgress(0.0, "Import failed: $e");
      dev.log('Error during data import: $e');
      rethrow; // Re-throw to rollback transaction
    } finally {
      _isImporting = false;
    }
  }

  Future<void> _importDataFromSQLScript(
    Database db,
    String filePath,
    double progressStart,
    double progressSegment,
  ) async {
    dev.log('Importing data from SQL script: $filePath');

    try {
      // Load the SQL script file from assets
      final String sqlScript = await rootBundle.loadString(filePath);

      // Remove comments and trim whitespace
      final cleanedScript = sqlScript.trim();

      try {
        await db.execute(cleanedScript);

        dev.log('Executed SQL script successfully: $filePath');

        // update progress
        _updateProgress(
          progressStart + progressSegment,
          "Executed SQL script: $filePath",
        );
      } catch (e) {
        dev.log('Error executing SQL statement: $e');
      }
    } catch (e) {
      dev.log('Error loading or parsing SQL script: $e');
      rethrow;
    }
  }

  Future<List<Song>> transformSongsData(
    List<Map<String, dynamic>> songsData,
  ) async {
    final result = <Song>[];
    final db = await DatabaseHelper.instance.database;

    for (final songData in songsData) {
      final artistsData = await db.rawQuery(
        '''
        SELECT a.id, a.name, a.slug, a.imageUrl, a.createdAt, a.updatedAt
        FROM Artist a
        JOIN _ArtistToSong ats ON ats.A = a.id
        WHERE ats.B = ?
      ''',
        [songData['id']],
      );

      final artists =
          artistsData
              .map(
                (artistData) => Artist(
                  id: artistData['id'] as int,
                  name: artistData['name'] as String,
                  slug: artistData['slug'] as String,
                  imageUrl: artistData['imageUrl'] as String?,
                  createdAt: DateTime.parse(artistData['createdAt'] as String),
                  updatedAt: DateTime.parse(artistData['updatedAt'] as String),
                ),
              )
              .toList();

      result.add(
        Song(
          id: songData['id'] as int,
          title: songData['title'] as String,
          slug: songData['slug'] as String,
          views: songData['views'] as int? ?? 0,
          createdAt: DateTime.parse(songData['createdAt'] as String),
          updatedAt: DateTime.parse(songData['updatedAt'] as String),
          artists: artists,
        ),
      );
    }

    return result;
  }
}
