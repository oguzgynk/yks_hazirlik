import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class StudyTimeEntryScreen extends StatefulWidget {
  const StudyTimeEntryScreen({super.key});

  @override
  State<StudyTimeEntryScreen> createState() => _StudyTimeEntryScreenState();
}

class _StudyTimeEntryScreenState extends State<StudyTimeEntryScreen> {
  String _selectedExamType = 'TYT';
  String? _selectedSubject;
  String? _selectedTopic;
  
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();
  
  int _totalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _hoursController.addListener(_calculateTime);
    _minutesController.addListener(_calculateTime);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _calculateTime() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    
    setState(() {
      _totalMinutes = (hours * 60) + minutes;
    });
  }

  Map<String, List<String>> get _currentTopics {
    return _selectedExamType == 'TYT' 
        ? AppConstants.tytTopics 
        : AppConstants.aytTopics;
  }

  List<String> get _subjects {
    return _currentTopics.keys.toList();
  }

  List<String> get _topics {
    if (_selectedSubject == null) return [];
    return _currentTopics[_selectedSubject!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Süresi Girişi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExamTypeSelector(),
            const SizedBox(height: 24),
            _buildSubjectSelector(),
            const SizedBox(height: 24),
            _buildTopicSelector(),
            const SizedBox(height: 24),
            _buildTimeInputs(),
            const SizedBox(height: 24),
            _buildResultCard(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sınav Türü',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton('TYT', _selectedExamType == 'TYT', () {
                    setState(() {
                      _selectedExamType = 'TYT';
                      _selectedSubject = null;
                      _selectedTopic = null;
                    });
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleButton('AYT', _selectedExamType == 'AYT', () {
                    setState(() {
                      _selectedExamType = 'AYT';
                      _selectedSubject = null;
                      _selectedTopic = null;
                    });
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ders Seçin',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                hintText: 'Ders seçin...',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                  _selectedTopic = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konu Seçin',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTopic,
              decoration: const InputDecoration(
                hintText: 'Konu seçin...',
                prefixIcon: Icon(Icons.topic),
                border: OutlineInputBorder(),
              ),
              items: _topics.map((topic) {
                return DropdownMenuItem(
                  value: topic,
                  child: Text(
                    topic,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _selectedSubject == null ? null : (value) {
                setState(() {
                  _selectedTopic = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Çalışma Süresi',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Saat',
                      prefixIcon: Icon(Icons.access_time, color: AppTheme.primaryBlue),
                      border: OutlineInputBorder(),
                      suffixText: 'sa',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Dakika',
                      prefixIcon: Icon(Icons.timer, color: AppTheme.primaryPurple),
                      border: OutlineInputBorder(),
                      suffixText: 'dk',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Çalışma süreniz günlük istatistiklerinize eklenir',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.secondaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text(
              'Toplam Çalışma Süresi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _totalMinutes > 0 
                ? '${(_totalMinutes / 60).floor()}sa ${_totalMinutes % 60}dk'
                : '0sa 0dk',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$_totalMinutes dakika',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final isValid = _selectedSubject != null && 
                   _selectedTopic != null && 
                   _totalMinutes > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? _saveSession : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: Container(
          decoration: isValid ? const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ) : null,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Kaydet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isValid ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSession() async {
    if (_totalMinutes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çalışma süresi girmelisiniz')),
      );
      return;
    }

    final session = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _selectedSubject!,
      topic: _selectedTopic!,
      duration: _totalMinutes,
      correctAnswers: 0,
      wrongAnswers: 0,
      emptyAnswers: 0,
      date: DateTime.now(),
    );

    await StorageService.saveStudySession(session);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Çalışma süresi kaydedildi! ${(_totalMinutes / 60).toStringAsFixed(1)} saat'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}