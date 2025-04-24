import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tononkira_mobile/models/models.dart';

/// A beautiful lyrics tab screen displaying all available lyrics with filtering options
class LyricsTab extends StatefulWidget {
  const LyricsTab({super.key});

  @override
  State<LyricsTab> createState() => _LyricsTabState();
}

class _LyricsTabState extends State<LyricsTab> {
  // Filter options
  String _currentFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  SortDirection _sortDirection = SortDirection.ascending;
  SortOption _sortOption = SortOption.title;
  String _searchQuery = '';

  // Sample data for demonstration
  final List<Song> _songs = List.generate(
    50,
    (index) => Song(
      id: index + 1,
      title: _generateSongTitle(index),
      slug: "song-${index + 1}",
      views: 100 + (index * 10),
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now(),
      artists: [
        Artist(
          id: (index % 5) + 1,
          name: _generateArtistName(index % 5),
          slug: "artist-${(index % 5) + 1}",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
    ),
  );

  // Generate song titles for sample data
  static String _generateSongTitle(int index) {
    final titles = [
      "Veloma",
      "Tsy Haiko",
      "Ianao",
      "Nofy Ratsy",
      "Embona",
      "Tonga Soa",
      "Lasa Ny Andro",
      "Tsara Ny Mino",
      "Ho Avy Aho",
      "Fitiavana",
      "Tanindrazana",
      "Tiana Ianao",
      "Miandry Anao",
      "Misaotra",
      "Tsy Ampy",
      "Mba Jereo",
      "Fitia Tsy Miova",
      "Izao no Izy",
      "Tsy Very",
      "Mandalo",
    ];
    return "${titles[index % titles.length]} ${index + 1}";
  }

  // Generate artist names for sample data
  static String _generateArtistName(int index) {
    final artists = [
      "Mahaleo",
      "Ambondrona",
      "Ny Ainga",
      "Tarika Johary",
      "Njakatiana",
    ];
    return artists[index];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter and sort songs based on current settings
  List<Song> _getFilteredAndSortedSongs() {
    List<Song> filteredSongs = List<Song>.from(_songs);

    // Apply filter
    if (_currentFilter == 'popular') {
      filteredSongs.sort((a, b) => b.views?.compareTo(a.views ?? 0) ?? 0);
      return filteredSongs; // No additional sorting needed for popular filter
    }

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
    if (_sortOption == SortOption.title) {
      filteredSongs.sort(
        (a, b) =>
            _sortDirection == SortDirection.ascending
                ? a.title.compareTo(b.title)
                : b.title.compareTo(a.title),
      );
    } else if (_sortOption == SortOption.artist) {
      filteredSongs.sort((a, b) {
        final artistA = a.artists.isNotEmpty ? a.artists.first.name : '';
        final artistB = b.artists.isNotEmpty ? b.artists.first.name : '';
        return _sortDirection == SortDirection.ascending
            ? artistA.compareTo(artistB)
            : artistB.compareTo(artistA);
      });
    } else if (_sortOption == SortOption.views) {
      filteredSongs.sort(
        (a, b) =>
            _sortDirection == SortDirection.ascending
                ? (a.views ?? 0).compareTo(b.views ?? 0)
                : (b.views ?? 0).compareTo(a.views ?? 0),
      );
    } else if (_sortOption == SortOption.date) {
      filteredSongs.sort(
        (a, b) =>
            _sortDirection == SortDirection.ascending
                ? a.createdAt.compareTo(b.createdAt)
                : b.createdAt.compareTo(a.createdAt),
      );
    }

    return filteredSongs;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredSongs = _getFilteredAndSortedSongs();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar with animations
            _buildAppBar(context),

            // Main songs list
            Expanded(
              child:
                  filteredSongs.isEmpty
                      ? _buildEmptyState(context)
                      : _buildSongsList(filteredSongs),
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
                  'Lyrics',
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

  // A chip that shows current sort/filter status and opens bottom sheet when tapped
  Widget _buildFilterChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String filterText;
    if (_currentFilter == 'popular') {
      filterText = "Popular";
    } else {
      // Show current sort option and direction
      String sortName;
      switch (_sortOption) {
        case SortOption.title:
          sortName = "Title";
          break;
        case SortOption.artist:
          sortName = "Artist";
          break;
        case SortOption.views:
          sortName = "Views";
          break;
        case SortOption.date:
          sortName = "Date";
          break;
      }

      String direction = _sortDirection == SortDirection.ascending ? "↑" : "↓";
      filterText = "$sortName $direction";
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
            Icon(Icons.tune, size: 16, color: colorScheme.onPrimaryContainer),
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
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No lyrics found',
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filter or search terms',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
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
        return SongListTile(
          song: song,
          onTap:
              () => context.pushNamed(
                'lyricDetails',
                pathParameters: {'id': song.id.toString()},
              ),
        );
      },
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
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return FilterBottomSheet(
                  scrollController: scrollController,
                  onFilterSelected: (filter) {
                    setState(() {
                      _currentFilter = filter;
                      // Reset sort option when changing to popular
                      if (filter == 'popular') {
                        _sortOption = SortOption.views;
                        _sortDirection = SortDirection.descending;
                      }
                    });
                    Navigator.pop(context);
                  },
                  currentFilter: _currentFilter,
                  sortOption: _sortOption,
                  sortDirection: _sortDirection,
                  onSortOptionChanged: (option) {
                    setModalState(() {
                      _sortOption = option;
                    });
                    setState(() {
                      _sortOption = option;
                      // When changing sort option, reset to "all" filter
                      _currentFilter = 'all';
                    });
                  },
                  onSortDirectionChanged: (direction) {
                    setModalState(() {
                      _sortDirection = direction;
                    });
                    setState(() {
                      _sortDirection = direction;
                      // When changing sort direction, reset to "all" filter
                      _currentFilter = 'all';
                    });
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
}

/// Sort options enum
enum SortOption { title, artist, views, date }

/// Sort direction enum
enum SortDirection { ascending, descending }

/// Modern search bar with rounded edges following Material 3 design
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchBar({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'lyricsSearchBar',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                  hintText: 'Search for songs or artists...',
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

/// Beautiful song list tile with visual enhancements
class SongListTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongListTile({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              // Artistic song icon with Material 3 styling
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primary.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
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
                      song.artists.map((a) => a.name).join(', '),
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
                  // More options button
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        // Show options menu
                      },
                    ),
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
}

/// Bottom sheet for advanced filtering options
class FilterBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final ValueChanged<String> onFilterSelected;
  final String currentFilter;
  final SortOption sortOption;
  final SortDirection sortDirection;
  final ValueChanged<SortOption> onSortOptionChanged;
  final ValueChanged<SortDirection> onSortDirectionChanged;
  final VoidCallback onApplySelected;

  const FilterBottomSheet({
    super.key,
    required this.scrollController,
    required this.onFilterSelected,
    required this.currentFilter,
    required this.sortOption,
    required this.sortDirection,
    required this.onSortOptionChanged,
    required this.onSortDirectionChanged,
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
                Text('Filter & Sort Lyrics', style: textTheme.titleLarge),
              ],
            ),
          ),

          const Divider(),

          // Filter options
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // Filter by section
                _buildFilterSection(context, 'Filter By'),
                _buildFilterOption(context, 'all', 'All Lyrics', Icons.list),
                _buildFilterOption(
                  context,
                  'popular',
                  'Most Popular',
                  Icons.trending_up,
                ),

                const SizedBox(height: 16),

                // Sort by section
                _buildFilterSection(context, 'Sort By'),
                _buildSortOption(
                  context,
                  SortOption.title,
                  'Title',
                  Icons.sort_by_alpha,
                ),
                _buildSortOption(
                  context,
                  SortOption.artist,
                  'Artist',
                  Icons.person,
                ),
                _buildSortOption(
                  context,
                  SortOption.views,
                  'Views',
                  Icons.visibility,
                ),
                _buildSortOption(
                  context,
                  SortOption.date,
                  'Date Added',
                  Icons.calendar_today,
                ),

                const SizedBox(height: 16),

                // Sort direction section
                _buildFilterSection(context, 'Sort Direction'),
                _buildDirectionOption(
                  context,
                  SortDirection.ascending,
                  'Ascending (A-Z, 0-9)',
                  Icons.arrow_upward,
                ),
                _buildDirectionOption(
                  context,
                  SortDirection.descending,
                  'Descending (Z-A, 9-0)',
                  Icons.arrow_downward,
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
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
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

  Widget _buildFilterSection(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

  Widget _buildSortOption(
    BuildContext context,
    SortOption value,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = sortOption == value;
    final isDisabled = currentFilter == 'popular' && value != SortOption.views;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isDisabled ? null : () => onSortOptionChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isDisabled
                        ? colorScheme.onSurface.withOpacity(0.38)
                        : isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isDisabled
                          ? colorScheme.onSurface.withOpacity(0.38)
                          : isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected && !isDisabled)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionOption(
    BuildContext context,
    SortDirection value,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = sortDirection == value;
    final isDisabled =
        currentFilter == 'popular' && value == SortDirection.ascending;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isDisabled ? null : () => onSortDirectionChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isDisabled
                        ? colorScheme.onSurface.withOpacity(0.38)
                        : isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isDisabled
                          ? colorScheme.onSurface.withOpacity(0.38)
                          : isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected && !isDisabled)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
