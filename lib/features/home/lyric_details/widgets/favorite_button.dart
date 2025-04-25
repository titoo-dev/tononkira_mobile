import 'package:flutter/material.dart';
import 'package:tononkira_mobile/data/database_helper.dart';

/// Animated like button widget for song favorites
class FavoriteButton extends StatefulWidget {
  /// Song ID to toggle in favorites
  final int songId;

  /// Initial favorite state
  final bool initialLiked;

  /// Callback when favorite state changes
  final Function(bool) onLikeChanged;

  const FavoriteButton({
    super.key,
    required this.songId,
    required this.initialLiked,
    required this.onLikeChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late bool _isLiked;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialLiked;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'Favorites',
      where: 'songId = ?',
      whereArgs: [widget.songId],
    );
    if (mounted) {
      setState(() {
        _isLiked = result.isNotEmpty;
      });
      widget.onLikeChanged(_isLiked);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final db = await DatabaseHelper.instance.database;

      if (_isLiked) {
        // Remove from favorites
        await db.delete(
          'Favorites',
          where: 'songId = ?',
          whereArgs: [widget.songId],
        );
      } else {
        // Add to favorites
        await db.insert('Favorites', {
          'songId': widget.songId,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Play animation
        _animationController.forward(from: 0.0);
      }

      setState(() {
        _isLiked = !_isLiked;
      });

      // Notify parent
      widget.onLikeChanged(_isLiked);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon:
          _isProcessing
              ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
              : Icon(
                _isLiked ? Icons.favorite : Icons.favorite_outline,
                color: _isLiked ? colorScheme.error : colorScheme.primary,
              ),
      onPressed: _isProcessing ? null : _toggleFavorite,
      tooltip: _isLiked ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}
