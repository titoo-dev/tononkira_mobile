import 'package:flutter/material.dart';
import 'package:tononkira_mobile/features/home/widgets/featured_song_card.dart';
import 'package:tononkira_mobile/models/models.dart';

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
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
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
