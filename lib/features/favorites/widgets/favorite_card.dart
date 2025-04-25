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

                    const SizedBox(height: 8),

                    // Stats row
                    Row(
                      children: [
                        // View count
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
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

                        const SizedBox(width: 16),

                        // Added date
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(song.createdAt),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
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

                  const SizedBox(height: 8),

                  // Quick actions menu
                  IconButton(
                    onPressed: () {
                      _showQuickActionsMenu(context);
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    tooltip: 'More options',
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

  // Format date in a readable format
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Show quick actions menu for the lyric
  void _showQuickActionsMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.share, color: colorScheme.primary),
                  title: const Text('Share lyrics'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement sharing functionality
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.download_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Download for offline'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement download functionality
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit_note, color: colorScheme.primary),
                  title: const Text('Add to collection'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement collection functionality
                  },
                ),
              ],
            ),
          ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
