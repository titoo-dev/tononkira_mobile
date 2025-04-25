import 'package:flutter/material.dart';
import 'package:tononkira_mobile/features/home/widgets/app_info_bottom_sheet.dart';

/// Info button that shows app details and developer contact
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppInfoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer.withValues(alpha: 0.8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.info_outline_rounded,
          color: colorScheme.onPrimaryContainer,
        ),
        tooltip: 'App Information',
        onPressed: () => _showInfoBottomSheet(context),
      ),
    );
  }
}
