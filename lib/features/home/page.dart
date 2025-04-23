import 'package:flutter/material.dart';
import 'package:tononkira_mobile/models/models.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Search
            SliverToBoxAdapter(
              child: Padding(
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
                        Container(
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Modern Animated Search Bar
                    _buildSearchBar(colorScheme),
                  ],
                ),
              ),
            ),

            // Featured Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Featured Lyrics",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "See All",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Lyrics Cards
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: _featuredSongs.length,
                  itemBuilder: (context, index) {
                    final song = _featuredSongs[index];
                    return _buildFeaturedSongCard(song, colorScheme);
                  },
                ),
              ),
            ),

            // Popular Artists Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  "Popular Artists",
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Artist Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildArtistChip(
                      "Mahaleo",
                      'https://i1.sndcdn.com/artworks-000147146077-a0h5gs-t500x500.jpg',
                      colorScheme,
                    ),
                    _buildArtistChip(
                      "Ambondrona",
                      'https://la1ere.francetvinfo.fr/image/ygcCMkxXTPdYXcsmZx2K_5xyfEU/600x400/outremer/2023/08/31/groupe-malgasy-64f06d75f1021368806331.jpg',
                      colorScheme,
                    ),
                    _buildArtistChip(
                      "Ny Ainga",
                      'https://www.matin.mg/wp-content/uploads/2016/07/ny-ainga-ok.jpg',
                      colorScheme,
                    ),
                    _buildArtistChip(
                      "The Dizzy Brains",
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJ_u7Edm2MGvnl7c3B5uJ9lfcx5lda332IRkOLEU-bmum1DygX87y0fXU8l4xOjk-477s&usqp=CAU',
                      colorScheme,
                    ),
                    _buildArtistChip(
                      "Bodo",
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTAC5LhdLol5Nia_KmfZk8shgweMwahUOPfA3MP84pTTAQec54kYfoRsf9J1dQcQeD9iwI&usqp=CAU',
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),

            // Recent Lyrics Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  "Recent Lyrics",
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Recent Lyrics List
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = _featuredSongs[index % _featuredSongs.length];
                return _buildRecentLyricItem(song, colorScheme);
              }, childCount: 10),
            ),

            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
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
      ),
    );
  }

  // Modern search bar with rounded edges following Material 3 design
  Widget _buildSearchBar(ColorScheme colorScheme) {
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
                controller: _searchController,
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

  // Featured song card with Material 3 styling
  Widget _buildFeaturedSongCard(Song song, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
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
            // Artist Image
            song.artists.isNotEmpty && song.artists.first.imageUrl != null
                ? Image.network(
                  song.artists.first.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.image_not_supported,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    );
                  },
                )
                : Container(
                  color: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.music_note,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colorScheme.inverseSurface.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Song Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  song.artists.isNotEmpty
                      ? Text(
                        song.artists.first.name,
                        style: TextStyle(
                          color: colorScheme.onInverseSurface.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        size: 14,
                        color: colorScheme.onInverseSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${song.views ?? 0}",
                        style: TextStyle(
                          color: colorScheme.onInverseSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Artist chip with circular image and name using theme's chip style
  Widget _buildArtistChip(
    String name,
    String imageUrl,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        avatar: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: colorScheme.primaryContainer,
        ),
        label: Text(name),
        labelStyle: TextStyle(fontWeight: FontWeight.w500),
        selected: false,
        onSelected: (bool selected) {},
      ),
    );
  }

  // Recent lyric item with Material 3 list tile design
  Widget _buildRecentLyricItem(Song song, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              song.artists.isNotEmpty && song.artists.first.imageUrl != null
                  ? Image.network(
                    song.artists.first.imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 56,
                        height: 56,
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.music_note,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      );
                    },
                  )
                  : Container(
                    width: 56,
                    height: 56,
                    color: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.music_note,
                      color: colorScheme.onPrimaryContainer,
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
