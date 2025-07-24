// lib/screens/main_navigation.dart

import 'package:flutter/material.dart';
import '../services/ad_service.dart'; // AdService import edildi
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'topics_screen.dart';
import 'books_screen.dart';
import 'agenda_screen.dart';
import '../utils/theme.dart';

class MainNavigation extends StatefulWidget {
  final String currentTheme;
  final ValueChanged<String> onThemeChanged;

  const MainNavigation({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isPremium = false;

  // --- YEREL REKLAM KODLARI TAMAMEN KALDIRILDI ---
  // BannerAd? _bannerAd;
  // bool _isBannerAdReady = false;
  // InterstitialAd? _interstitialAd;
  // int _interstitialAdCounter = 0;
  // _loadBannerAd(), _loadInterstitialAd(), _showInterstitialAd() metodları silindi.

  @override
  void initState() {
    super.initState();
    _checkPremiumStatusAndLoadAds();
  }

  void _checkPremiumStatusAndLoadAds() {
    setState(() {
      _isPremium = StorageService.getPremiumStatus();
    });

    // Reklamları AdService üzerinden yüklüyoruz
    if (!_isPremium) {
      // Bu setState, reklam yüklendiğinde banner'ın görünmesini sağlar
      AdService.loadBannerAd().then((_) => setState(() {}));
      AdService.loadInterstitialAd();
    }
  }

  @override
  void dispose() {
    // AdService singleton olduğu için dispose'u genellikle uygulama kapanırken yönetilir,
    // ama burada da çağrılabilir.
    // AdService.dispose(); 
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      // Geçiş reklamını gösterme sorumluluğu AdService'e devredildi
      AdService.showInterstitialAd();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildNavItem(IconData selectedIcon, IconData unselectedIcon, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 26,
        ),
      ),
    );
  }

  double _getGradientPosition(double navBarWidth) {
    final itemWidth = navBarWidth / 5;
    
    switch (_currentIndex) {
      case 0:
        return 0;
      case 4:
        return navBarWidth - 64;
      default:
        return _currentIndex * itemWidth + (itemWidth - 64) / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeScreen(
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
      ),
      const StatisticsScreen(),
      const TopicsScreen(),
      const BooksScreen(),
      const AgendaScreen(),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final navBarWidth = screenWidth - 32;

    // AdService'ten banner widget'ını alıyoruz
    final bannerAdWidget = AdService.getBannerAdWidget();

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: screens[_currentIndex]),
          // Banner reklam alanı
          if (bannerAdWidget != null)
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 50, // Banner yüksekliği
              child: bannerAdWidget,
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _getGradientPosition(navBarWidth),
                  top: 0,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppThemes.getGradient(widget.currentTheme),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home, Icons.home_outlined, 0),
                    _buildNavItem(Icons.bar_chart, Icons.bar_chart_outlined, 1),
                    _buildNavItem(Icons.book, Icons.book_outlined, 2),
                    _buildNavItem(Icons.library_books, Icons.library_books_outlined, 3),
                    _buildNavItem(Icons.event, Icons.event_outlined, 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}