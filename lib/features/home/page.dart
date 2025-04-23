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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        // Profile Icon Button
                        IconButton(
                          icon: const CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              "https://source.unsplash.com/random/100x100/?person",
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Modern Animated Search Bar
                    _buildSearchBar(),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text("See All")),
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
                    return _buildFeaturedSongCard(song);
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                      "https://source.unsplash.com/random/100x100/?artist,1",
                    ),
                    _buildArtistChip(
                      "Ambondrona",
                      "https://source.unsplash.com/random/100x100/?artist,2",
                    ),
                    _buildArtistChip(
                      "Ny Ainga",
                      "https://source.unsplash.com/random/100x100/?artist,3",
                    ),
                    _buildArtistChip(
                      "The Dizzy Brains",
                      "https://source.unsplash.com/random/100x100/?artist,4",
                    ),
                    _buildArtistChip(
                      "Bodo",
                      "https://source.unsplash.com/random/100x100/?artist,5",
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Recent Lyrics List
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = _featuredSongs[index % _featuredSongs.length];
                return _buildRecentLyricItem(song);
              }, childCount: 10),
            ),

            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: NavigationBar(
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
        selectedIndex: 0,
        onDestinationSelected: (index) {},
      ),
    );
  }

  // Modern animated search bar with rounded edges and subtle shadow
  Widget _buildSearchBar() {
    return Hero(
      tag: 'searchBar',
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for lyrics, artists...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.mic,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Featured song card with gradient overlay and artist image
  Widget _buildFeaturedSongCard(Song song) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artist Image
            song.artists.isNotEmpty && song.artists.first.imageUrl != null
                ? Image.network(song.artists.first.imageUrl!, fit: BoxFit.cover)
                : Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                    style: const TextStyle(
                      color: Colors.white,
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
                          color: Colors.white.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${song.views ?? 0}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
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

  // Artist chip with circular image and name
  Widget _buildArtistChip(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Chip(
        avatar: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
        label: Text(name),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  // Recent lyric item with list tile design
  Widget _buildRecentLyricItem(Song song) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            song.artists.isNotEmpty && song.artists.first.imageUrl != null
                ? Image.network(
                  song.artists.first.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                )
                : Container(
                  width: 56,
                  height: 56,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.music_note,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: song.artists.isNotEmpty ? Text(song.artists.first.name) : null,
      trailing: IconButton(
        icon: Icon(
          Icons.favorite_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {},
      ),
      onTap: () {},
    );
  }
}
