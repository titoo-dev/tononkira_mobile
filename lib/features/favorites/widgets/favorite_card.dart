import 'package:flutter/material.dart';
import 'package:tononkira_mobile/models/models.dart';

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
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
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
                      backgroundColor: colorScheme.primaryContainer.withValues(
                        alpha: 0.4,
                      ),
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
