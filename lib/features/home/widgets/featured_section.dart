import 'package:flutter/material.dart';
import 'package:tononkira_mobile/features/home/widgets/featured_song_card.dart';
import 'package:tononkira_mobile/models/models.dart';

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
        Opacity(
          opacity: 0,
          child: TextButton(
            onPressed: null,
            child: Text(
              actionLabel,
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
