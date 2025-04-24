import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
import 'dart:async';

class DatabaseSyncPage extends StatefulWidget {
  const DatabaseSyncPage({super.key});

  @override
  State<DatabaseSyncPage> createState() => _DatabaseSyncPageState();
}

class _DatabaseSyncPageState extends State<DatabaseSyncPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  String _status = 'Preparing...';
  bool _isComplete = false;
  bool _hasError = false;
  String _errorMessage = '';
  late StreamSubscription<Map<String, dynamic>> _progressSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startDatabaseSync();
  }

  Future<void> _startDatabaseSync() async {
    try {
      // Subscribe to progress updates
      _progressSubscription = DatabaseHelper.instance.progressStream.listen((
        update,
      ) {
        setState(() {
          _progress = update['progress'];
          _status = update['status'];
        });

        // When complete, prepare to navigate to home
        if (_progress >= 1.0) {
          _completeSync();
        }
      });

      // Start the database import
      await DatabaseHelper.instance.importDataFromCSV('assets/data');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _completeSync() {
    setState(() {
      _isComplete = true;
    });

    // Wait a moment to show the completion animation before navigating
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/main/home');
      }
    });
  }

  void _retrySync() {
    setState(() {
      _progress = 0.0;
      _status = 'Preparing...';
      _isComplete = false;
      _hasError = false;
      _errorMessage = '';
    });

    _startDatabaseSync();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // App logo or icon
              _buildAppLogo(colorScheme),
              const SizedBox(height: 40),
              // Title and subtitle
              Text(
                'Setting Up Your Experience',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'re preparing the song database to provide you with the best experience',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Sync status and progress
              _buildSyncStatus(colorScheme, textTheme),
              const SizedBox(height: 20),
              // Progress bar
              _buildProgressIndicator(colorScheme),
              const SizedBox(height: 30),
              // Error message or success message
              _hasError
                  ? _buildErrorView(colorScheme, textTheme)
                  : _isComplete
                  ? _buildSuccessView(colorScheme, textTheme)
                  : const SizedBox(height: 60),
              const Spacer(),
              // Footer or additional info
              Text(
                'Tononkira - Your Malagasy Song Lyrics App',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo(ColorScheme colorScheme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: 60,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildSyncStatus(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          _status,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${(_progress * 100).toStringAsFixed(0)}%',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    return Column(
      children: [
        // Animated progress indicator
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: Stack(
              children: [
                // Background
                Container(
                  width: double.infinity,
                  color: colorScheme.surfaceVariant,
                ),
                // Progress fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: MediaQuery.of(context).size.width * _progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.tertiary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Sync step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepIndicator('Lyrics', _progress >= 0.25, colorScheme),
            _buildStepIndicator('Artists', _progress >= 0.5, colorScheme),
            _buildStepIndicator('Songs', _progress >= 0.75, colorScheme),
            _buildStepIndicator('Relations', _progress >= 1.0, colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator(
    String label,
    bool isCompleted,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? colorScheme.primary
                    : colorScheme.surfaceVariant.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isCompleted
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
              width: 2,
            ),
          ),
          child:
              isCompleted
                  ? Icon(Icons.check, color: colorScheme.onPrimary, size: 16)
                  : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isCompleted
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withOpacity(0.7),
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 48, color: colorScheme.error),
        const SizedBox(height: 16),
        Text(
          'Sync Error',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage.length > 100
              ? '${_errorMessage.substring(0, 100)}...'
              : _errorMessage,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _retrySync,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 32,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Setup Complete!',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Taking you to the app...',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
