// lib/screens/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ad_service.dart';
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

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission(); // YENİ: Uygulama başlarken bildirim izni iste
    _initializeAds();
  }
  
  // YENİ: Bildirim izni isteme fonksiyonu
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("Bildirim izni verildi.");
    } else if (status.isDenied) {
      print("Bildirim izni reddedildi.");
    } else if (status.isPermanentlyDenied) {
      // Kullanıcı izni kalıcı olarak reddetti,
      // bu durumda kullanıcıyı uygulama ayarlarına yönlendirmek iyi bir fikir olabilir.
      print("Bildirim izni kalıcı olarak reddedildi.");
    }
  }

  Future<void> _initializeAds() async {
    await AdService.loadBannerAd();
    await AdService.loadInterstitialAd();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      AdService.showInterstitialAd();
      _refreshBannerOnPageChange();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _refreshBannerOnPageChange() async {
    try {
      await AdService.refreshBannerAdWithCooldown();
      if (mounted) {
        setState(() {});
      }
      print('Sayfa değişimi - Banner yenilendi');
    } catch (error) {
      print('Banner yenileme hatası: $error');
    }
  }

  Widget _buildNavItem(IconData selectedIcon, IconData unselectedIcon, int index) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          _onTabTapped(index);
        },
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: isSelected ? Colors.white : Colors.grey[400],
            size: 26,
          ),
        ),
      ),
    );
  }

  double _getGradientPosition(double navBarWidth) {
    final itemWidth = navBarWidth / 5;
    final centerPosition = (_currentIndex * itemWidth) + (itemWidth / 2);
    return centerPosition - 32;
  }

  Widget _buildBannerAdSection(Widget? bannerAdWidget) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: bannerAdWidget ?? Container(
        height: 50,
        alignment: Alignment.center,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
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

    final bannerAdWidget = AdService.getBannerAdWidget();

    return GestureDetector(
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: screens[_currentIndex]),
            _buildBannerAdSection(bannerAdWidget),
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
      ),
    );
  }
}