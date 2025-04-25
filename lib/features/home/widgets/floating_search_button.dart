import 'package:flutter/material.dart';

/// Floating search button with animation
class FloatingSearchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingSearchButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: const Offset(0, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: onPressed,
          tooltip: 'Search lyrics',
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}
