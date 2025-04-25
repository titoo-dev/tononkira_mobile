import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';

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
          }
        },
      ),
    );
  }
}

class MainBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const MainBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(LineIcons.home),
          selectedIcon: Icon(LineIcons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(LineIcons.music),
          selectedIcon: Icon(LineIcons.music),
          label: 'Lyrics',
        ),
        NavigationDestination(
          icon: Icon(LineIcons.heart),
          selectedIcon: Icon(LineIcons.heart),
          label: 'Favorites',
        ),
      ],
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('404 - Page Not Found')));
  }
}
