import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
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

  // Songs data
  List<Song> _songs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  final int _pageSize = 500;
  int _currentPage = 0;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreSongs();
    }
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _songs = [];
    });

    await _fetchSongsPage();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMoreSongs() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchSongsPage();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _fetchSongsPage() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Determine sort field based on current settings
      String orderBy;
      switch (_sortOption) {
        case SortOption.title:
          orderBy =
              'title ${_sortDirection == SortDirection.ascending ? 'ASC' : 'DESC'}';
          break;
        case SortOption.artist:
          orderBy =
              'title ${_sortDirection == SortDirection.ascending ? 'ASC' : 'DESC'}'; // Will sort by artist later in memory
          break;
        case SortOption.views:
          orderBy =
              'views ${_sortDirection == SortDirection.ascending ? 'ASC' : 'DESC'} NULLS LAST';
          break;
        case SortOption.date:
          orderBy =
              'created_at ${_sortDirection == SortDirection.ascending ? 'ASC' : 'DESC'}';
          break;
      }

      final songsData = await db.query(
        DatabaseHelper.kDbSongTableName,
        orderBy: orderBy,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      final newSongs = await DatabaseHelper.instance.transformSongsData(
        songsData,
      );

      // Handle popular filter directly in the query for better performance
      if (_currentFilter == 'popular') {
        final popularSongsData = await db.query(
          DatabaseHelper.kDbSongTableName,
          orderBy: 'views DESC NULLS LAST',
          limit: _pageSize,
        );
        final popularSongs = await DatabaseHelper.instance.transformSongsData(
          popularSongsData,
        );
        setState(() {
          _songs = popularSongs;
          _hasMoreData = popularSongsData.length == _pageSize;
        });
        return;
      }

      setState(() {
        if (_currentPage == 0) {
          _songs = newSongs;
        } else {
          _songs.addAll(newSongs);
        }
        _currentPage++;
        _hasMoreData = newSongs.length == _pageSize;
      });
    } catch (e) {
      dev.log('Error loading songs: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Filter and sort songs based on current settings
  List<Song> _getFilteredAndSortedSongs() {
    if (_songs.isEmpty) return [];

    List<Song> filteredSongs = List<Song>.from(_songs);

    // Apply filter - popular filter is handled directly in the query
    if (_currentFilter == 'popular') {
      return filteredSongs; // Already sorted in the query
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

    // Artist sorting needs to be handled in memory since it involves relationships
    if (_sortOption == SortOption.artist) {
      filteredSongs.sort((a, b) {
        final artistA = a.artists.isNotEmpty ? a.artists.first.name : '';
        final artistB = b.artists.isNotEmpty ? b.artists.first.name : '';
        return _sortDirection == SortDirection.ascending
            ? artistA.compareTo(artistB)
            : artistB.compareTo(artistA);
      });
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
                  _isLoading
                      ? _buildLoadingState()
                      : filteredSongs.isEmpty
                      ? _buildEmptyState(context)
                      : _buildSongsList(filteredSongs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
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
            color: colorScheme.primary.withValues(alpha: 0.5),
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
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(List<Song> songs) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      separatorBuilder:
          (context, index) => const Divider(height: 1, indent: 70),
      itemCount: songs.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == songs.length) {
          return _buildLoadMoreIndicator();
        }

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

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
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
                      // Reload songs with new filter
                      _loadSongs();
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
                      // Reload songs with new sorting
                      _loadSongs();
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
                      // Reload songs with new direction
                      _loadSongs();
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
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                      colorScheme.primary.withValues(alpha: 0.5),
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
            ],
          ),
        ),
      ),
    );
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
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
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
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
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
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
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
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
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
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
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
