import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tononkira_mobile/features/home/page.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Track the selected index based on the current route
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndexFromRoute();
  }

  // Update selected index based on current route
  void _updateSelectedIndexFromRoute() {
    final String location = GoRouterState.of(context).uri.path;
    if (location.contains('/home')) {
      _selectedIndex = 0;
    } else if (location.contains('/lyrics')) {
      _selectedIndex = 1;
    } else if (location.contains('/favorites')) {
      _selectedIndex = 2;
    } else if (location.contains('/settings')) {
      _selectedIndex = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: MainBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navigate based on index
          switch (index) {
            case 0:
              context.go('/main/home');
              break;
            case 1:
              context.go('/main/lyrics');
              break;
            case 2:
              context.go('/main/favorites');
              break;
            case 3:
              context.go('/main/settings');
              break;
          }
        },
      ),
    );
  }
}

class LyricsTab extends StatelessWidget {
  const LyricsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Lyrics Tab')));
  }
}

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Favorites Tab')));
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Settings Tab')));
  }
}

class SongDetailsScreen extends StatelessWidget {
  final String songId;
  const SongDetailsScreen({super.key, required this.songId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Song Details: $songId')));
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Search Screen')));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Profile Screen')));
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('404 - Page Not Found')));
  }
}
