import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tononkira_mobile/config/routes.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
import 'dart:async';

class DatabaseSyncPage extends StatefulWidget {
  const DatabaseSyncPage({super.key});

  @override
  State<DatabaseSyncPage> createState() => _DatabaseSyncPageState();
}

class _DatabaseSyncPageState extends State<DatabaseSyncPage> {
  double _progress = 0.0;
  String _status = 'Setting up your library';
  bool _isComplete = false;
  bool _hasError = false;
  String _errorMessage = '';
  StreamSubscription<Map<String, dynamic>>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _checkDatabaseAndNavigate();
  }

  Future<void> _checkDatabaseAndNavigate() async {
    try {
      // Check if database exists and has data
      final db = await DatabaseHelper.instance.database;
      final artistCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM Artist'),
      );
      final songCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM Song'),
      );

      if (mounted) {
        // If database is empty or not properly set up, go to sync page
        if (artistCount == 0 || songCount == 0) {
          _startDatabaseSync();
        } else {
          // Database exists and has data, go to home
          GoRouter.of(context).go(AppRoutes.home);
        }
      }
    } catch (e) {
      // If there's an error (like tables don't exist), go to sync page
      if (mounted) {
        GoRouter.of(context).go(AppRoutes.databaseSync);
      }
    }
  }

  Future<void> _startDatabaseSync() async {
    _progressSubscription = DatabaseHelper.instance.progressStream.listen(
      (update) {
        setState(() {
          _progress = update['progress'];
          _status = update['status'];
        });

        if (_progress >= 1.0) {
          _completeSync();
        }
      },
      onError: (e) {
        dev.log('Error during database sync: $e');
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      },
      onDone: () {
        dev.log('Database sync completed successfully');
        setState(() {
          _isComplete = true;
        });
      },
    );

    try {
      await DatabaseHelper.instance.importDataFromSQL('assets/sql');
    } catch (e) {
      setState(() {
        dev.log('Error during database sync: $e');
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _completeSync() {
    setState(() {
      _isComplete = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  void _retrySync() {
    setState(() {
      _progress = 0.0;
      _status = 'Setting up your library';
      _isComplete = false;
      _hasError = false;
      _errorMessage = '';
    });

    _startDatabaseSync();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.music_note,
                  size: 50,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                'Setting Up Tononkira',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Status text
              Text(
                _status,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Error or Progress UI
              _hasError
                  ? _buildErrorWidget(colorScheme)
                  : _buildProgressWidget(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressWidget(ColorScheme colorScheme) {
    return Column(
      children: [
        // Progress percentage
        Text(
          '${(_progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),

        // Success animation when complete
        if (_isComplete)
          Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ready to go!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildErrorWidget(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.error_outline, size: 40, color: colorScheme.error),
        ),
        const SizedBox(height: 20),
        Text(
          'Something went wrong',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.error,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage.length > 100
              ? '${_errorMessage.substring(0, 100)}...'
              : _errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _retrySync,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}
