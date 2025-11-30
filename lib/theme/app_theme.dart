import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension CustomColorScheme on ColorScheme {
  // Brand Colors
  Color get primary => const Color(0xFF2FD1C5);
  Color get secondary => const Color(0xFF00394C);
  Color get tertiary => const Color(0xFF585A66);
  Color get alternate => const Color(0xFFE4EDFF);

  // Utility Colors
  Color get primaryText => brightness == Brightness.dark
      ? const Color(0xFFFFFFFF) // Cor do texto primário no tema escuro
      : const Color(0xFF00394C); // Cor do texto primário no tema claro

  Color get secondaryText => brightness == Brightness.dark
      ? const Color(0xFF95A1AC) // Cor do texto secundário no tema escuro
      : const Color(0xFF585A66); // Cor do texto secundário no tema claro

  Color get primaryBackground => brightness == Brightness.dark
      ? const Color(0xFF1D2428) // Cor de fundo primário no tema escuro
      : const Color(0xFFF5FBFF); // Cor de fundo primário no tema claro

  Color get secondaryBackground => brightness == Brightness.dark
      ? const Color(0xFF14181B) // Cor de fundo secundário no tema escuro
      : const Color(0xFFFFFFFF); // Cor de fundo secundário no tema claro

  // Semantic Colors
  Color get success => const Color(0xFF249689);
  Color get error => const Color(0xFFFF5963);
  Color get warning => const Color(0xFFF9CF58);
  Color get info => const Color(0xFFFFFFFF);
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2FD1C5),
  cardColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2FD1C5),
    onPrimary: Colors.white,
    secondary: Color(0xFF33B0A8),
    onSecondary: Colors.white,
    // Background (app canvas) and surface (cards) for light mode
    background: Color(0xFFF5FBFF), // primaryBackground in light
    surface: Color(0xFFFFFFFF), // secondaryBackground (cards) in light
    onSurface: Colors.black,
    error: Color(0xFFD32F2F),
    onError: Colors.white,
  ),
  // Keep scaffold background consistent with surface
  scaffoldBackgroundColor: const Color(0xFFF5FBFF),
  textTheme: GoogleFonts.almaraiTextTheme().apply(
    bodyColor: const Color(0xFF00394C),
    displayColor: const Color(0xFF00394C),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF1ED760),
  fontFamily: 'Momo Signature',
  cardColor: const Color(0xFF14181B),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF1ED760),
    onPrimary: Colors.white,
    secondary: Color(0xFF33B0A8),
    onSecondary: Colors.white,
    // Background (app canvas) and surface (cards) for dark mode
    background: Color(0xFF1D2428), // primaryBackground in dark
    surface: Color(0xFF14181B), // secondaryBackground (cards) in dark
    onSurface: Colors.white,
    error: Color(0xFFD32F2F),
    onError: Colors.white,
  ),
  // Use the surface color for scaffold background in dark mode as well
  scaffoldBackgroundColor: const Color(0xFF1D2428),
  textTheme: GoogleFonts.almaraiTextTheme().apply(
    // Default text in dark theme should be white for good contrast
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
);
