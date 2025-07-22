# YKS Hazırlık Uygulaması

YKS sınavına hazırlanan öğrenciler için geliştirilmiş kapsamlı bir mobil uygulama. Flutter framework'ü kullanılarak geliştirilmiştir.

## 📱 Özellikler

### 🏠 Ana Sayfa
- YKS'ye kalan gün sayısı (geri sayım)
- Günlük motivasyon sözleri (50+ ünlü kişi sözü)
- Günlük hedef takibi (çalışma süresi ve soru sayısı)
- Bugünkü çalışma istatistikleri
- Hızlı erişim butonları (Çalışma Saati, Soru Gir, Deneme Gir)

### 📊 İstatistikler
- Çizgi grafiklerle görsel analiz
- 3 farklı grafik türü: Deneme Netlerim, Çalışma Saati, Çözülen Soru
- Haftalık, aylık ve tüm zamanlar filtreleme
- Dönem özeti kartları

### 📚 Konular
- TYT ve AYT konu listesi
- Ders bazlı ilerleme takibi
- Konu tamamlama sistemi
- Her konudan çözülen soru sayısı takibi

### 📖 Kitaplarım
- Kişisel kitap kütüphanesi
- Otomatik konu ataması
- Kitap tamamlanma yüzdesi
- Konu ekleme/çıkarma özelliği

### ⏰ Pomodoro Timer
- Varsayılan 25dk çalışma, 5dk dinlenme
- Özelleştirilebilir süreler
- Çalışma süresini istatistiklere dahil etme seçeneği
- Görsel geri sayım ve animasyonlar

### 🧮 Net Hesaplayıcı
- Hızlı net hesaplama aracı
- Detaylı ders bazlı hesaplama
- TYT ve AYT desteği
- Hesaplama ipuçları

### ⚙️ Ayarlar
- Karanlık/Açık mod
- YKS tarihi ayarlama
- Premium satın alma
- Veri yönetimi

## 🎯 Teknik Özellikler

### 💾 Veri Yönetimi
- Tüm veriler cihazın yerel depolamasında (SharedPreferences)
- Çalışma oturumları, kitap bilgileri, konu ilerlemeleri
- Deneme sonuçları ve istatistikler

### 💰 Monetizasyon
- Google AdMob banner reklamları
- Sayfa geçişlerinde interstitial reklamlar
- 200₺ ile premium (reklam kaldırma)
- Google Play In-App Purchase entegrasyonu

### 🎨 Tasarım
- Material Design 3 uyumlu
- Mor-mavi gradyan tema
- Karanlık mod desteği
- Animasyonlar ve geçiş efektleri
- Responsive tasarım (tüm Android ekranları)

### 📱 Platformlar
- Android 12+ (API 31+)
- Tüm ekran boyutları destekli
- Çentik ve navigation bar uyumlu

## 🚀 Kurulum

### Gereksinimler
- Flutter 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Android SDK (API 31+)

### Kurulum Adımları

1. **Projeyi klonlayın:**
```bash
git clone https://github.com/your-username/yks-hazirlik-app.git
cd yks-hazirlik-app
```

2. **Bağımlılıkları yükleyin:**
```bash
flutter pub get
```

3. **Android emülatörü başlatın veya cihazı bağlayın**

4. **Uygulamayı çalıştırın:**
```bash
flutter run
```

### Release Build

1. **APK oluşturma:**
```bash
flutter build apk --release
```

2. **App Bundle oluşturma (Play Store için):**
```bash
flutter build appbundle --release
```

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                 # Ana uygulama dosyası
├── models/                   # Veri modelleri
│   └── data_models.dart
├── screens/                  # Ekranlar
│   ├── home_screen.dart
│   ├── statistics_screen.dart
│   ├── topics_screen.dart
│   ├── books_screen.dart
│   ├── pomodoro_screen.dart
│   ├── settings_screen.dart
│   ├── question_entry_screen.dart
│   ├── exam_entry_screen.dart
│   ├── study_time_entry_screen.dart
│   ├── net_calculator_screen.dart
│   └── main_navigation.dart
├── services/                 # Servisler
│   ├── storage_service.dart
│   └── ad_service.dart
└── utils/                    # Yardımcı dosyalar
    ├── constants.dart
    └── theme.dart
```

## 📦 Kullanılan Paketler

### Ana Paketler
- `shared_preferences` - Yerel veri depolama
- `fl_chart` - Grafik çizimi
- `google_mobile_ads` - Reklam entegrasyonu
- `in_app_purchase` - Premium satın alma

### UI Paketler
- `percent_indicator` - İlerleme göstergeleri
- `circular_countdown_timer` - Pomodoro timer
- `animated_text_kit` - Animasyonlu metin
- `flutter_animate` - Geçiş animasyonları

### Yardımcı Paketler
- `intl` - Tarih/saat formatlama
- `flutter_local_notifications` - Bildirimler

## 🎯 Konu Listesi

### TYT (119 soru)
- **Türkçe** (40 soru): 24 konu
- **Matematik** (28 soru): 21 konu
- **Geometri** (12 soru): 16 konu
- **Fizik** (7 soru): 12 konu
- **Kimya** (6 soru): 10 konu
- **Biyoloji** (6 soru): 10 konu
- **Tarih** (5 soru): 22 konu
- **Coğrafya** (5 soru): 19 konu
- **Felsefe** (5 soru): 13 konu
- **Din Kültürü** (5 soru): 10 konu

### AYT
- **Matematik** (28 soru): 23 konu
- **Geometri** (12 soru): 8 konu
- **Türk Dili ve Edebiyatı** (24 soru): 26 konu
- **Tarih-1** (10 soru): 12 konu
- **Coğrafya-1** (6 soru): 6 konu
- **Fizik** (14 soru): 12 konu
- **Kimya** (13 soru): 10 konu
- **Biyoloji** (13 soru): 12 konu
- **Felsefe** (12 soru): 12 konu
- **Din Kültürü** (6 soru): 10 konu

## 🔧 Konfigürasyon

### AdMob Ayarları
`lib/utils/constants.dart` dosyasındaki test ID'lerini production ID'leri ile değiştirin:

```dart
// Test IDs (şu anki)
static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

// Production IDs ile değiştirin
static const String bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String interstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

### App Signing
`android/app/build.gradle` dosyasındaki keystore bilgilerini güncelleyin.

### App ID
`android/app/src/main/AndroidManifest.xml` dosyasındaki `applicationId` değerini güncelleyin.

## 🎨 Tasarım Sistemi

### Renkler
- **Primary Purple**: `#6366F1`
- **Primary Blue**: `#3B82F6`
- **Secondary Purple**: `#8B5CF6`
- **Accent Blue**: `#06B6D4`

### Gradyanlar
- **Primary Gradient**: Purple → Blue
- **Secondary Gradient**: Secondary Purple → Accent Blue

### Typography
- **Font Family**: Poppins
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

## 📊 Veri Yapısı

### Çalışma Oturumu
```dart
class StudySession {
  final String id;
  final String subject;
  final String topic;
  final int duration; // dakika
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;
  final DateTime date;
  final bool isExam;
  final String examType;
}
```

### Kitap
```dart
class Book {
  final String id;
  final String name;
  final String publisher;
  final String examType;
  final String subject;
  final List<Topic> topics;
}
```

## 🚀 Yayınlama

### Play Store Hazırlık
1. **App signing** sertifikası oluşturun
2. **Privacy Policy** hazırlayın
3. **Store listing** metinlerini hazırlayın
4. **Screenshots** ve **feature graphic** oluşturun
5. **Test kullanıcıları** ekleyin

### Play Console Adımları
1. Uygulama oluşturun
2. App Bundle'ı yükleyin
3. Store listing bilgilerini doldurun
4. İçerik derecelendirmesi yapın
5. Fiyatlandırma ve dağıtım ayarlarını yapın
6. Internal testing ile test edin
7. Production'a yayınlayın

## 🐛 Bilinen Sorunlar

- [ ] Çok fazla veri olduğunda grafik performansı
- [ ] Android 14'te bildirim izinleri
- [ ] Bazı cihazlarda reklam yüklenme gecikmesi

## 🔄 Geliştirilmesi Planlanan Özellikler

- [ ] Bulut senkronizasyonu
- [ ] Sosyal özellikler (arkadaşlarla yarışma)
- [ ] AI destekli çalışma önerileri
- [ ] Sesli hatırlatıcılar
- [ ] Widget desteği
- [ ] iOS sürümü

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Push yapın (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 📞 İletişim

- **Email**: developer@yksapp.com
- **Website**: https://yksapp.com
- **Support**: https://support.yksapp.com

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Tüm open source katkıda bulunanlar
- YKS adaylarına motivasyon için

---

**YKS Hazırlık Uygulaması** ile başarıya giden yolda öğrencilerin yanındayız! 🎯📚