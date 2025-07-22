import '../models/data_models.dart';

class AppConstants {
  // YKS Tarihi (2025)
  static DateTime yksDate = DateTime(2025, 6, 14); // YKS genellikle Haziran'da
  
  // AdMob IDs (Test IDs)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // Premium fiyat
  static const String premiumProductId = 'remove_ads_premium';
  static const double premiumPrice = 200.0;
  
  // Motivasyon sözleri
  static List<MotivationQuote> motivationQuotes = [
    MotivationQuote(quote: "Başarı, hazırlık ile fırsatın buluştuğu andır.", author: "Bobby Unser"),
    MotivationQuote(quote: "Eğitim geleceğin kapısını açan altın anahtardır.", author: "Malcolm X"),
    MotivationQuote(quote: "Öğrenmeye yatırım yapın. En iyi faizi sağlar.", author: "Benjamin Franklin"),
    MotivationQuote(quote: "Başarı %1 ilham, %99 terdir.", author: "Thomas Edison"),
    MotivationQuote(quote: "İmkansız, motive olmayanların sözlüğünde bulunan bir kelimedir.", author: "Napoleon Bonaparte"),
    MotivationQuote(quote: "Hayatta en büyük zafer hiç düşmemek değil, her düştüğünde ayağa kalkmaktır.", author: "Nelson Mandela"),
    MotivationQuote(quote: "Eğitim, karanlığı aydınlatan en güçlü silahtır.", author: "Nelson Mandela"),
    MotivationQuote(quote: "Bugün yapacağın şey yarının sonuçlarını belirler.", author: "Mahatma Gandhi"),
    MotivationQuote(quote: "Başarının anahtarı sürekli öğrenmeye devam etmektir.", author: "Robert Kiyosaki"),
    MotivationQuote(quote: "Büyük işler küçük adımlarla başlar.", author: "Lao Tzu"),
    MotivationQuote(quote: "Kendine inanırsan, yolun yarısını almış olursun.", author: "Theodore Roosevelt"),
    MotivationQuote(quote: "Zeka sadece bilgi değil, bilgiyi kullanma yetisidir.", author: "Aristotle"),
    MotivationQuote(quote: "Başarı, başarısızlıktan başarısızlığa coşkuyu kaybetmeden geçmektir.", author: "Winston Churchill"),
    MotivationQuote(quote: "Geleceği tahmin etmenin en iyi yolu onu yaratmaktır.", author: "Peter Drucker"),
    MotivationQuote(quote: "Öğrenmek deneyimdir. Geri kalan her şey sadece bilgidir.", author: "Albert Einstein"),
    MotivationQuote(quote: "Başarı, hazırlık ile şansın buluşmasıdır.", author: "Seneca"),
    MotivationQuote(quote: "Hayal edebiliyorsan, yapabilirsin.", author: "Walt Disney"),
    MotivationQuote(quote: "Bilim, düzenlenmiş bilgidir. Bilgelik ise düzenlenmiş yaşamdır.", author: "Immanuel Kant"),
    MotivationQuote(quote: "Daha iyi olmak istiyorsan, kendin olmayı öğren.", author: "Socrates"),
    MotivationQuote(quote: "Öğretmen kapıyı açar ama içeri sen girmelisin.", author: "Çin Atasözü"),
    MotivationQuote(quote: "Başarı, küçük çabaların günlük tekrarından doğar.", author: "Robert Collier"),
    MotivationQuote(quote: "Okumak zihni, yazmak da ruhu besler.", author: "Voltaire"),
    MotivationQuote(quote: "En büyük zafer düşmemek değil, her düştüğünde ayağa kalkmaktır.", author: "Confucius"),
    MotivationQuote(quote: "Öğrenmek asla durdurulmaz. Yaş, renk, din fark etmez.", author: "B.B. King"),
    MotivationQuote(quote: "Bilgi güçtür.", author: "Francis Bacon"),
    MotivationQuote(quote: "Başarısızlık, başarının anahtarıdır.", author: "Morihei Ueshiba"),
    MotivationQuote(quote: "Eğitim tutkuyu söndürmek değil, alevlendirmektir.", author: "William Butler Yeats"),
    MotivationQuote(quote: "Öğrenmeye yatırım yapmak her zaman en iyi faizi verir.", author: "Benjamin Franklin"),
    MotivationQuote(quote: "Cesaret, korkunun karşısında durabilmektir.", author: "Mark Twain"),
    MotivationQuote(quote: "Hayallerinizi gerçekleştirmek için önce uyanmalısınız.", author: "Josephine Baker"),
    MotivationQuote(quote: "Başarı, hazırlığın şansla buluşmasıdır.", author: "Louis Pasteur"),
    MotivationQuote(quote: "Öğrenmek yaşamın ta kendisidir.", author: "Plutarch"),
    MotivationQuote(quote: "Zorluklar seni güçlendirir, kolaylıklar seni zayıflatır.", author: "John C. Maxwell"),
    MotivationQuote(quote: "Başarılı olmak için önce başarısız olmayı öğrenmelisin.", author: "Michael Jordan"),
    MotivationQuote(quote: "Bilgisizlik, bilginin yokluğu değil, yanlış bilgidir.", author: "Stephen Hawking"),
    MotivationQuote(quote: "En iyi yatırım kendinize yaptığınız yatırımdır.", author: "Warren Buffett"),
    MotivationQuote(quote: "Başarı, durmadan devam etme yeteneğidir.", author: "Albert Einstein"),
    MotivationQuote(quote: "Öğrenme sevgi ile başlar.", author: "Aristotle"),
    MotivationQuote(quote: "Başarısızlık seçenek değildir.", author: "Gene Kranz"),
    MotivationQuote(quote: "Eğitim, zihni açan anahtardır.", author: "Oprah Winfrey"),
    MotivationQuote(quote: "Büyük başarılar, büyük riskler gerektirir.", author: "Herodotus"),
    MotivationQuote(quote: "Başarı, azimli çalışmanın ödülüdür.", author: "Sophocles"),
    MotivationQuote(quote: "Öğrenmek bir hazinedir ve sahibini her yerde takip eder.", author: "Çin Atasözü"),
    MotivationQuote(quote: "Başarı, başkalarının vazgeçtiği yerde başlar.", author: "William Feather"),
    MotivationQuote(quote: "Eğitim en güçlü silahtır.", author: "Nelson Mandela"),
    MotivationQuote(quote: "Bilgili olmak yeterli değildir; uygulamak gerekir.", author: "Goethe"),
    MotivationQuote(quote: "Başarı, hazırlık ile fırsatın kesiştiği noktadır.", author: "Bobby Unser"),
    MotivationQuote(quote: "Hayallerin gerçek olabilmesi için önce hayal kurmalısın.", author: "Joel Brown"),
    MotivationQuote(quote: "Başarının sırrı, başlamaktır.", author: "Mark Twain"),
    MotivationQuote(quote: "Öğrenme asla para kaybı değildir.", author: "Benjamin Franklin"),
  ];
  
  // TYT Konuları
  static Map<String, List<String>> tytTopics = {
    'Türkçe': [
      'Sözcükte Anlam', 'Deyim ve Atasözü', 'Cümlede Anlam', 'Paragraf',
      'Ses Bilgisi', 'Yazım Kuralları', 'Noktalama İşaretleri', 'Sözcükte Yapı/Ekler',
      'Sözcük Türleri', 'İsimler', 'Zamirler', 'Sıfatlar', 'Zarflar',
      'Edat - Bağlaç - Ünlem', 'Fiiller', 'Fiilde Anlam (Kip-Kişi-Yapı)',
      'Ek Fiil', 'Fiilimsi', 'Fiilde Çatı', 'Sözcük Grupları', 'Cümlenin Ögeleri',
      'Cümle Türleri', 'Anlatım Bozukluğu'
    ],
    'Matematik': [
      'Temel Kavramlar', 'Sayı Basamakları', 'Bölme ve Bölünebilme', 'EBOB - EKOK',
      'Rasyonel Sayılar', 'Basit Eşitsizlikler', 'Mutlak Değer', 'Üslü Sayılar',
      'Köklü Sayılar', 'Çarpanlara Ayırma', 'Oran Orantı', 'Denklem Çözme',
      'Problemler', 'Kümeler - Kartezyen Çarpım', 'Mantık', 'Fonksiyonlar',
      'Polinomlar', '2.Dereceden Denklemler', 'Permütasyon ve Kombinasyon',
      'Olasılık', 'Veri - İstatistik'
    ],
    'Geometri': [
      'Temel Kavramlar', 'Doğruda Açılar', 'Üçgende Açılar', 'Eşkenar Üçgen',
      'Açıortay', 'Kenarortay', 'Eşlik ve Benzerlik', 'Üçgende Alan',
      'Üçgende Benzerlik', 'Açı Kenar Bağıntıları', 'Çokgenler', 'Özel Dörtgenler',
      'Çember ve Daire', 'Analitik Geometri', 'Katı Cisimler', 'Çemberin Analitiği'
    ],
    'Fizik': [
      'Fizik Bilimine Giriş', 'Madde ve Özellikleri', 'Sıvıların Kaldırma Kuvveti',
      'Basınç', 'Isı, Sıcaklık ve Genleşme', 'Hareket ve Kuvvet', 'Dinamik',
      'İş, Güç ve Enerji', 'Elektrik', 'Manyetizma', 'Dalgalar', 'Optik'
    ],
    'Kimya': [
      'Kimya Bilimi', 'Atom ve Periyodik Sistem', 'Kimyasal Türler Arası Etkileşimler',
      'Maddenin Halleri', 'Doğa ve Kimya', 'Kimyanın Temel Kanunları',
      'Kimyasal Hesaplamalar', 'Karışımlar', 'Asit, Baz ve Tuz', 'Kimya Her Yerde'
    ],
    'Biyoloji': [
      'Canlıların Ortak Özellikleri', 'Canlıların Temel Bileşenleri',
      'Hücre ve Organelleri', 'Hücre Zarından Madde Geçişi', 'Canlıların Sınıflandırılması',
      'Mitoz ve Eşeysiz Üreme', 'Mayoz ve Eşeyli Üreme', 'Kalıtım',
      'Ekosistem Ekolojisi', 'Güncel Çevre Sorunları'
    ],
    'Tarih': [
      'Tarih ve Zaman', 'İnsanlığın İlk Dönemleri', 'Orta Çağ\'da Dünya',
      'İlk ve Orta Çağlarda Türk Dünyası', 'İslam Medeniyetinin Doğuşu',
      'Türklerin İslamiyet\'i Kabulü ve İlk Türk İslam Devletleri',
      'Yerleşme ve Devletleşme Sürecinde Selçuklu Türkiyesi',
      'Beylikten Devlete Osmanlı Siyaseti', 'Devletleşme Sürecinde Savaşçılar ve Askerler',
      'Beylikten Devlete Osmanlı Medeniyeti', 'Dünya Gücü Osmanlı',
      'Sultan ve Osmanlı Merkez Teşkilatı', 'Klasik Çağda Osmanlı Toplum Düzeni',
      'Değişen Dünya Dengeleri Karşısında Osmanlı Siyaseti',
      'Değişim Çağında Avrupa ve Osmanlı', 'Uluslararası İlişkilerde Denge Stratejisi (1774-1914)',
      'Devrimler Çağında Değişen Devlet-Toplum İlişkileri', 'Sermaye ve Emek',
      'XIX. ve XX. Yüzyılda Değişen Gündelik Hayat',
      'XX. Yüzyıl Başlarında Osmanlı Devleti ve Dünya', 'Milli Mücadele',
      'Atatürkçülük ve Türk İnkılabı'
    ],
    'Coğrafya': [
      'Doğa ve İnsan', 'Dünya\'nın Şekli ve Hareketleri', 'Coğrafi Konum',
      'Harita Bilgisi', 'Atmosfer ve Sıcaklık', 'İklimler', 'Basınç ve Rüzgarlar',
      'Nem, Yağış ve Buharlaşma', 'İç Kuvvetler / Dış Kuvvetler',
      'Su - Toprak ve Bitkiler', 'Nüfus', 'Göç', 'Yerleşme', 'Türkiye\'nin Yer Şekilleri',
      'Ekonomik Faaliyetler', 'Bölgeler', 'Uluslararası Ulaşım Hatları',
      'Çevre ve Toplum', 'Doğal Afetler'
    ],
    'Felsefe': [
      'Felsefe\'nin Konusu', 'Bilgi Felsefesi', 'Varlık Felsefesi', 'Ahlak Felsefesi',
      'Sanat Felsefesi', 'Din Felsefesi', 'Siyaset Felsefesi', 'Bilim Felsefesi',
      'İlk Çağ Felsefesi', '2. Yüzyıl ve 15. Yüzyıl Felsefeleri',
      '15. Yüzyıl ve 17. Yüzyıl Felsefeleri', '18. Yüzyıl ve 19. Yüzyıl Felsefeleri',
      '20. Yüzyıl Felsefesi'
    ],
    'Din Kültürü': [
      'Bilgi ve İnanç', 'İslam ve İbadet', 'Ahlak ve Değerler', 'Allah İnsan İlişkisi',
      'Hz. Muhammed (S.A.V.)', 'Vahiy ve Akıl', 'İslam Düşüncesinde Yorumlar, Mezhepler',
      'Din, Kültür ve Medeniyet', 'İslam ve Bilim, Estetik, Barış', 'Yaşayan Dinler'
    ],
  };
  
  // AYT Konuları
  static Map<String, List<String>> aytTopics = {
    'Matematik': [
      'Kümeler', 'Denklem ve Eşitsizlikler', 'Fonksiyonlar', 'Üçgenler', 'Veri',
      'Olasılık', 'Sayma', 'Fonksiyonlarla İşlemler ve Uygulamalar',
      'Dörtgenler ve Çokgenler', 'İkinci Dereceden Denklem ve Fonksiyonlar',
      'Polinomlar', 'Geometrik Cisimler', 'Trigonometri', 'Analitik Geometri',
      'Fonksiyonlarda Uygulamalar', 'Denklem ve Eşitsizlik Sistemleri',
      'Çember ve Daire', 'Uzay Geometri', 'Üstel ve Logaritmik Fonksiyonlar',
      'Diziler', 'Türev', 'İntegral', 'Dönüşümler'
    ],
    'Geometri': [
      'Üçgenler', 'Dörtgenler ve Çokgenler', 'Geometrik Cisimler', 'Trigonometri',
      'Analitik Geometri', 'Çember ve Daire', 'Uzay Geometri', 'Dönüşümler'
    ],
    'Türk Dili ve Edebiyatı': [
      'Hikaye', 'Şiir', 'Roman', 'Tiyatro', 'Masal', 'Fabl', 'Biyografi',
      'Otobiyografi', 'Mektup', 'E-Posta', 'Günlük', 'Blog', 'Destan',
      'Efsane', 'Anı', 'Hatıra', 'Haber Metni', 'Gezi Yazısı', 'Makale',
      'Sohbet ve Fıkra', 'Eleştiri', 'Mülakat', 'Röportaj', 'Deneme',
      'Söylev', 'Nutuk'
    ],
    'Tarih-1': [
      'Tarih Bilimi', 'Uygarlığın Doğuşu ve İlk Uygarlıklar', 'İlk Türk Devletleri',
      'İslam Tarihi ve Uygarlığı (13. Yüzyıla Kadar)',
      'Türk - İslam Devletleri (10 -13. Yüzyıllar)', 'Türkiye Tarihi (11 - 13. Yüzyıllar)',
      'Beylikten Devlete', 'Dünya Gücü: Osmanlı Devleti (1453- 1600)',
      'Arayış Yılları (17. Yüzyıl)', 'Avrupa ve Osmanlı Devleti (18. Yüzyıl)',
      'En Uzun Yüzyıl (1800 - 1922)', 'T.C. İnkılap Tarihi ve Atatürkçülük'
    ],
    'Coğrafya-1': [
      'Doğal Sistemler', 'Beşeri Sistemler', 'Küresel Ortam: Bölgeler ve Ülkeler',
      'Çevre ve Toplum', 'Ekonomik Faaliyetler', 'Türkiye\'nin Yeryüzü Şekilleri'
    ],
    'Fizik': [
      'Fizik Bilimine Giriş', 'Madde ve Özellikleri', 'Kuvvet ve Hareket',
      'Enerji', 'Isı ve Sıcaklık', 'Basınç ve Kaldırma Kuvveti',
      'Elektrik ve Manyetizma', 'Dalgalar', 'Optik', 'Vektörler',
      'Modern Fizik', 'Atom Fiziği'
    ],
    'Kimya': [
      'Kimya Bilimi', 'Atom ve Periyodik Sistem', 'Kimyasal Türler Arası Etkileşimler',
      'Maddenin Halleri', 'Karışımlar', 'Asitler, Bazlar ve Tuzlar',
      'Modern Atom Teorisi', 'Gazlar', 'Sıvı Çözeltiler', 'Organik Kimya'
    ],
    'Biyoloji': [
      'Yaşam Bilimi ve Biyoloji', 'Canlılar Dünyası', 'Güncel Çevre Sorunları',
      'Üreme', 'Kalıtımın Genel İlkeleri', 'Ekosistem Ekolojisi',
      'Sinir Sistemi', 'Duyu Organları', 'Destek ve Hareket Sistemi',
      'Sindirim Sistemi', 'Dolaşım Sistemleri', 'Genetik'
    ],
    'Felsefe': [
      'Felsefe\'nin Alanı', 'Bilgi Felsefesi', 'Bilim Felsefesi', 'Varlık Felsefesi',
      'Ahlak Felsefesi', 'Siyaset Felsefesi', 'Sanat Felsefesi', 'Din Felsefesi',
      'Mantığa Giriş', 'Klasik Mantık', 'Psikoloji', 'Sosyoloji'
    ],
    'Din Kültürü': [
      'İnanç', 'İbadet', 'Ahlak ve Değerler', 'Din, Kültür ve Medeniyet',
      'Hz. Muhammed (SAV)', 'Vahiy ve Akıl', 'Dünya ve Ahiret',
      'İslam Düşüncesi', 'Güncel Dini Meseleler', 'Diğer Dinler'
    ],
  };
  
  // Sınav soru sayıları
  static Map<String, int> tytQuestionCounts = {
    'Türkçe': 40,
    'Matematik': 28,
    'Geometri': 12,
    'Fizik': 7,
    'Kimya': 6,
    'Biyoloji': 6,
    'Tarih': 5,
    'Coğrafya': 5,
    'Felsefe': 5,
    'Din Kültürü': 5,
  };
  
  static Map<String, int> aytQuestionCounts = {
    'Matematik': 28,
    'Geometri': 12,
    'Türk Dili ve Edebiyatı': 24,
    'Tarih-1': 10,
    'Coğrafya-1': 6,
    'Tarih-2': 11,
    'Coğrafya-2': 11,
    'Felsefe': 12,
    'Din Kültürü': 6,
    'Fizik': 14,
    'Kimya': 13,
    'Biyoloji': 13,
  };
}