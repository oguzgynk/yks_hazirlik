// lib/services/ad_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';

// Premium kontrolü olmadığı için 'storage_service.dart' importu kaldırıldı.

class AdService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static bool _isBannerAdReady = false;
  static bool _isInterstitialAdReady = false;
  static int _interstitialAdCounter = 0;
  
  // YENİ: Banner yenileme sayacı ve timing kontrolü
  static int _bannerRefreshCount = 0;
  static DateTime? _lastBannerRefresh;
  static const int _minRefreshInterval = 10; // saniye

  // Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // AdMob Unit ID'leri - Production'da değiştirilmeli
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.bannerAdUnitId; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.interstitialAdUnitId; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    return '';
  }

  // Banner reklam yükleme
  static Future<void> loadBannerAd() async {
    // Premium kontrolü kaldırıldı. Reklam her zaman yüklenecek.
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          print('Banner reklam yüklendi');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          _bannerAd = null;
          print('Banner reklam yüklenemedi: $error');
        },
        onAdOpened: (ad) {
          // Reklam açıldığında
          print('Banner reklam açıldı');
        },
        onAdClosed: (ad) {
          // Reklam kapandığında
          print('Banner reklam kapandı');
        },
        onAdClicked: (ad) {
          // Reklama tıklandığında
          print('Banner reklama tıklandı');
        },
      ),
    );

    await _bannerAd?.load();
  }

  // YENİ: Banner reklamı yenileme metodu
  static Future<void> refreshBannerAd() async {
    try {
      print('Banner reklamı yenileniyor...');
      
      // Mevcut banner reklamı temizle
      _bannerAd?.dispose();
      _bannerAd = null;
      _isBannerAdReady = false;
      
      // Yeni banner reklamı yükle
      await loadBannerAd();
      
      // Sayacı artır
      _bannerRefreshCount++;
      _lastBannerRefresh = DateTime.now();
      
      print('Banner reklamı başarıyla yenilendi (${_bannerRefreshCount}. yenileme)');
    } catch (e) {
      print('Banner yenileme hatası: $e');
    }
  }

  // YENİ: Cooldown ile banner yenileme
  static Future<void> refreshBannerAdWithCooldown() async {
    final now = DateTime.now();
    
    // Çok sık yenilemeyi engelle
    if (_lastBannerRefresh != null && 
        now.difference(_lastBannerRefresh!).inSeconds < _minRefreshInterval) {
      print('Banner yenileme çok sık - bekleniyor (${_minRefreshInterval}s cooldown)');
      return;
    }
    
    await refreshBannerAd();
  }

  // Interstitial reklam yükleme
  static Future<void> loadInterstitialAd() async {
    // Premium kontrolü kaldırıldı. Reklam her zaman yüklenecek.
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          print('Geçiş reklamı yüklendi');
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              // Reklam tam ekranda gösterildiğinde
              print('Geçiş reklamı gösterildi');
            },
            onAdDismissedFullScreenContent: (ad) {
              // Kullanıcı reklamı kapattığında
              print('Geçiş reklamı kapatıldı');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // Yeni reklam yükle
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              // Reklam gösterilemediğinde
              print('Geçiş reklamı gösterilemedi: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // Yeni reklam yükle
              loadInterstitialAd();
            },
            onAdClicked: (ad) {
              // Reklama tıklandığında
              print('Geçiş reklamına tıklandı');
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Geçiş reklamı yüklenemedi: $error');
          _isInterstitialAdReady = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  // Banner reklam widget'ı alma
  static Widget? getBannerAdWidget() {
    // Premium kontrolü kaldırıldı.
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
    // Premium kontrolü kaldırıldı.
    _interstitialAdCounter++;

    // Her 5 sayfa değişiminde veya zorla gösterim
    if ((force || _interstitialAdCounter >= 5) && 
        _isInterstitialAdReady && 
        _interstitialAd != null) {
      
      _interstitialAdCounter = 0;
      _interstitialAd!.show();
      print('Geçiş reklamı gösteriliyor');
    }
  }

  // Reklam sayacını sıfırlama
  static void resetInterstitialCounter() {
    _interstitialAdCounter = 0;
  }

  // Banner reklam hazır mı kontrolü
  static bool get isBannerAdReady => _isBannerAdReady;

  // Interstitial reklam hazır mı kontrolü
  static bool get isInterstitialAdReady => _isInterstitialAdReady;

  // YENİ: Banner yenileme sayısı
  static int get bannerRefreshCount => _bannerRefreshCount;

  // Reklamları temizleme
  static void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }

  // Reklamları yeniden yükleme
  static Future<void> refreshAds() async {
    dispose();
    // Premium kontrolü kaldırıldı.
    await loadBannerAd();
    await loadInterstitialAd();
  }

  // Reklam gelirini simüle etme (test amaçlı)
  static Future<void> simulateAdRevenue() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // YENİ: Gelişmiş reklam analitikleri
  static Map<String, dynamic> getAdAnalytics() {
    return {
      'banner_ad_ready': _isBannerAdReady,
      'interstitial_ad_ready': _isInterstitialAdReady,
      'interstitial_counter': _interstitialAdCounter,
      'banner_refresh_count': _bannerRefreshCount,
      'last_banner_refresh': _lastBannerRefresh?.toIso8601String(),
    };
  }

  // YENİ: Banner performans metrikleri
  static Map<String, dynamic> getBannerPerformance() {
    return {
      'total_refreshes': _bannerRefreshCount,
      'last_refresh': _lastBannerRefresh?.toIso8601String(),
      'current_status': _isBannerAdReady ? 'ready' : 'loading',
      'ad_unit_id': bannerAdUnitId,
      'refresh_interval': _minRefreshInterval,
    };
  }

  // Test modunda mı kontrolü
  static bool get isTestMode {
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