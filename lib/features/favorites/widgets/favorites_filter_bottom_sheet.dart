import 'package:flutter/material.dart';

/// Bottom sheet for filtering favorite lyrics
class FavoritesFilterBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final ValueChanged<String> onFilterSelected;
  final String currentFilter;
  final VoidCallback onApplySelected;

  const FavoritesFilterBottomSheet({
    super.key,
    required this.scrollController,
    required this.onFilterSelected,
    required this.currentFilter,
    required this.onApplySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Sort Favorites', style: textTheme.titleLarge),
              ],
            ),
          ),

          const Divider(),

          // Filter options
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildFilterOption(
                  context,
                  'Recent',
                  'Most Recent',
                  Icons.access_time,
                ),
                _buildFilterOption(
                  context,
                  'Artist',
                  'By Artist Name',
                  Icons.person,
                ),
                _buildFilterOption(
                  context,
                  'Title',
                  'By Song Title',
                  Icons.sort_by_alpha,
                ),
                _buildFilterOption(
                  context,
                  'Popular',
                  'Most Popular',
                  Icons.trending_up,
                ),
              ],
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: onApplySelected,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentFilter == value;

    return Material(
      color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onFilterSelected(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
