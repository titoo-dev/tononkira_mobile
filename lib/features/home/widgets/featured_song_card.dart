import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tononkira_mobile/models/models.dart';

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
            color: colorScheme.outline.withValues(alpha: 0.2),
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
                    Colors.black.withValues(alpha: 0.85), // Darker at bottom
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
                      color: Colors.black.withValues(alpha: 0.3),
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
          colors: [containerColor, containerColor.withValues(alpha: 0.7)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle pattern overlay
          RepaintBoundary(
            child: CustomPaint(
              painter: WavePatternPainter(
                color: primaryColor.withValues(alpha: 0.15),
                waveCount: 3 + (nameHash % 3),
              ),
              size: Size.infinite,
            ),
          ),

          // Music icon with modern styling
          Icon(
            Icons.music_note_rounded,
            size: 60,
            color: primaryColor.withValues(alpha: 0.4),
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
