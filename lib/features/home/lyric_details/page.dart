import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
import 'package:tononkira_mobile/features/home/lyric_details/widgets/favorite_button.dart';
import 'package:tononkira_mobile/models/lyrics_analysis.dart';
import 'package:tononkira_mobile/models/models.dart';
import 'package:tononkira_mobile/shared/loader.dart';

/// A beautifully designed lyric details page showing song lyrics with artist information
/// following Material 3 design principles
class LyricDetailsPage extends StatefulWidget {
  /// The song to display details for
  final int songId;

  const LyricDetailsPage({super.key, required this.songId});

  @override
  State<LyricDetailsPage> createState() => _LyricDetailsPageState();
}

// Extension to add capitalize method to String
extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
  }
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
  // Song data
  Song? _song;
  // Lyric content
  LyricsAnalysis? _lyricContent;
  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadSongData();
  }

  Future<void> _loadSongData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await DatabaseHelper.instance.database;

      // Get song data
      final songData = await db.query(
        DatabaseHelper.kDbSongTableName,
        where: 'id = ?',
        whereArgs: [widget.songId],
      );

      if (songData.isNotEmpty) {
        // Transform song data with artists
        final songs = await DatabaseHelper.instance.transformSongsData(
          songData,
        );

        if (songs.isNotEmpty) {
          _song = songs.first;

          // Get lyric data using the lyricId from the song
          final lyricData = await db.query(
            DatabaseHelper.kDbLyricTableName,
            where: 'id = ?',
            whereArgs: [songData.first['lyricId']],
          );

          if (lyricData.isNotEmpty) {
            final Map<String, dynamic> jsonData = json.decode(
              lyricData.first['content'] as String,
            );
            _lyricContent = LyricsAnalysis.fromJson(jsonData);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading song data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Loader()),
      );
    }

    if (_song == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Song Not Found'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Song with ID ${widget.songId} not found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

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
            color: colorScheme.primaryContainer.withOpacity(0.8),
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
          _song!.title,
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
        FavoriteButton(
          songId: _song!.id,
          initialLiked: _isLiked,
          onLikeChanged: (liked) {
            setState(() {
              _isLiked = liked;
            });
          },
        ),
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
              _song!.artists.isNotEmpty
                  ? _song!.artists.first.name
                  : 'Unknown Artist',
          imageUrl:
              _song!.artists.isNotEmpty ? _song!.artists.first.imageUrl : null,
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
        _song!.artists.isEmpty
            ? 'Unknown Artist'
            : _song!.artists.map((a) => a.name).join(', ');

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

          const SizedBox(height: 10),

          // View count and date info
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(_song!.createdAt),
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

    if (_lyricContent == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.lyrics_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Lyrics not available for this song',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in _lyricContent!.content)
            _buildLyricsSection(section, context),
        ],
      ),
    );
  }

  Widget _buildLyricsSection(LyricsSection section, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Format section title properly
    String title = section.type.capitalize();
    if (section.verseNumber != null) {
      title = '$title ${section.verseNumber}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header (Verse, Chorus, etc.)
        // Padding(
        //   padding: const EdgeInsets.only(top: 16, bottom: 8),
        //   child: Text(
        //     title,
        //     style: textTheme.titleMedium?.copyWith(
        //       color: colorScheme.tertiary,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        // ),

        // Section content (actual lyrics)
        ...section.content.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: _fontSize,
                height: 1.5,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
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
      '${_song!.title} by ${_song!.artists.map((a) => a.name).join(', ')}\n\n$_lyricContent',
      subject: 'Check out these lyrics from Tononkira',
    );
  }

  // Copy lyrics to clipboard
  void _copyLyricsToClipboard() {
    Clipboard.setData(ClipboardData(text: _lyricContent.toString()));

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
                colors: [Colors.black.withOpacity(0.3), Colors.transparent],
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
          colors: [containerColor, containerColor.withOpacity(0.7)],
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
              color: primaryColor.withOpacity(0.3),
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
                        color: primaryColor.withOpacity(0.5),
                      ),
                    )
                    : Icon(
                      Icons.music_note_rounded,
                      size: 72,
                      color: primaryColor.withOpacity(0.5),
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
