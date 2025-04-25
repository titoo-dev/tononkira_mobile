import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tononkira_mobile/config/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Find Lyrics Easily",
      description:
          "Search through thousands of song lyrics in Malagasy and other languages",
      illustration: "assets/illustrations/search_lyrics.png",
      backgroundColor: const Color(0xFFE8F3FF),
      iconData: Icons.search_rounded,
    ),
    OnboardingItem(
      title: "Save Your Favorites",
      description:
          "Create a personalized collection of your favorite songs and artists",
      illustration: "assets/illustrations/favorites.png",
      backgroundColor: const Color(0xFFFFF3E8),
      iconData: Icons.favorite_rounded,
    ),
    OnboardingItem(
      title: "Offline Access",
      description:
          "Access your saved lyrics even without an internet connection",
      illustration: "assets/illustrations/offline.png",
      backgroundColor: const Color(0xFFE8FFEA),
      iconData: Icons.offline_pin_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _goToNextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    GoRouter.of(context).go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLastPage = _currentPage == _onboardingItems.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top right corner
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _navigateToHome,
                  child: Text(
                    "Skip",
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = _onboardingItems[index];
                  return OnboardingPageContent(
                    item: item,
                    animation: _fadeAnimation,
                  );
                },
              ),
            ),

            // Page indicator and next button
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingItems.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: colorScheme.primary,
                      dotColor: colorScheme.primary.withValues(alpha: 0.2),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),

                  // Next or Get Started button
                  FilledButton(
                    onPressed: _goToNextPage,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isLastPage ? "Get Started" : "Next"),
                        const SizedBox(width: 8),
                        Icon(
                          isLastPage
                              ? Icons.celebration_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
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

/// Single onboarding page content
class OnboardingPageContent extends StatelessWidget {
  final OnboardingItem item;
  final Animation<double> animation;

  const OnboardingPageContent({
    super.key,
    required this.item,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration container with soft background
            Container(
              height: 280,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: item.backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dynamic background patterns
                  Positioned.fill(
                    child: OnboardingBackgroundPattern(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                    ),
                  ),

                  // Use actual illustration if available, otherwise fallback to icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        item.illustration != null
                            ? Image.asset(
                              item.illustration!,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildFallbackIcon(colorScheme),
                            )
                            : _buildFallbackIcon(colorScheme),
                  ),
                ],
              ),
            ),

            // Title with emphasis on the first word
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                children: _getStyledTitle(item.title, colorScheme),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(ColorScheme colorScheme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(item.iconData, size: 60, color: colorScheme.primary),
    );
  }

  List<TextSpan> _getStyledTitle(String title, ColorScheme colorScheme) {
    final words = title.split(' ');
    if (words.isEmpty) return [TextSpan(text: title)];

    return [
      TextSpan(
        text: "${words.first} ",
        style: TextStyle(color: colorScheme.primary),
      ),
      TextSpan(text: words.length > 1 ? words.sublist(1).join(' ') : ""),
    ];
  }
}

/// Custom painter for background patterns
class OnboardingBackgroundPattern extends StatelessWidget {
  final Color color;

  const OnboardingBackgroundPattern({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PatternPainter(color: color),
      size: Size.infinite,
    );
  }
}

class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw circles of varying sizes
    for (int i = 0; i < 5; i++) {
      final radius = (i + 1) * 20.0;
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint,
      );
    }

    // Draw some dots
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = size.width * (i % 5) / 5;
      final y = size.height * (i ~/ 5) / 4;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Draw some lines
    for (int i = 0; i < 3; i++) {
      final path = Path();
      path.moveTo(0, size.height * 0.3 + i * 40);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2 + i * 30,
        size.width,
        size.height * 0.4 + i * 20,
      );
      canvas.drawPath(path, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Data class for onboarding items
class OnboardingItem {
  final String title;
  final String description;
  final String? illustration;
  final Color backgroundColor;
  final IconData iconData;

  OnboardingItem({
    required this.title,
    required this.description,
    this.illustration,
    required this.backgroundColor,
    required this.iconData,
  });
}
