import 'package:flutter/material.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
import 'package:tononkira_mobile/features/favorites/widgets/favorite_card.dart';
import 'package:tononkira_mobile/features/favorites/widgets/favorites_filter_bottom_sheet.dart';
import 'package:tononkira_mobile/models/models.dart';
import 'package:go_router/go_router.dart';

/// A beautiful favorites page that displays user's liked lyrics in a modern layout
/// following latest Material 3 design trends
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab>
    with SingleTickerProviderStateMixin {
  // Filter options
  String _currentFilter = 'Recent';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  String _searchQuery = '';
  bool _isLoading = true;
  late AnimationController _animationController;

  // List to store favorite songs
  List<Song> _favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    // Animation controller for staggered animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Load favorites from database
    _loadFavorites();
  }

  // Load favorites from database
  Future<void> _loadFavorites() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Query the favorites table
      final favorites = await db.query('Favorites', orderBy: 'updatedAt DESC');

      if (favorites.isEmpty) {
        if (mounted) {
          setState(() {
            _favoriteSongs = [];
            _isLoading = false;
          });
          _animationController.forward();
        }
        return;
      }

      // Get all the song IDs from favorites
      final songIds = favorites.map((fav) => fav['songId'] as int).toList();

      // Query songs with these IDs
      final songsData = await db.query(
        'Song',
        where: 'id IN (${List.filled(songIds.length, '?').join(', ')})',
        whereArgs: songIds,
      );

      // Transform songs data to include artists
      final songs = await DatabaseHelper.instance.transformSongsData(songsData);

      if (mounted) {
        setState(() {
          _favoriteSongs = songs;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading favorites: $e');
    }
  }

  // Filter and sort favorites based on current settings
  List<Song> _getFilteredAndSortedFavorites() {
    List<Song> filteredSongs = List<Song>.from(_favoriteSongs);

    // Apply search if needed
    if (_searchQuery.isNotEmpty) {
      filteredSongs =
          filteredSongs.where((song) {
            return song.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                song.artists.any(
                  (artist) => artist.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                );
          }).toList();
    }

    // Apply sorting
    switch (_currentFilter) {
      case 'Recent':
        filteredSongs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Artist':
        filteredSongs.sort((a, b) {
          if (a.artists.isEmpty) return 1;
          if (b.artists.isEmpty) return -1;
          return a.artists.first.name.compareTo(b.artists.first.name);
        });
        break;
      case 'Title':
        filteredSongs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Popular':
        filteredSongs.sort((a, b) => (b.views ?? 0).compareTo(a.views ?? 0));
        break;
    }

    return filteredSongs;
  }

  Future<void> _removeFavorite(Song song) async {
    // Remove from UI immediately for better UX
    setState(() {
      _favoriteSongs.removeWhere((s) => s.id == song.id);
    });

    try {
      // Remove from database
      final db = await DatabaseHelper.instance.database;
      await db.delete('Favorites', where: 'songId = ?', whereArgs: [song.id]);

      // Show a snackbar with undo option
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${song.title}" from favorites'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                // Add back to favorites in the database
                await db.insert('Favorites', {
                  'songId': song.id,
                  'updatedAt': DateTime.now().toIso8601String(),
                });

                // Reload favorites to refresh the list
                _loadFavorites();
              },
            ),
            behavior: SnackBarBehavior.floating,
            width: MediaQuery.of(context).size.width * 0.9,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.4,
              minChildSize: 0.3,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return FavoritesFilterBottomSheet(
                  scrollController: scrollController,
                  currentFilter: _currentFilter,
                  onFilterSelected: (filter) {
                    setState(() {
                      _currentFilter = filter;
                    });
                    Navigator.pop(context);
                  },
                  onApplySelected: () {
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredFavorites = _getFilteredAndSortedFavorites();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar with animations
            _buildAppBar(context),

            // Main content
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                      : filteredFavorites.isEmpty
                      ? _buildEmptyState(context)
                      : _buildLyricsList(filteredFavorites),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _showSearchBar ? 142 : 72,
      child: Column(
        children: [
          // Title row with actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                // Title with decorative element
                Text(
                  'Favorite Lyrics',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const Spacer(),

                // Current filter/sort indicator chip
                _buildFilterChip(context),

                // Search button
                IconButton(
                  icon: Icon(
                    _showSearchBar ? Icons.close : Icons.search,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                      if (!_showSearchBar) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // Search bar (expandable)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child:
                _showSearchBar
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: SearchBar(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // A chip that shows current sort status and opens bottom sheet when tapped
  Widget _buildFilterChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String filterText;
    IconData filterIcon;

    switch (_currentFilter) {
      case 'Recent':
        filterText = "Recent";
        filterIcon = Icons.access_time;
        break;
      case 'Artist':
        filterText = "Artist";
        filterIcon = Icons.person;
        break;
      case 'Title':
        filterText = "Title";
        filterIcon = Icons.sort_by_alpha;
        break;
      case 'Popular':
        filterText = "Popular";
        filterIcon = Icons.trending_up;
        break;
      default:
        filterText = "Recent";
        filterIcon = Icons.access_time;
    }

    return InkWell(
      onTap: () => _showFilterBottomSheet(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(filterIcon, size: 16, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: 4),
            Text(
              filterText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Using a more modern and minimalist empty state design
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Modern illustration container
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 70,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
                Positioned(
                  bottom: 35,
                  right: 35,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 24,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Saved Lyrics',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 260,
            child: Text(
              'Lyrics you heart will appear here for quick access and offline reading',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.tonal(
            onPressed: () {
              // Navigate to browse lyrics
              context.go('/lyrics');
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Discover Lyrics'),
          ),
        ],
      ),
    );
  }

  // Build a modern list of favorite lyrics
  Widget _buildLyricsList(List<Song> songs) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        // Create a delayed animation for each item
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index / songs.length) * 0.5, // Stagger start times
              0.5 + (index / songs.length) * 0.5, // Stagger end times
              curve: Curves.easeOut,
            ),
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.2, 0),
              end: Offset.zero,
            ).animate(animation),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: FavoriteLyricCard(
                song: songs[index],
                onTap:
                    () => context.pushNamed(
                      'songDetails',
                      pathParameters: {'id': songs[index].id.toString()},
                    ),
                onRemove: () => _removeFavorite(songs[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchBar({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color:
            Theme.of(context).brightness == Brightness.light
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
                : colorScheme.surfaceContainerHighest,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search lyrics...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
            onPressed: () {
              controller.clear();
              onChanged?.call('');
            },
            tooltip: 'Clear search',
          ),
        ],
      ),
    );
  }
}
