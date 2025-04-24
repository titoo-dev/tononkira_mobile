import 'package:flutter/material.dart';
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

  // Sample data for demonstration - would be fetched from backend in production
  List<Song> _favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    // Animation controller for staggered animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

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
      _animationController.forward();
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
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 70,
                  color: colorScheme.primary.withOpacity(0.7),
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

/// Modern search bar with rounded edges following Material 3 design
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
                ? colorScheme.surfaceVariant.withOpacity(0.7)
                : colorScheme.surfaceVariant,
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
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
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

/// Beautiful lyric card with modern Material 3 design for favorites list view
class FavoriteLyricCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteLyricCard({
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

    // Create a modern card with Material 3 styling
    return Card(
      elevation: 0, // Flatter design trend
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Artist/Lyric image or placeholder
              Hero(
                tag: 'lyric_${song.id}',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.secondaryContainer,
                  ),
                  clipBehavior: Clip.antiAlias,
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

              // Lyric details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with lyrics indicator
                    Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            song.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Artist name
                    Text(
                      'by $artistName',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Stats row
                    Row(
                      children: [
                        // View count
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
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

                        const SizedBox(width: 16),

                        // Added date
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(song.createdAt),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Remove from favorites
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.favorite,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    tooltip: 'Remove from favorites',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer.withOpacity(
                        0.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Quick actions menu
                  IconButton(
                    onPressed: () {
                      _showQuickActionsMenu(context);
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    tooltip: 'More options',
                  ),
                ],
              ),
            ],
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

  // Format date in a readable format
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Show quick actions menu for the lyric
  void _showQuickActionsMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.share, color: colorScheme.primary),
                  title: const Text('Share lyrics'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement sharing functionality
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.download_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Download for offline'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement download functionality
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit_note, color: colorScheme.primary),
                  title: const Text('Add to collection'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement collection functionality
                  },
                ),
              ],
            ),
          ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // Build a placeholder for when artist image is not available
  Widget _buildArtistPlaceholder(BuildContext context, String artistName) {
    final colorScheme = Theme.of(context).colorScheme;

    // Create a modern gradient background
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondaryContainer,
            colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          artistName.isNotEmpty ? artistName[0].toUpperCase() : '?',
          style: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for filtering favorite lyrics
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
            child: FilledButton(
              onPressed: onApplySelected,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Apply'),
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
      color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
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
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? colorScheme.onSecondaryContainer
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
