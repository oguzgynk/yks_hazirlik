// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_navigation.dart';
import 'services/storage_service.dart';
import 'utils/theme.dart';
import 'dart:io';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isAndroid || Platform.isIOS) {
    // Sadece Android ve iOS cihazlarda reklamları başlat
    MobileAds.instance.initialize();
  }

  await initializeDateFormatting('tr_TR', null);
  //await MobileAds.instance.initialize();
  await StorageService.init();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  
  runApp(const YKSApp());
}

class YKSApp extends StatefulWidget {
  const YKSApp({super.key});

  @override
  State<YKSApp> createState() => _YKSAppState();
}

class _YKSAppState extends State<YKSApp> {
  // DEĞİŞTİ: bool _isDarkMode -> String _currentTheme
  String _currentTheme = AppThemes.light;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() {
    // DEĞİŞTİ: Tema adı okunuyor
    final themeName = StorageService.getTheme();
    setState(() {
      _currentTheme = themeName;
    });
  }

  // DEĞİŞTİ: toggleTheme -> changeTheme(String themeName)
  void changeTheme(String themeName) {
    setState(() {
      _currentTheme = themeName;
    });
    StorageService.saveTheme(themeName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YKS Asistanım',
      debugShowCheckedModeBanner: false,
      // DEĞİŞTİ: theme, darkTheme, themeMode yerine tek bir theme
      theme: AppThemes.getThemeData(_currentTheme),
      locale: const Locale('tr', 'TR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      home: MainNavigation(
        // DEĞİŞTİ: Parametreler güncellendi
        currentTheme: _currentTheme,
        onThemeChanged: changeTheme,
      ),
    );
  }
}