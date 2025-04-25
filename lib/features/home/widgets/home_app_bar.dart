import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
import 'package:tononkira_mobile/features/home/widgets/featured_song_card.dart';
import 'package:tononkira_mobile/features/home/widgets/highlighted_text.dart';
import 'package:tononkira_mobile/features/home/widgets/profile_button.dart';
import 'package:tononkira_mobile/models/models.dart';
import 'package:tononkira_mobile/shared/loader.dart';

/// App bar component with title and search functionality
class HomeAppBar extends StatefulWidget {
  final String title;
  final TextEditingController searchController;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.searchController,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // App Logo/Title
              Expanded(
                child: Text(
                  widget.title,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              // Profile Icon Button
              ProfileButton(),
            ],
          ),
          const SizedBox(height: 16),
          // Modern Animated Search Bar
          SearchBar(controller: widget.searchController),
        ],
      ),
    );
  }
}

/// Modern search bar with rounded edges following Material 3 design
class SearchBar extends StatefulWidget {
  final TextEditingController controller;

  const SearchBar({super.key, required this.controller});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool _isSearching = false;
  List<Song> _searchResults = [];
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _isSearching = true;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (widget.controller.text.length >= 2) {
        _performSearch(widget.controller.text);
      } else if (widget.controller.text.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = _focusNode.hasFocus;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    final db = await DatabaseHelper.instance.database;

    try {
      // Complex query that searches across songs, artists and lyrics
      final results = await db.rawQuery(
        '''
        SELECT DISTINCT s.id, s.title, s.slug, s.views, s.createdAt, s.updatedAt 
        FROM Song s
        LEFT JOIN _ArtistToSong ats ON s.id = ats.B
        LEFT JOIN Artist a ON a.id = ats.A
        LEFT JOIN Lyric l ON l.id = s.lyricId
        WHERE 
          s.title LIKE ? OR 
          a.name LIKE ? OR 
          (l.content LIKE ? OR l.contentText LIKE ?)
        LIMIT 20
      ''',
        ['%$query%', '%$query%', '%$query%', '%$query%'],
      );

      // Transform raw data to Song objects
      final songs = await DatabaseHelper.instance.transformSongsData(results);

      setState(() {
        _searchResults = songs;
      });
    } catch (e) {
      dev.log('Search error: $e');
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _clearSearch() {
    widget.controller.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Hero(
          tag: 'searchBar',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.search, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for lyrics, artists...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                if (_isSearching && widget.controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.primary),
                    onPressed: _clearSearch,
                    tooltip: 'Clear search',
                  )
                else
                  IconButton(
                    icon: Icon(Icons.mic, color: colorScheme.primary),
                    onPressed: () {},
                    tooltip: 'Voice search',
                  ),
              ],
            ),
          ),
        ),

        // Search results section
        if (_isSearching)
          SearchResultsSection(
            searchQuery: widget.controller.text,
            searchResults: _searchResults,
            isLoading:
                widget.controller.text.length >= 2 &&
                _debounce?.isActive == true,
          ),
      ],
    );
  }
}

class SearchResultsSection extends StatelessWidget {
  final String searchQuery;
  final List<Song> searchResults;
  final bool isLoading;

  const SearchResultsSection({
    super.key,
    required this.searchQuery,
    required this.searchResults,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Show loading indicator or placeholder when typing
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: Loader(width: 80)),
      );
    }

    // Show placeholder when search field is empty or has less than 2 chars
    if (searchQuery.length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Type at least 2 characters to search',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // No search results
    if (searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found for "$searchQuery"',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Display search results
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            'Search Results',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Found ${searchResults.length} results for "$searchQuery"',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // List of search results with beautiful animations
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final song = searchResults[index];
            return _buildAnimatedSearchResult(context, song, index);
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedSearchResult(
    BuildContext context,
    Song song,
    int index,
  ) {
    // Staggered animation for search results
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(0, 0, 0),
      child: SearchResultItem(
        song: song,
        highlightText: searchQuery,
        delay: Duration(milliseconds: index * 50),
      ),
    );
  }
}

class SearchResultItem extends StatefulWidget {
  final Song song;
  final String highlightText;
  final Duration delay;

  const SearchResultItem({
    super.key,
    required this.song,
    required this.highlightText,
    required this.delay,
  });

  @override
  State<SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<SearchResultItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child:
                    widget.song.artists.isNotEmpty &&
                            widget.song.artists.first.imageUrl != null
                        ? ArtistImage(
                          imageUrl: widget.song.artists.first.imageUrl,
                        )
                        : ArtistPlaceholder(
                          artistName:
                              widget.song.artists.isNotEmpty
                                  ? widget.song.artists.first.name
                                  : "Unknown",
                        ),
              ),
            ),
            title: HighlightedText(
              text: widget.song.title,
              highlight: widget.highlightText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
              highlightStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                backgroundColor: colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            subtitle:
                widget.song.artists.isNotEmpty
                    ? HighlightedText(
                      text: widget.song.artists.first.name,
                      highlight: widget.highlightText,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                      highlightStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.primaryContainer
                            .withValues(alpha: 0.2),
                      ),
                    )
                    : null,
            trailing: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: _onTap,
            ),
            onTap: _onTap,
          ),
        ),
      ),
    );
  }

  void _onTap() {
    context.pushNamed(
      'lyricDetails',
      pathParameters: {'id': widget.song.id.toString()},
    );
  }
}
