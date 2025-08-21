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

// YENİ EKLENEN IMPORT'LAR:
import 'services/notification_service.dart';
import 'utils/constants.dart'; // Motivasyon sözleri için

void main() async {
  // Bu satırın en üstte olduğundan emin olun
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sizin mevcut kodlarınız
  if (Platform.isAndroid || Platform.isIOS) {
    MobileAds.instance.initialize();
  }
  await initializeDateFormatting('tr_TR', null);
  await StorageService.init();

  // --- YENİ EKLENEN BİLDİRİM AYARLARI BÖLÜMÜ ---
  // =================================================================
  // 1. Bildirim servisini başlat
  await NotificationService.init();

  // 2. Son görülme tarihini güncelle ve "seni özledik" hatırlatıcısını sıfırla
  // Bu sayede kullanıcı uygulamayı her açtığında hatırlatıcı ertelenmiş olur.
  await StorageService.updateLastSeenDate();
  await NotificationService.resetInactivityReminder();

  // 3. Her gün öğlen 12'de gönderilecek motivasyon bildirimini kur
  // ÖNEMLİ NOT: Bu satır, AppConstants dosyanızda 'motivationalQuotes' adında
  // bir motivasyon sözleri listesi (List<String>) olduğunu varsayar.
  // Eğer listenizin adı farklıysa, lütfen bu satırdaki 'motivationalQuotes' kısmını ona göre düzenleyin.
  NotificationService.scheduleDailyQuoteNotification(AppConstants.motivationQuotes);

  // =================================================================
  // --- YENİ BÖLÜM BİTTİ ---

  // Tam ekran modu için sizin kodunuz
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const YKSApp());
}

class YKSApp extends StatefulWidget {
  const YKSApp({super.key});

  @override
  State<YKSApp> createState() => _YKSAppState();
}

class _YKSAppState extends State<YKSApp> {
  String _currentTheme = AppThemes.light;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() {
    final themeName = StorageService.getTheme();
    setState(() {
      _currentTheme = themeName;
    });
  }

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
        currentTheme: _currentTheme,
        onThemeChanged: changeTheme,
      ),
    );
  }
}