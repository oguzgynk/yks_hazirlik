// lib/utils/theme.dart

import 'package:flutter/material.dart';

class AppThemes {
  // Tema Adları (kod içinde anahtar olarak kullanılacak)
  static const String light = 'light';
  static const String dark = 'dark';
  static const String ocean = 'ocean';   // Premium
  static const String sunset = 'sunset'; // Premium
  static const String forest = 'forest'; // Premium
  static const String dusk = 'dusk';     // Premium


  
  // Temaların kullanıcının göreceği adları
  static Map<String, String> themeDisplayNames = {
    light: 'Aydınlık Mod',
    dark: 'Karanlık Mod',
    ocean: 'Okyanus Esintisi',
    sunset: 'Gün Batımı',
    forest: 'Orman Yeşili',
    dusk: 'Galaksi Rüyası',
  };

  // Renk paletleri
  static const _lightColors = {'primary': Color(0xFF6366F1), 'secondary': Color(0xFF3B82F6), 'background': Color(0xFFF8FAFC), 'surface': Colors.white, 'text': Color(0xFF1E293B), 'subtext': Color(0xFF64748B)};
  static const _darkColors = {'primary': Color(0xFF818CF8), 'secondary': Color(0xFF60A5FA), 'background': Color(0xFF0F172A), 'surface': Color(0xFF1E293B), 'text': Color(0xFFF1F5F9), 'subtext': Color(0xFF94A3B8)};
  static const _oceanColors = {'primary': Color(0xFF06B6D4), 'secondary': Color(0xFF14B8A6), 'background': Color(0xFFF0FDFA), 'surface': Colors.white, 'text': Color(0xFF0F766E), 'subtext': Color(0xFF115E59)};
  static const _sunsetColors = {'primary': Color(0xFFF97316), 'secondary': Color(0xFFEF4444), 'background': Color(0xFFFFF7ED), 'surface': Colors.white, 'text': Color(0xFFB45309), 'subtext': Color(0xFF9A3412)};
  static const _forestColors = {'primary': Color(0xFF16A34A), 'secondary': Color(0xFF65A30D), 'background': Color(0xFFF7FEE7), 'surface': Colors.white, 'text': Color(0xFF365314), 'subtext': Color(0xFF4D7C0F)};
  static const _duskColors = {'primary': Color(0xFF9333EA), 'secondary': Color(0xFFDB2777), 'background': Color(0xFF1E1B4B), 'surface': Color(0xFF312E81), 'text': Color(0xFFE0E7FF), 'subtext': Color(0xFFC7D2FE)};

  // Tema adına göre ThemeData objesini döndüren ana fonksiyon
  static ThemeData getThemeData(String themeName) {
    switch (themeName) {
      case dark:
        return _createTheme(brightness: Brightness.dark, colors: _darkColors, gradient: const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF60A5FA)]));
      case ocean:
        return _createTheme(brightness: Brightness.light, colors: _oceanColors, gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)]));
      case sunset:
        return _createTheme(brightness: Brightness.light, colors: _sunsetColors, gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)]));
      case forest:
        return _createTheme(brightness: Brightness.light, colors: _forestColors, gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF65A30D)]));
      case dusk:
        return _createTheme(brightness: Brightness.dark, colors: _duskColors, gradient: const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFFDB2777)]));
      case light:
      default:
        return _createTheme(brightness: Brightness.light, colors: _lightColors, gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF3B82F6)]));
    }
  }
  
  // Widget'larda kolayca erişmek için gradyanları döndüren fonksiyon
  static LinearGradient getGradient(String themeName) {
    switch (themeName) {
      case dark: return const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF60A5FA)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case ocean: return const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case sunset: return const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case forest: return const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF65A30D)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case dusk: return const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFFDB2777)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case light:
      default: return const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  // Standart bir tema oluşturmak için kullanılan yardımcı fonksiyon
  static ThemeData _createTheme({ required Brightness brightness, required Map<String, Color> colors, required LinearGradient gradient, }) {
    final primaryColor = colors['primary']!;
    final secondaryColor = colors['secondary']!;
    final backgroundColor = colors['background']!;
    final surfaceColor = colors['surface']!;
    final textColor = colors['text']!;
    final subtextColor = colors['subtext']!;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Poppins',
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme( brightness: brightness, primary: primaryColor, onPrimary: Colors.white, secondary: secondaryColor, onSecondary: Colors.white, error: Colors.red, onError: Colors.white, background: backgroundColor, onBackground: textColor, surface: surfaceColor, onSurface: textColor),
      appBarTheme: AppBarTheme( elevation: 0, backgroundColor: Colors.transparent, foregroundColor: textColor, titleTextStyle: TextStyle( color: textColor, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
      cardTheme: CardThemeData( elevation: 2, shadowColor: Colors.black.withOpacity(0.06), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: surfaceColor),
      elevatedButtonTheme: ElevatedButtonThemeData( style: ElevatedButton.styleFrom( elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12)), textStyle: TextStyle( fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins'))),
      textTheme: TextTheme( headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor), headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textColor), headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor), bodyLarge: TextStyle(fontSize: 16, color: subtextColor), bodyMedium: TextStyle(fontSize: 14, color: subtextColor)),
    );
  }
}