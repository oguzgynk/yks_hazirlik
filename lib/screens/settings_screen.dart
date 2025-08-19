// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import 'net_calculator_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String currentTheme;
  final ValueChanged<String> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime _yksDate = AppConstants.yksDate;
  // bool _isPremium = false; // Premium durumu kaldırıldı
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _yksDate = StorageService.getYksDate() ?? AppConstants.yksDate;
      // _isPremium = StorageService.getPremiumStatus(); // Premium kontrolü kaldırıldı
      _notificationsEnabled = StorageService.getNotificationEnabled();
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
            // _buildPremiumSection(), // Premium bölümü tamamen kaldırıldı
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
          gradient: AppThemes.getGradient(widget.currentTheme),
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
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
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
            // Premium rozeti kaldırıldı
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
                icon: Icons.palette,
                title: 'Uygulama Teması',
                subtitle: AppThemes.themeDisplayNames[widget.currentTheme] ?? 'Aydınlık',
                onTap: _showThemeSelectionDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                title: const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Ajanda hatırlatıcıları'),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    await StorageService.setNotificationEnabled(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showThemeSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tema Seç', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              // Tema kısıtlamaları tamamen kaldırıldı
              ...AppThemes.themeDisplayNames.entries.map((entry) {
                final themeName = entry.key;
                final themeDisplayName = entry.value;

                return ListTile(
                  onTap: () { // Her zaman tıklanabilir
                    widget.onThemeChanged(themeName);
                    Navigator.pop(context);
                  },
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: AppThemes.getGradient(themeName),
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).dividerColor, width: 2)
                    ),
                  ),
                  title: Text(themeDisplayName),
                  trailing: widget.currentTheme == themeName
                      ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                      : null, // Kilit ikonu ve diğer kontroller kaldırıldı
                );
              }).toList(),
               const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Araçlar', style: Theme.of(context).textTheme.headlineSmall),
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
                    MaterialPageRoute(builder: (context) => const NetCalculatorScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // _buildPremiumSection metodu tamamen silindi.

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hakkında', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.info,
                title: 'Uygulama Hakkında',
                subtitle: 'Versiyon 2.0.0',
                onTap: _showAboutDialog,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.star_rate,
                title: 'Uygulamayı Değerlendir',
                subtitle: 'Play Store\'da değerlendirin',
                onTap: () {
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

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('tr', 'TR'),
    );

    if (selectedDate != null) {
      setState(() => _yksDate = selectedDate);
      await StorageService.saveYksDate(selectedDate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('YKS tarihi güncellendi!'), backgroundColor: Colors.green));
      }
    }
  }

  // _purchasePremium metodu tamamen silindi.

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'YKS Asistanım',
      applicationVersion: '2.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppThemes.getGradient(widget.currentTheme),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.school, color: Colors.white, size: 30),
      ),
      children: [
        const Text('YKS Asistanım sürecinizi organize etmenize yardımcı olan kapsamlı bir uygulama.'),
      ],
    );
  }
}