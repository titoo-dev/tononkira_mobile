import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tononkira_mobile/models/models.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  // Sample data for demonstration
  final List<Song> _featuredSongs = [
    Song(
      id: 1,
      title: "Veloma",
      slug: "veloma",
      views: 1245,
      createdAt: DateTime.now(),
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
      createdAt: DateTime.now(),
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
      createdAt: DateTime.now(),
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
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Search
            SliverToBoxAdapter(
              child: HomeAppBar(
                title: 'Tononkira',
                searchController: _searchController,
              ),
            ),

            // Featured Section
            SliverToBoxAdapter(
              child: FeaturedSection(featuredSongs: _featuredSongs),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Recent Lyrics Section Header
            SliverToBoxAdapter(child: SectionHeader(title: "Recent Lyrics")),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Recent Lyrics List
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = _featuredSongs[index % _featuredSongs.length];
                return RecentLyricItem(song: song);
              }, childCount: 10),
            ),

            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

/// App bar component with title and search functionality
class HomeAppBar extends StatelessWidget {
  final String title;
  final TextEditingController searchController;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.searchController,
  });

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
                  title,
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
          SearchBar(controller: searchController),
        ],
      ),
    );
  }
}

/// Profile button with circular avatar and border
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: IconButton(
        icon: const CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(
            "https://source.unsplash.com/random/100x100/?person",
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}

/// Modern search bar with rounded edges following Material 3 design
class SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const SearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
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
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search for lyrics, artists...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.mic, color: colorScheme.primary),
              onPressed: () {},
              tooltip: 'Voice search',
            ),
          ],
        ),
      ),
    );
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
            // Artist Placeholder instead of image
            ArtistPlaceholder(
              artistName:
                  song.artists.isNotEmpty ? song.artists.first.name : "Unknown",
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
                      color:
                          Colors
                              .white, // White is more readable on dark backgrounds
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
                        color: Colors.white, // Consistent white for readability
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 56,
            height: 56,
            child: ArtistImage(
              imageUrl:
                  song.artists.isNotEmpty ? song.artists.first.imageUrl : null,
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
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
