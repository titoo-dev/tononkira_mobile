// filepath: lib/data/database_helper.dart
import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:developer' as dev;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

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

  // Import data from CSV files in assets folder with progress tracking
  Future<void> importDataFromCSV(String assetsPath) async {
    dev.log('Starting data import from CSV files');

    if (_isImporting) {
      dev.log('Import already in progress');
      return;
    }

    _isImporting = true;
    _updateProgress(0.0, "Starting import");

    final db = await instance.database;

    // Start a transaction for better performance and atomicity
    await db.transaction((txn) async {
      try {
        // Import Lyric data - 25% of total progress
        _updateProgress(0.0, "Importing lyrics");
        await _importLyricData(txn, '$assetsPath/Lyric.csv');
        _updateProgress(0.25, "Lyrics imported successfully");

        // Import Artist data - 25% of total progress
        _updateProgress(0.25, "Importing artists");
        await _importArtistData(txn, '$assetsPath/Artist.csv');
        _updateProgress(0.5, "Artists imported successfully");

        // Import Song data - 25% of total progress
        _updateProgress(0.5, "Importing songs");
        await _importSongData(txn, '$assetsPath/Song.csv');
        _updateProgress(0.75, "Songs imported successfully");

        // Import ArtistToSong relations - 25% of total progress
        _updateProgress(0.75, "Importing artist-song relationships");
        await _importArtistToSongData(txn, '$assetsPath/_ArtistToSong.csv');
        _updateProgress(1.0, "Data import completed successfully");

        dev.log('Data import completed successfully');
      } catch (e) {
        _updateProgress(0.0, "Import failed: $e");
        dev.log('Error during data import: $e');
        rethrow; // Re-throw to rollback transaction
      } finally {
        _isImporting = false;
      }
    });
  }

  Future<void> _importLyricData(Transaction txn, String filePath) async {
    dev.log('Importing Lyric data from $filePath');

    // In a real implementation, you'd read the file from assets
    // For example:
    // final String csvString = await rootBundle.loadString(filePath);
    // final List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);

    // Mock implementation for demonstration
    final String csvString = ''; // Load CSV content
    final List<String> lines = csvString.split('\n');

    // Skip header if present
    int count = 0;
    int total = lines.length > 1 ? lines.length - 1 : 0;

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Parse CSV row - this is simplified, you should use a proper CSV parser
      final fields = line.split(',');
      if (fields.length >= 8) {
        try {
          await txn.insert('Lyric', {
            'id': int.parse(fields[0]),
            'content': fields[1],
            'contentText': fields[2].isEmpty ? null : fields[2],
            'url': fields[3],
            'language': fields[4],
            'createdBy': fields[5],
            'isSynced': int.parse(fields[6]),
            'createdAt': fields[7],
            'updatedAt': fields[8],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          count++;

          // Update sub-progress for lyrics import (ranges from 0.0 to 0.25 of the total)
          if (total > 0 && count % 10 == 0) {
            double subProgress = count / total;
            _updateProgress(
              0.0 + (subProgress * 0.25),
              "Importing lyrics: $count/$total",
            );
          }
        } catch (e) {
          dev.log('Error parsing Lyric row: $e');
        }
      }
    }

    dev.log('Imported $count Lyric records');
  }

  Future<void> _importArtistData(Transaction txn, String filePath) async {
    dev.log('Importing Artist data from $filePath');

    // Similar implementation as _importLyricData but for Artist table
    final String csvString = ''; // Load CSV content
    final List<String> lines = csvString.split('\n');

    int count = 0;
    int total = lines.length > 1 ? lines.length - 1 : 0;

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = line.split(',');
      if (fields.length >= 7) {
        try {
          await txn.insert('Artist', {
            'id': int.parse(fields[0]),
            'name': fields[1],
            'bio': fields[2].isEmpty ? null : fields[2],
            'url': fields[3],
            'slug': fields[4],
            'imageUrl': fields[5].isEmpty ? null : fields[5],
            'createdAt': fields[6],
            'updatedAt': fields[7],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          count++;

          // Update sub-progress for artists import (ranges from 0.25 to 0.5 of the total)
          if (total > 0 && count % 10 == 0) {
            double subProgress = count / total;
            _updateProgress(
              0.25 + (subProgress * 0.25),
              "Importing artists: $count/$total",
            );
          }
        } catch (e) {
          dev.log('Error parsing Artist row: $e');
        }
      }
    }

    dev.log('Imported $count Artist records');
  }

  Future<void> _importSongData(Transaction txn, String filePath) async {
    dev.log('Importing Song data from $filePath');

    // Similar implementation as above but for Song table
    final String csvString = ''; // Load CSV content
    final List<String> lines = csvString.split('\n');

    int count = 0;
    int total = lines.length > 1 ? lines.length - 1 : 0;

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = line.split(',');
      if (fields.length >= 8) {
        try {
          await txn.insert('Song', {
            'id': int.parse(fields[0]),
            'title': fields[1],
            'duration': fields[2].isEmpty ? null : int.parse(fields[2]),
            'slug': fields[3],
            'trackNumber': fields[4].isEmpty ? null : int.parse(fields[4]),
            'views': int.parse(fields[5]),
            'lyricId': int.parse(fields[6]),
            'createdAt': fields[7],
            'updatedAt': fields[8],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          count++;

          // Update sub-progress for songs import (ranges from 0.5 to 0.75 of the total)
          if (total > 0 && count % 10 == 0) {
            double subProgress = count / total;
            _updateProgress(
              0.5 + (subProgress * 0.25),
              "Importing songs: $count/$total",
            );
          }
        } catch (e) {
          dev.log('Error parsing Song row: $e');
        }
      }
    }

    dev.log('Imported $count Song records');
  }

  Future<void> _importArtistToSongData(Transaction txn, String filePath) async {
    dev.log('Importing ArtistToSong relations from $filePath');

    // Similar implementation for the junction table
    final String csvString = ''; // Load CSV content
    final List<String> lines = csvString.split('\n');

    int count = 0;
    int total = lines.length;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = line.split(',');
      if (fields.length >= 2) {
        try {
          await txn.insert('_ArtistToSong', {
            'A': int.parse(fields[0]),
            'B': int.parse(fields[1]),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          count++;

          // Update sub-progress for relations import (ranges from 0.75 to 1.0 of the total)
          if (total > 0 && count % 10 == 0) {
            double subProgress = count / total;
            _updateProgress(
              0.75 + (subProgress * 0.25),
              "Importing artist-song relations: $count/$total",
            );
          }
        } catch (e) {
          dev.log('Error parsing ArtistToSong relation: $e');
        }
      }
    }

    dev.log('Imported $count ArtistToSong relations');
  }
}
