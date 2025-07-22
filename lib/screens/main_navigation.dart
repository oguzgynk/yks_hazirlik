import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'topics_screen.dart';
import 'books_screen.dart';
import 'pomodoro_screen.dart';
import '../utils/theme.dart'; // ✅

class MainNavigation extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const MainNavigation({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _isPremium = false;
  InterstitialAd? _interstitialAd;
  int _interstitialAdCounter = 0;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _checkPremiumStatus() {
    setState(() {
      _isPremium = StorageService.getPremiumStatus();
    });
  }

  void _loadBannerAd() {
    if (_isPremium) return;

    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  void _loadInterstitialAd() {
    if (_isPremium) return;

    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isPremium) return;
    
    _interstitialAdCounter++;
    
    // Her 5 sayfa geçişinde bir reklam göster
    if (_interstitialAdCounter % 5 == 0 && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      _showInterstitialAd();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      const StatisticsScreen(),
      const TopicsScreen(),
      const BooksScreen(),
      const PomodoroScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: screens[_currentIndex],
          ),
          // Banner reklam
          if (!_isPremium && _isBannerAdReady && _bannerAd != null)
            Container(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryPurple,
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 0 
                      ? BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                    color: _currentIndex == 0 ? Colors.white : Colors.grey[400],
                  ),
                ),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 1 
                      ? BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    _currentIndex == 1 ? Icons.bar_chart : Icons.bar_chart_outlined,
                    color: _currentIndex == 1 ? Colors.white : Colors.grey[400],
                  ),
                ),
                label: 'İstatistikler',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 2 
                      ? BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    _currentIndex == 2 ? Icons.book : Icons.book_outlined,
                    color: _currentIndex == 2 ? Colors.white : Colors.grey[400],
                  ),
                ),
                label: 'Konular',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 3 
                      ? BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    _currentIndex == 3 ? Icons.library_books : Icons.library_books_outlined,
                    color: _currentIndex == 3 ? Colors.white : Colors.grey[400],
                  ),
                ),
                label: 'Kitaplarım',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 4 
                      ? BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    _currentIndex == 4 ? Icons.timer : Icons.timer_outlined,
                    color: _currentIndex == 4 ? Colors.white : Colors.grey[400],
                  ),
                ),
                label: 'Pomodoro',
              ),
            ],
          ),
        ),
      ),
    );
  }
}