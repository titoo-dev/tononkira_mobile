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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/images/tononkira_logo.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: IconButton(
        icon: Icon(null),
        tooltip: 'App Information',
        onPressed: () => _showInfoBottomSheet(context),
      ),
    );
  }
}
