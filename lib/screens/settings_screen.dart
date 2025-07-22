import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import 'net_calculator_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime _yksDate = AppConstants.yksDate;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _yksDate = StorageService.getYksDate() ?? AppConstants.yksDate;
      _isPremium = StorageService.getPremiumStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildToolsSection(),
            const SizedBox(height: 24),
            _buildPremiumSection(),
            const SizedBox(height: 24),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final daysLeft = _yksDate.difference(DateTime.now()).inDays;
    
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'YKS Adayı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              daysLeft > 0 
                  ? '$daysLeft gün kaldı'
                  : daysLeft == 0
                      ? 'Bugün sınav günü!'
                      : 'Sınav geçti',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (_isPremium) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Premium Üye',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genel Ayarlar',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.calendar_today,
                title: 'YKS Tarihi',
                subtitle: DateFormat('dd MMMM yyyy', 'tr_TR').format(_yksDate),
                onTap: _showDatePicker,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                title: 'Tema',
                subtitle: widget.isDarkMode ? 'Karanlık Mod' : 'Açık Mod',
                onTap: widget.onThemeChanged,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Bildirimler',
                subtitle: 'Hatırlatma ve motivasyon bildirimleri',
                onTap: () {
                  // TODO: Bildirim ayarları
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bildirim ayarları yakında!')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Araçlar',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.calculate,
                title: 'Net Hesaplayıcı',
                subtitle: 'Hızlı net hesaplama aracı',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NetCalculatorScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.backup,
                title: 'Verileri Yedekle',
                subtitle: 'Verilerinizi yedekleyin ve geri yükleyin',
                onTap: () {
                  // TODO: Yedekleme sistemi
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yedekleme özelliği yakında!')),
                  );
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.delete_sweep,
                title: 'Verileri Temizle',
                subtitle: 'Tüm verileri sıfırla',
                onTap: _showClearDataDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumSection() {
    if (_isPremium) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Premium Üyesiniz!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reklamları kaldırdınız ve tüm premium özelliklere erişiminiz var',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Premium\'a Geçin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppConstants.premiumPrice.toInt()} TL',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    _buildPremiumFeature('Reklamları kaldır'),
                    _buildPremiumFeature('Gelişmiş istatistikler'),
                    _buildPremiumFeature('Sınırsız kitap ekleme'),
                    _buildPremiumFeature('Özel temalar'),
                    _buildPremiumFeature('Öncelikli destek'),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _purchasePremium,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Text(
                        'Premium Satın Al',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hakkında',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.info,
                title: 'Uygulama Hakkında',
                subtitle: 'Versiyon 1.0.0',
                onTap: _showAboutDialog,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Gizlilik Politikası',
                subtitle: 'Verileriniz nasıl korunur',
                onTap: () {
                  // TODO: Gizlilik politikası
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gizlilik politikası yakında!')),
                  );
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.help,
                title: 'Yardım ve Destek',
                subtitle: 'SSS ve destek',
                onTap: () {
                  // TODO: Yardım sayfası
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yardım sayfası yakında!')),
                  );
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.star_rate,
                title: 'Uygulamayı Değerlendir',
                subtitle: 'Play Store\'da değerlendirin',
                onTap: () {
                  // TODO: Play Store rating
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Play Store\'a yönlendiriliyor...')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryPurple,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _yksDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    if (selectedDate != null) {
      setState(() {
        _yksDate = selectedDate;
      });
      await StorageService.saveYksDate(selectedDate);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('YKS tarihi güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Temizle'),
        content: const Text(
          'Bu işlem tüm çalışma verilerinizi, kitaplarınızı ve ayarlarınızı silecektir. Bu işlem geri alınamaz!\n\nDevam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Tüm verileri temizle
              final prefs = StorageService.prefs;
              await prefs.clear();
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tüm veriler temizlendi!'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context); // Settings sayfasından çık
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Temizle', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _purchasePremium() {
    // TODO: Google Play In-App Purchase entegrasyonu
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Satın Al'),
        content: const Text(
          'Premium özellikler için Google Play Store üzerinden ödeme yapılacaktır. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Simüle edilmiş satın alma
              await Future.delayed(const Duration(seconds: 2));
              
              await StorageService.setPremiumStatus(true);
              setState(() {
                _isPremium = true;
              });
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Premium satın alındı! Teşekkürler! 🎉'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'YKS Hazırlık',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.school,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'YKS hazırlık sürecinizi organize etmenize yardımcı olan kapsamlı bir uygulama.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Özellikler:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Çalışma takibi'),
        const Text('• Soru ve deneme girişi'),
        const Text('• İstatistiksel analiz'),
        const Text('• Konu ve kitap yönetimi'),
        const Text('• Pomodoro timer'),
        const Text('• Net hesaplayıcı'),
      ],
    );
  }
}