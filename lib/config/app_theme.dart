import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A collection of custom themes based on Material 3 design system
/// with color schemes inspired by the shadcn UI theme.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Returns the light theme with Material 3 design
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      fontFamily: GoogleFonts.inter().fontFamily,

      // Card theme
      cardTheme: CardTheme(
        color: _lightColorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: _lightColorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightColorScheme.surface,
        foregroundColor: _lightColorScheme.onSurface,
        elevation: 0,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: _lightColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: _lightColorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: _lightColorScheme.onPrimary,
          backgroundColor: _lightColorScheme.primary,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightColorScheme.primary,
          side: BorderSide(color: _lightColorScheme.outline),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: _lightColorScheme.primary,
          backgroundColor: _lightColorScheme.surface,
          minimumSize: const Size(64, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: _lightColorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: _lightColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _lightColorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightColorScheme.surface,
        indicatorColor: _lightColorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontFamily: GoogleFonts.inter().fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: _lightColorScheme.outlineVariant,
        thickness: 1,
      ),
    );
  }

  /// Returns the dark theme with Material 3 design
  static ThemeData get darkTheme {
    // Similar implementation for dark theme
    // Would be implemented based on the .dark classes from the provided CSS
    return ThemeData(
      // Implement dark theme here based on the dark class CSS values
    );
  }

  /// Light color scheme based on shadcn theme values
  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Core colors from shadcn
    primary: _convertFromOklch(0.4529, 0.14, 62.89), // --primary
    onPrimary: Colors.white, // --primary-foreground
    secondary: _convertFromOklch(0.6157, 0.2, 41.51), // --secondary
    onSecondary: Colors.white, // --secondary-foreground
    tertiary: _convertFromOklch(0.7216, 0.12, 60), // --accent
    onTertiary: _convertFromOklch(0.1529, 0.08, 61.2), // --foreground
    surface: Colors.white, // --card
    onSurface: Colors.black, // --card-foreground
    // Supporting colors
    error: _convertFromOklch(0.4647, 0.19, 3.2), // --destructive
    onError: Colors.white, // --destructive-foreground
    // Additional material colors derived from the theme
    surfaceContainerHighest: _convertFromOklch(0.9686, 0.01, 210), // --muted
    onSurfaceVariant: _convertFromOklch(0.2, 0.02, 210), // --muted-foreground
    outline: _convertFromOklch(0.93, 0.01, 40), // --border
    outlineVariant: _convertFromOklch(0.93, 0.01, 40).withValues(alpha: 0.5),

    // Popover colors
    inverseSurface: _convertFromOklch(0.99, 0.03, 40), // --popover
    onInverseSurface: _convertFromOklch(0, 0, 40), // --popover-foreground
    // Shadcn specific colors not directly mapped to Material
    inversePrimary: _convertFromOklch(0.73, 0.15, 40), // --ring
  );

  /// Text theme using Inter font family
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  /// Helper function to convert OKLCH values to Color
  /// This is a simplified conversion since Flutter doesn't natively support OKLCH
  /// For production, consider using a proper color space conversion package
  static Color _convertFromOklch(double l, double c, double h) {
    // This is a very simplified conversion
    // In production, use a proper color conversion package

    // Convert to HSL (simplified approximation)
    final double lightness = l * 100;
    final double chroma = c * 100;
    final double hue = h % 360;

    // Simple mapping to HSL then to RGB
    // This is not accurate but gives an approximation for the example
    return HSLColor.fromAHSL(
      1.0,
      hue,
      chroma / 100, // Normalize chroma as saturation
      lightness / 100, // Normalize lightness
    ).toColor();
  }
}
