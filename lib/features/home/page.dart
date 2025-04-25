import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
import 'package:tononkira_mobile/models/models.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingSearchButton = false;

  late Future<Map<String, List<Song>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _dataFuture = _loadData();
  }

  Future<Map<String, List<Song>>> _loadData() async {
    final db = await DatabaseHelper.instance.database;

    // Load songs with artists (featured songs - limit to 5)
    final featuredSongsData = await db.rawQuery('''
      SELECT s.id, s.title, s.slug, s.views, s.createdAt, s.updatedAt 
      FROM Song s 
      ORDER BY s.views DESC LIMIT 5
    ''');

    // Load recent songs (limit to 10)
    final recentSongsData = await db.rawQuery('''
      SELECT s.id, s.title, s.slug, s.views, s.createdAt, s.updatedAt 
      FROM Song s 
      ORDER BY s.createdAt DESC LIMIT 10
    ''');

    final featuredSongs = await DatabaseHelper.instance.transformSongsData(
      featuredSongsData,
    );
    final recentSongs = await DatabaseHelper.instance.transformSongsData(
      recentSongsData,
    );

    return {'featured': featuredSongs, 'recent': recentSongs};
  }

  void _onScroll() {
    const threshold = 150.0;
    if (_scrollController.offset > threshold && !_showFloatingSearchButton) {
      setState(() {
        _showFloatingSearchButton = true;
      });
    } else if (_scrollController.offset <= threshold &&
        _showFloatingSearchButton) {
      setState(() {
        _showFloatingSearchButton = false;
      });
    }
  }

  void _openSearch() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton:
          _showFloatingSearchButton
              ? FloatingSearchButton(onPressed: _openSearch)
              : null,
      body: SafeArea(
        child: FutureBuilder<Map<String, List<Song>>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Failed to load data. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No data available. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }

            final featuredSongs = snapshot.data!['featured'] ?? [];
            final recentSongs = snapshot.data!['recent'] ?? [];

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _dataFuture = _loadData();
                });
                await _dataFuture;
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeAppBar(
                      title: 'Tononkira',
                      searchController: _searchController,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child:
                        featuredSongs.isEmpty
                            ? const SizedBox(height: 16)
                            : FeaturedSection(featuredSongs: featuredSongs),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: SectionHeader(title: "Recent Lyrics"),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  recentSongs.isEmpty
                      ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No lyrics found. Try importing data first.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                      : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final song = recentSongs[index];
                          return RecentLyricItem(song: song);
                        }, childCount: recentSongs.length),
                      ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Floating search button with animation
class FloatingSearchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingSearchButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: const Offset(0, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: onPressed,
          tooltip: 'Search lyrics',
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}

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

/// Info button that shows app details and developer contact
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppInfoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer.withOpacity(0.8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.info_outline_rounded,
          color: colorScheme.onPrimaryContainer,
        ),
        tooltip: 'App Information',
        onPressed: () => _showInfoBottomSheet(context),
      ),
    );
  }
}

/// Beautiful bottom sheet showing app information and developer contacts
class AppInfoBottomSheet extends StatelessWidget {
  const AppInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 36, left: 24, right: 24),
      // Use at least 60% of screen height
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // App Logo and Info
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.primaryContainer,
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tononkira',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // App Description
          Text(
            'About App',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tononkira is a lyrics app for Malagasy songs. Find and discover lyrics from your favorite Malagasy artists.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Check for Updates button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Checking for updates...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.system_update_outlined),
              label: const Text('Check for Updates'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Developer Contact
          Text(
            'Developer Contact',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Social links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // LinkedIn
              _ContactButton(
                icon: Icons.person_outline_rounded,
                label: 'LinkedIn',
                color: const Color(0xFF0077B5),
                onTap: () {},
              ),

              // GitHub
              _ContactButton(
                icon: Icons.code_rounded,
                label: 'GitHub',
                color: const Color(0xFF333333),
                onTap: () {},
              ),

              // Email
              _ContactButton(
                icon: Icons.email_outlined,
                label: 'Email',
                color: colorScheme.tertiary,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Copyright
          Center(
            child: Text(
              '© ${DateTime.now().year} Tononkira',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contact button with icon and label for developer links
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
    if (!_focusNode.hasFocus) {
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
                    controller: widget.controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for lyrics, artists...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
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
        child: Center(child: CircularProgressIndicator()),
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
                color: colorScheme.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Type at least 2 characters to search',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
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
                color: colorScheme.primary.withOpacity(0.3),
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
            side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
              highlightStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
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
                            .withOpacity(0.2),
                      ),
                    )
                    : null,
            trailing: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {},
            ),
            onTap: () {
              // Navigate to song details page
            },
          ),
        ),
      ),
    );
  }
}

class HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle style;
  final TextStyle highlightStyle;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    required this.style,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty ||
        !text.toLowerCase().contains(highlight.toLowerCase())) {
      return Text(text, style: style);
    }

    final matches = RegExp(highlight, caseSensitive: false).allMatches(text);
    final TextSpan span = TextSpan(
      children: _buildTextSpans(text, matches),
      style: style,
    );

    return RichText(text: span, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  List<TextSpan> _buildTextSpans(String text, Iterable<RegExpMatch> matches) {
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add text before match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      // Add highlighted text
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: highlightStyle,
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text after last match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
  }
}

/// Featured section with header and horizontal scrollable song cards
class FeaturedSection extends StatelessWidget {
  final List<Song> featuredSongs;

  const FeaturedSection({super.key, required this.featuredSongs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: SectionHeaderWithAction(
            title: "Featured Lyrics",
            actionLabel: "See All",
            onActionPressed: () {},
          ),
        ),

        // Featured Lyrics Cards
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: featuredSongs.length,
            itemBuilder: (context, index) {
              return FeaturedSongCard(song: featuredSongs[index]);
            },
          ),
        ),
      ],
    );
  }
}

/// Section header with title and optional action button
class SectionHeaderWithAction extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;

  const SectionHeaderWithAction({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onActionPressed,
          child: Text(
            actionLabel,
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

/// Simple section header with only title
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Featured song card with material design styling and improved readability
class FeaturedSongCard extends StatelessWidget {
  final Song song;

  const FeaturedSongCard({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1, // Slight elevation for better depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artist Image or Placeholder
            song.artists.isNotEmpty && song.artists.first.imageUrl != null
                ? ArtistImage(imageUrl: song.artists.first.imageUrl)
                : ArtistPlaceholder(
                  artistName:
                      song.artists.isNotEmpty
                          ? song.artists.first.name
                          : "Unknown",
                ),

            // Enhanced Gradient Overlay for better readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85), // Darker at bottom
                  ],
                ),
              ),
            ),

            // Song Info with improved contrast
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Song title with text shadow for better readability
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black,
                          offset: Offset(0.5, 0.5),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (song.artists.isNotEmpty)
                    Text(
                      song.artists.first.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black,
                            offset: Offset(0.5, 0.5),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Container with slight opacity for view count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.remove_red_eye,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${song.views ?? 0}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern artist placeholder with dynamic Material 3 styling
class ArtistPlaceholder extends StatelessWidget {
  final String artistName;

  const ArtistPlaceholder({super.key, required this.artistName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Create a deterministic but varied color based on artist name
    final int nameHash = artistName.hashCode;

    // Use colors from the Material 3 color scheme for cohesive design
    final List<Color> primaryColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];

    final List<Color> containerColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    // Select colors based on the hash
    final primaryColor = primaryColors[nameHash % primaryColors.length];
    final containerColor = containerColors[nameHash % containerColors.length];

    return Container(
      decoration: BoxDecoration(
        // Material 3 inspired gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [containerColor, containerColor.withOpacity(0.7)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle pattern overlay
          RepaintBoundary(
            child: CustomPaint(
              painter: WavePatternPainter(
                color: primaryColor.withOpacity(0.15),
                waveCount: 3 + (nameHash % 3),
              ),
              size: Size.infinite,
            ),
          ),

          // Music icon with modern styling
          Icon(
            Icons.music_note_rounded,
            size: 60,
            color: primaryColor.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for Material 3 inspired wave pattern
class WavePatternPainter extends CustomPainter {
  final Color color;
  final int waveCount;

  WavePatternPainter({required this.color, this.waveCount = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();

    // Calculate wave parameters based on size
    final waveHeight = size.height / (waveCount * 2);
    final horizontalStep = size.width / 20;

    for (int i = 0; i < waveCount; i++) {
      final startY =
          (i * size.height / waveCount) + (size.height / (waveCount * 2));

      path.moveTo(0, startY);

      // Create smooth wave pattern
      for (double x = 0; x < size.width; x += horizontalStep) {
        final progress = x / size.width;
        final waveAmplitude = waveHeight * (1 - (i / waveCount) * 0.5);
        final y = startY + sin(progress * 2 * pi) * waveAmplitude;

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
      path.reset();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Artist image with fallback
class ArtistImage extends StatelessWidget {
  final String? imageUrl;

  const ArtistImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackContainer(colorScheme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallbackContainer(colorScheme);
        },
      );
    } else {
      return _buildFallbackContainer(colorScheme);
    }
  }

  Widget _buildFallbackContainer(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(Icons.music_note, color: colorScheme.onPrimaryContainer),
    );
  }
}

/// Recent lyric item in a list
class RecentLyricItem extends StatelessWidget {
  final Song song;

  const RecentLyricItem({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 56,
            height: 56,
            child:
                song.artists.isNotEmpty && song.artists.first.imageUrl != null
                    ? ArtistImage(imageUrl: song.artists.first.imageUrl)
                    : ArtistPlaceholder(
                      artistName:
                          song.artists.isNotEmpty
                              ? song.artists.first.name
                              : "Unknown",
                    ),
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            song.artists.isNotEmpty ? Text(song.artists.first.name) : null,
        trailing: IconButton(
          icon: Icon(Icons.favorite_outline, color: colorScheme.primary),
          onPressed: () {},
          tooltip: 'Add to favorites',
        ),
        onTap: () {},
      ),
    );
  }
}

/// Bottom navigation bar for the app
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
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.music_note_outlined),
          selectedIcon: Icon(Icons.music_note),
          label: 'Lyrics',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
      ],
    );
  }
}
