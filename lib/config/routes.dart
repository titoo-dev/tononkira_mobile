import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tononkira_mobile/features/db_sync/page.dart';
import 'package:tononkira_mobile/features/favorites/page.dart';
import 'package:tononkira_mobile/features/home/lyric_details/page.dart';
import 'package:tononkira_mobile/features/home/page.dart';
import 'package:tononkira_mobile/features/lyrics/page.dart';
import 'package:tononkira_mobile/features/onboarding/page.dart';
import 'package:tononkira_mobile/features/page.dart';

/// Configuration class for application routes
class AppRoutes {
  /// Private constructor to prevent instantiation
  AppRoutes._();

  // Route names as constants for easy reference and maintenance
  /// Onboarding route
  static const String onboarding = '/onboarding';

  /// Database sync route
  static const String databaseSync = '/database-sync';

  /// Main route containing bottom navigation
  static const String main = '/main';

  /// Home tab route
  static const String home = '/main/home';

  /// Lyrics tab route
  static const String lyrics = '/main/lyrics';

  /// Favorites tab route
  static const String favorites = '/main/favorites';

  /// Settings tab route
  static const String settings = '/main/settings';

  /// Song details route
  static const String songDetails = '/song/:id';

  /// Playlist route
  static const String playlist = '/playlist/:id';

  /// Search route
  static const String search = '/search';

  /// Profile route
  static const String profile = '/profile';

  /// GoRouter configuration for the application
  static final router = GoRouter(
    initialLocation: databaseSync,
    routes: [
      // Onboarding route (shown only first time)
      GoRoute(
        path: '/database-sync',
        name: 'databaseSync',
        builder: (context, state) => const DatabaseSyncPage(),
      ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Database sync route (shown during initial setup)

      // Main screen with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: '/main/home',
            name: 'home',
            builder: (context, state) => const HomeTab(),
            routes: [
              GoRoute(
                path: 'lyric/:id',
                name: 'lyricDetails',
                builder: (context, state) {
                  final songId = state.pathParameters['id'];

                  // Creating a sample song with mock data
                  // In a production app, you would fetch this from an API or database
                  return LyricDetailsPage(songId: int.parse(songId!));
                },
              ),
            ],
          ),
          // Lyrics tab
          GoRoute(
            path: '/main/lyrics',
            name: 'lyrics',
            builder: (context, state) => const LyricsTab(),
          ),
          // Favorites tab
          GoRoute(
            path: '/main/favorites',
            name: 'favorites',
            builder: (context, state) => const FavoritesTab(),
          ),
        ],
      ),
    ],
    // Custom error page when route is not found
    errorBuilder: (context, state) => const NotFoundScreen(),
    // Log routing for debugging purposes
    debugLogDiagnostics: true,
    // Redirect to onboarding on first launch, then to main screen
    redirect: (BuildContext context, GoRouterState state) async {
      // You can add logic here to check if this is first launch
      // Example:
      // final firstLaunch = PreferencesService.isFirstLaunch();
      // if (firstLaunch && state.path != '/onboarding') return '/onboarding';

      // Redirect to main screen if trying to access root
      if (state.path == '/') {
        return databaseSync;
      }

      return null;
    },
  );
}
