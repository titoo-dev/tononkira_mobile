import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Beautiful bottom sheet showing app information and developer contacts
class AppInfoBottomSheet extends StatelessWidget {
  const AppInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 36, left: 24, right: 24),
      // Use at least 60% of screen height
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // App Logo and Info
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.primaryContainer,
                  image: DecorationImage(
                    image: AssetImage('assets/images/tononkira_logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tononkira',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // App Description
          Text(
            'About App',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tononkira is a lyrics app for Malagasy songs. Find and discover lyrics from your favorite Malagasy artists.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Check for Updates button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Show checking for updates message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checking for updates...'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );

                // Simulate checking process with a delay
                Future.delayed(const Duration(seconds: 3), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your app is up to date!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                });
              },
              icon: const Icon(Icons.system_update_outlined),
              label: const Text('Check for Updates'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Developer Contact
          Text(
            'Developer Contact',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Social links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // LinkedIn
              _ContactButton(
                icon: LineIcons.linkedinIn,
                label: 'LinkedIn',
                color: const Color(0xFF0077B5),
                onTap: () => openLinkedIn(context),
              ),

              // GitHub
              _ContactButton(
                icon: LineIcons.github,
                label: 'GitHub',
                color: const Color(0xFF333333),
                onTap: () => openGitHub(context),
              ),

              // Email
              _ContactButton(
                icon: LineIcons.envelope,
                label: 'Email',
                color: colorScheme.tertiary,
                onTap: () => openEmail(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Copyright
          Center(
            child: Text(
              '© ${DateTime.now().year} Tononkira',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void openLinkedIn(BuildContext context) async {
    final Uri url = Uri.parse('https://linkedin.com/in/titosy-manankasina');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        // Show error message if the URL cannot be opened
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open LinkedIn profile')),
        );
      }
    }
  }

  void openGitHub(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/titoo-dev');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        // Show error message if the URL cannot be opened
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open GitHub profile')),
        );
      }
    }
  }

  void openEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'dev.titosy@gmail.com',
      queryParameters: {'subject': 'Regarding Tononkira App'},
    );

    if (!await launchUrl(emailUri)) {
      if (context.mounted) {
        // Show error message if email client cannot be opened
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }
}

/// Contact button with icon and label for developer links
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
