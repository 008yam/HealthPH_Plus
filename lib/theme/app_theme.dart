import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF243B8F);
  static const primary = Color(0xFF31459B);
  static const pageBlue = Color(0xFF3B4C98);

  static const surface = Colors.white;
  static const surfaceSoft = Color(0xFFF4F7FB);
  static const border = Color(0xFFD7DEEA);
  static const progressTrack = Color(0xFFE9EEF8);

  static const text = Color(0xFF172033);
  static const mutedText = Color(0xFF667085);

  static const highRisk = Color(0xFFD64545);
  static const warning = Color(0xFFE0A21A);
  static const success = Color(0xFF2E7D5B);
  static const info = Color(0xFF2F80ED);

  static const concerned = warning;
  static const misinformed = highRisk;
  static const neutral = Color(0xFF6B7A90);
  static const proactive = success;

  static final cardRadius = BorderRadius.circular(8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pageBlue,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: info,
        surface: surface,
        error: highRisk,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
      ),
    );
  }

  static ThemeData get plainLightTheme {
  return lightTheme.copyWith(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: lightTheme.colorScheme.copyWith(
      surface: Colors.white,
    ),
  );
}

static ThemeData get greyTheme {
  return lightTheme.copyWith(
    scaffoldBackgroundColor: const Color(0xFFE9EDF3),
    colorScheme: lightTheme.colorScheme.copyWith(
      surface: const Color(0xFFF6F7FA),
    ),
  );
}

static ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF111827),
    colorScheme: const ColorScheme.dark(
      primary: info,
      secondary: warning,
      surface: Color(0xFF1F2937),
      error: highRisk,
    ),
  );
}

  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: surface,
      border: Border.all(color: border),
      borderRadius: cardRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Color riskColor(num value) {
    if (value >= 21) return highRisk;
    if (value >= 10) return warning;
    return success;
  }
}