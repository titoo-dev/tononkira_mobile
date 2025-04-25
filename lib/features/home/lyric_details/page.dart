import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tononkira_mobile/models/models.dart';
import 'package:share_plus/share_plus.dart';

/// A beautifully designed lyric details page showing song lyrics with artist information
/// following Material 3 design principles
class LyricDetailsPage extends StatefulWidget {
  /// The song to display details for
  final Song song;

  const LyricDetailsPage({super.key, required this.song});

  @override
  State<LyricDetailsPage> createState() => _LyricDetailsPageState();
}

class _LyricDetailsPageState extends State<LyricDetailsPage>
    with SingleTickerProviderStateMixin {
  // Controller for expandable app bar
  late ScrollController _scrollController;
  // Flag to show/hide floating action button
  bool _showFab = false;
  // Controller for lyric font size
  late double _fontSize = 16.0;
  // Animation controller for the like button
  late AnimationController _likeAnimationController;
  // State for liked status
  bool _isLiked = false;

  // Sample lyric content for preview
  final String _sampleLyric = '''
Fitia tsy miova
Fitia mandrakizay
Izay rehetra anananareo
Dia avy aminao

Manantena anao
Mandrakizay
Fitia tsy miova
Mandrakizay o...

Ho tano ny tananao izahay
Ho sotra ny fitiavanao izahay
Ho sambatra aminao izahay
Hiaraka aminao mandrakizay
  ''';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  // Show/hide FAB based on scroll position
  void _onScroll() {
    final showFab = _scrollController.offset > 150;
    if (showFab != _showFab) {
      setState(() {
        _showFab = showFab;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Floating text size adjustment button
      floatingActionButton: _showFab ? _buildFloatingActionButton() : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Expandable app bar with song info
          _buildSliverAppBar(context),

          // Song metadata
          SliverToBoxAdapter(child: _buildSongInfo(context)),

          // Lyric content
          SliverToBoxAdapter(child: _buildLyricContent(context)),
        ],
      ),
    );
  }

  // Beautiful expandable app bar with song and artist information
  Widget _buildSliverAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverAppBar.large(
      pinned: true,
      expandedHeight: 200.0,
      backgroundColor: colorScheme.surface,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.song.title,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: _buildAppBarBackground(),
      ),
      actions: [
        // Like button with animation
        _buildLikeButton(),
        // Share button
        IconButton(
          icon: Icon(Icons.share_rounded, color: colorScheme.onSurfaceVariant),
          onPressed: () => _shareContent(),
          tooltip: 'Share lyrics',
        ),
        // More options menu
        _buildMoreMenu(),
      ],
    );
  }

  // Beautiful gradient background for app bar
  Widget _buildAppBarBackground() {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Artist cover or placeholder
        ArtistCover(
          artistName:
              widget.song.artists.isNotEmpty
                  ? widget.song.artists.first.name
                  : 'Unknown Artist',
        ),

        // Gradient overlay for better text readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  colorScheme.surface.withValues(alpha: 0.5),
                  colorScheme.surface.withValues(alpha: 0.7),
                  colorScheme.surface,
                ],
                stops: const [0.0, 0.6, 0.8, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Animated like button
  Widget _buildLikeButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _likeAnimationController,
      builder: (context, child) {
        final scale = 1.0 + _likeAnimationController.value * 0.4;

        return IconButton(
          icon: Transform.scale(
            scale: scale,
            child: Icon(
              _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isLiked ? Colors.redAccent : colorScheme.onSurfaceVariant,
            ),
          ),
          onPressed: () {
            setState(() {
              _isLiked = !_isLiked;
              if (_isLiked) {
                _likeAnimationController.forward(from: 0.0);
              }
            });
          },
          tooltip: _isLiked ? 'Remove from favorites' : 'Add to favorites',
        );
      },
    );
  }

  // More options menu button
  Widget _buildMoreMenu() {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  Icon(Icons.content_copy, size: 20),
                  SizedBox(width: 12),
                  Text('Copy lyrics'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, size: 20),
                  SizedBox(width: 12),
                  Text('Report issue'),
                ],
              ),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'copy':
            _copyLyricsToClipboard();
            break;
          case 'report':
            _showReportDialog();
            break;
        }
      },
    );
  }

  // Song metadata section
  Widget _buildSongInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String artistNames =
        widget.song.artists.isEmpty
            ? 'Unknown Artist'
            : widget.song.artists.map((a) => a.name).join(', ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artist names
          Row(
            children: [
              Icon(Icons.person_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  artistNames,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // View count and date info
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 18,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatViews(widget.song.views ?? 0)} views',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(widget.song.createdAt),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const Divider(height: 32),
        ],
      ),
    );
  }

  // Lyric content with proper formatting and style
  Widget _buildLyricContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      child: Text(
        _sampleLyric,
        style: textTheme.bodyLarge?.copyWith(
          fontSize: _fontSize,
          height: 1.8,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // Floating action button with text size options
  Widget _buildFloatingActionButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () => _showTextSizeDialog(),
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      label: const Text('Text Size'),
      icon: const Icon(Icons.text_fields_rounded),
    );
  }

  // Show dialog to adjust text size
  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Adjust Text Size'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Move the slider to adjust text size'),
                    const SizedBox(height: 16),
                    Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 28.0,
                      divisions: 8,
                      label: _fontSize.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });

                        // Also update parent state
                        this.setState(() {});
                      },
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // Share lyrics content
  void _shareContent() {
    Share.share(
      '${widget.song.title} by ${widget.song.artists.map((a) => a.name).join(', ')}\n\n$_sampleLyric',
      subject: 'Check out these lyrics from Tononkira',
    );
  }

  // Copy lyrics to clipboard
  void _copyLyricsToClipboard() {
    Clipboard.setData(ClipboardData(text: _sampleLyric));

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lyrics copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
      ),
    );
  }

  // Show report issue dialog
  void _showReportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Issue'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What issue would you like to report?'),
                SizedBox(height: 16),
                ReportIssueOption(
                  icon: Icons.text_format,
                  title: 'Incorrect lyrics',
                ),
                ReportIssueOption(
                  icon: Icons.people,
                  title: 'Wrong artist information',
                ),
                ReportIssueOption(icon: Icons.title, title: 'Wrong song title'),
                ReportIssueOption(
                  icon: Icons.warning_rounded,
                  title: 'Inappropriate content',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your report'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }

  // Format view count
  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  // Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}

/// Beautiful artist cover with dynamic colors and patterns
class ArtistCover extends StatelessWidget {
  final String artistName;
  final String? imageUrl;

  const ArtistCover({super.key, required this.artistName, this.imageUrl});

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

    if (imageUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    _buildPatternBackground(primaryColor, containerColor),
          ),
          // Add color overlay for better text contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      );
    }

    return _buildPatternBackground(primaryColor, containerColor);
  }

  /// Creates a beautiful patterned background when no image is available
  Widget _buildPatternBackground(Color primaryColor, Color containerColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [containerColor, containerColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Wave pattern decoration
          CustomPaint(
            painter: WavePatternPainter(
              color: primaryColor.withValues(alpha: 0.3),
              waveCount: 5,
            ),
          ),

          // Artist initials or music icon
          Center(
            child:
                artistName.isNotEmpty
                    ? Text(
                      artistName.characters.first.toUpperCase(),
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: primaryColor.withValues(alpha: 0.5),
                      ),
                    )
                    : Icon(
                      Icons.music_note_rounded,
                      size: 72,
                      color: primaryColor.withValues(alpha: 0.5),
                    ),
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
        final y = startY + sin(progress * 2 * 3.14159) * waveAmplitude;

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

/// Report issue option in the report dialog
class ReportIssueOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const ReportIssueOption({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
      ),
    );
  }
}
