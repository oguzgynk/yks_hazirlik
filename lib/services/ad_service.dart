import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import 'storage_service.dart';
import 'package:flutter/material.dart';

class AdService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static bool _isBannerAdReady = false;
  static bool _isInterstitialAdReady = false;
  static int _interstitialAdCounter = 0;

  // Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // AdMob Unit IDs - Production'da değiştirilmeli
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.bannerAdUnitId; // Test ID
      // Production: return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
      // Production: return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.interstitialAdUnitId; // Test ID
      // Production: return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
      // Production: return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    }
    return '';
  }

  // Banner reklam yükleme
  static Future<void> loadBannerAd() async {
    // Premium kullanıcılara reklam gösterme
    if (StorageService.getPremiumStatus()) {
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          _bannerAd = null;
        },
        onAdOpened: (ad) {
          // Reklam açıldığında
        },
        onAdClosed: (ad) {
          // Reklam kapandığında
        },
        onAdClicked: (ad) {
          // Reklama tıklandığında
        },
      ),
    );

    await _bannerAd?.load();
  }

  // Interstitial reklam yükleme
  static Future<void> loadInterstitialAd() async {
    // Premium kullanıcılara reklam gösterme
    if (StorageService.getPremiumStatus()) {
      return;
    }

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              // Reklam tam ekranda gösterildiğinde
            },
            onAdDismissedFullScreenContent: (ad) {
              // Kullanıcı reklamı kapattığında
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // Yeni reklam yükle
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              // Reklam gösterilemediğinde
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // Yeni reklam yükle
              loadInterstitialAd();
            },
            onAdClicked: (ad) {
              // Reklama tıklandığında
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  // Banner reklam widget'ı alma
  static Widget? getBannerAdWidget() {
    if (StorageService.getPremiumStatus()) {
      return null;
    }

    if (_isBannerAdReady && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  // Interstitial reklam gösterme
  static void showInterstitialAd({bool force = false}) {
    // Premium kullanıcılara reklam gösterme
    if (StorageService.getPremiumStatus()) {
      return;
    }

    _interstitialAdCounter++;

    // Her 5 sayfa değişiminde veya zorla gösterim
    if ((force || _interstitialAdCounter >= 5) && 
        _isInterstitialAdReady && 
        _interstitialAd != null) {
      
      _interstitialAdCounter = 0;
      _interstitialAd!.show();
    }
  }

  // Reklam sayacını sıfırlama
  static void resetInterstitialCounter() {
    _interstitialAdCounter = 0;
  }

  // Banner reklam hazır mı kontrolü
  static bool get isBannerAdReady => _isBannerAdReady && !StorageService.getPremiumStatus();

  // Interstitial reklam hazır mı kontrolü
  static bool get isInterstitialAdReady => _isInterstitialAdReady && !StorageService.getPremiumStatus();

  // Reklamları temizleme
  static void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }

  // Reklamları yeniden yükleme (premium durumu değiştiğinde)
  static Future<void> refreshAds() async {
    dispose();
    
    if (!StorageService.getPremiumStatus()) {
      await loadBannerAd();
      await loadInterstitialAd();
    }
  }

  // Reklam gelirini simüle etme (test amaçlı)
  static Future<void> simulateAdRevenue() async {
    // Gerçek uygulamada AdMob'dan gelir verilerini alabilirsiniz
    // Bu sadece test amaçlı
    await Future.delayed(const Duration(seconds: 1));
  }

  // Reklam performansı için analitik
  static Map<String, dynamic> getAdAnalytics() {
    return {
      'banner_ad_ready': _isBannerAdReady,
      'interstitial_ad_ready': _isInterstitialAdReady,
      'interstitial_counter': _interstitialAdCounter,
      'premium_status': StorageService.getPremiumStatus(),
    };
  }

  // Test modunda mı kontrolü
  static bool get isTestMode {
    // Test ID'lerini kullanıyorsak test modundayız
    return bannerAdUnitId.contains('3940256099942544');
  }

  // Reklam yüklenme durumunu kontrol etme
  static Future<bool> waitForBannerAd({Duration timeout = const Duration(seconds: 10)}) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      if (_isBannerAdReady) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return false;
  }

  static Future<bool> waitForInterstitialAd({Duration timeout = const Duration(seconds: 10)}) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      if (_isInterstitialAdReady) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return false;
  }
}