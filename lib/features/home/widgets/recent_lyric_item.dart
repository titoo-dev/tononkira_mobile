import 'package:flutter/material.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
import 'package:tononkira_mobile/features/home/widgets/featured_song_card.dart';
import 'package:tononkira_mobile/models/models.dart';

/// Recent lyric item in a list
class RecentLyricItem extends StatefulWidget {
  final Song song;

  const RecentLyricItem({super.key, required this.song});

  @override
  State<RecentLyricItem> createState() => _RecentLyricItemState();
}

class _RecentLyricItemState extends State<RecentLyricItem> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'Favorites',
      where: 'songId = ?',
      whereArgs: [widget.song.id],
    );
    if (mounted) {
      setState(() {
        _isFavorite = result.isNotEmpty;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final db = await DatabaseHelper.instance.database;

    if (_isFavorite) {
      // Remove from favorites
      await db.delete(
        'Favorites',
        where: 'songId = ?',
        whereArgs: [widget.song.id],
      );
    } else {
      // Add to favorites
      await db.insert('Favorites', {
        'songId': widget.song.id,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

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
                widget.song.artists.isNotEmpty &&
                        widget.song.artists.first.imageUrl != null
                    ? ArtistImage(imageUrl: widget.song.artists.first.imageUrl)
                    : ArtistPlaceholder(
                      artistName:
                          widget.song.artists.isNotEmpty
                              ? widget.song.artists.first.name
                              : "Unknown",
                    ),
          ),
        ),
        title: Text(
          widget.song.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            widget.song.artists.isNotEmpty
                ? Text(widget.song.artists.first.name)
                : null,
        trailing: IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_outline,
            color: _isFavorite ? colorScheme.error : colorScheme.primary,
          ),
          onPressed: _toggleFavorite,
          tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
        onTap: () {},
      ),
    );
  }
}
