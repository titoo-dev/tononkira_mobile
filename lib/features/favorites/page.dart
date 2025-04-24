import 'package:flutter/material.dart';
import 'package:tononkira_mobile/models/models.dart';
import 'package:go_router/go_router.dart';

/// A beautiful favorites page that displays user's liked songs
/// following Material 3 design principles
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  // Filter options
  String _currentFilter = 'Recent';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  String _searchQuery = '';
  bool _isLoading = true;

  // Sample data for demonstration - would be fetched from backend in production
  List<Song> _favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    // Simulate loading data
    _loadFavorites();
  }

  // Simulate loading favorites from a data source
  Future<void> _loadFavorites() async {
    // In production, this would be a real API call
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    final sampleFavorites = [
      Song(
        id: 1,
        title: "Veloma",
        slug: "veloma",
        views: 1245,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        artists: [
          Artist(
            id: 1,
            name: "Mahaleo",
            slug: "mahaleo",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            imageUrl:
                'https://www.nocomment.mg/storage/app/public/articles/NC163/cultures/CHpuKxfe3d9c40b974a81858a8fe1ee1a3a9e1.webp',
          ),
        ],
      ),
      Song(
        id: 2,
        title: "Tsara ny tanantsika",
        slug: "tsara-ny-tanantsika",
        views: 982,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
        artists: [
          Artist(
            id: 2,
            name: "Ambondrona",
            slug: "ambondrona",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            imageUrl:
                'https://yt3.googleusercontent.com/ktckEASBqHYs--hLsycAhxTz-7ihykMxDvMN-CnJygTgVSUf-mNZUpSUhzqilkS02Wcavl-C=s900-c-k-c0x00ffffff-no-rj',
          ),
        ],
      ),
      Song(
        id: 3,
        title: "Mozika malaza",
        slug: "mozika-malaza",
        views: 784,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        artists: [
          Artist(
            id: 3,
            name: "Ny Ainga",
            slug: "ny-ainga",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            imageUrl:
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpPM-JypQLj_0iGGMkAAToFmKgEwFZH_9Yy75fDdyVlaZs5eZVDFoG6S3IpF8TCWrBrdY&usqp=CAU',
          ),
        ],
      ),
      Song(
        id: 4,
        title: "Hira faneva",
        slug: "hira-faneva",
        views: 621,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
        artists: [
          Artist(
            id: 4,
            name: "Tarika Ramaroson",
            slug: "tarika-ramaroson",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      ),
      Song(
        id: 5,
        title: "Fitia tsy miala",
        slug: "fitia-tsy-miala",
        views: 845,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        artists: [
          Artist(
            id: 5,
            name: "Nanie",
            slug: "nanie",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      ),
    ];

    if (mounted) {
      setState(() {
        _favoriteSongs = sampleFavorites;
        _isLoading = false;
      });
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

  void _removeFavorite(Song song) {
    setState(() {
      _favoriteSongs.removeWhere((s) => s.id == song.id);
    });

    // Show a snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${song.title}" from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _favoriteSongs.add(song);
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * 0.9,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                      : _buildSongsList(filteredFavorites),
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
                  'Favorites',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Attractive icon with container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              size: 60,
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorites Yet',
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Songs you like will appear here for quick access',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              // Navigate to browse lyrics
              context.go('/lyrics');
            },
            icon: const Icon(Icons.music_note),
            label: const Text('Browse Lyrics'),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(List<Song> songs) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      separatorBuilder:
          (context, index) => const Divider(height: 1, indent: 70),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return FavoriteSongListTile(
          song: song,
          onTap:
              () => context.pushNamed(
                'songDetails',
                pathParameters: {'id': song.id.toString()},
              ),
          onRemove: () => _removeFavorite(song),
        );
      },
    );
  }
}

/// Modern search bar with rounded edges following Material 3 design
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchBar({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'favoritesSearchBar',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          color: colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.search, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search favorites...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear, color: colorScheme.primary),
              onPressed: () {
                controller.clear();
                onChanged?.call('');
              },
              tooltip: 'Clear search',
            ),
          ],
        ),
      ),
    );
  }
}

/// Beautiful song list tile with visual enhancements for favorites
class FavoriteSongListTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteSongListTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final artistName =
        song.artists.isNotEmpty ? song.artists.first.name : 'Unknown Artist';
    final imageUrl =
        song.artists.isNotEmpty ? song.artists.first.imageUrl : null;

    return Dismissible(
      key: Key('favorite-${song.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(Icons.delete_outline, color: colorScheme.onError),
      ),
      onDismissed: (_) => onRemove(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                // Artist image or styled container
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child:
                        imageUrl != null
                            ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _buildArtistPlaceholder(
                                    context,
                                    artistName,
                                  ),
                            )
                            : _buildArtistPlaceholder(context, artistName),
                  ),
                ),

                const SizedBox(width: 16),

                // Song details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artistName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // View counter with icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatViews(song.views ?? 0),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Favorite button
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.favorite,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        onPressed: onRemove,
                        tooltip: 'Remove from favorites',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Format view count for display (e.g., 1.2K, 3.5M)
  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  // Build a placeholder for when artist image is not available
  Widget _buildArtistPlaceholder(BuildContext context, String artistName) {
    final colorScheme = Theme.of(context).colorScheme;

    // Create a deterministic but varied color based on artist name
    final int nameHash = artistName.hashCode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          artistName.isNotEmpty ? artistName[0].toUpperCase() : '?',
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for filtering favorite songs
class FavoritesFilterBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final ValueChanged<String> onFilterSelected;
  final String currentFilter;
  final VoidCallback onApplySelected;

  const FavoritesFilterBottomSheet({
    super.key,
    required this.scrollController,
    required this.onFilterSelected,
    required this.currentFilter,
    required this.onApplySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Sort Favorites', style: textTheme.titleLarge),
              ],
            ),
          ),

          const Divider(),

          // Filter options
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildFilterOption(
                  context,
                  'Recent',
                  'Most Recent',
                  Icons.access_time,
                ),
                _buildFilterOption(
                  context,
                  'Artist',
                  'By Artist Name',
                  Icons.person,
                ),
                _buildFilterOption(
                  context,
                  'Title',
                  'By Song Title',
                  Icons.sort_by_alpha,
                ),
                _buildFilterOption(
                  context,
                  'Popular',
                  'Most Popular',
                  Icons.trending_up,
                ),
              ],
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: onApplySelected,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentFilter == value;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onFilterSelected(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
