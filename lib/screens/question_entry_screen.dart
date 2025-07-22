import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class QuestionEntryScreen extends StatefulWidget {
  const QuestionEntryScreen({super.key});

  @override
  State<QuestionEntryScreen> createState() => _QuestionEntryScreenState();
}

class _QuestionEntryScreenState extends State<QuestionEntryScreen> {
  String _selectedExamType = 'TYT';
  String? _selectedSubject;
  String? _selectedTopic;
  
  final _correctController = TextEditingController();
  final _wrongController = TextEditingController();
  final _emptyController = TextEditingController();
  
  double _netScore = 0.0;
  int _totalQuestions = 0;

  @override
  void initState() {
    super.initState();
    _correctController.addListener(_calculateNet);
    _wrongController.addListener(_calculateNet);
    _emptyController.addListener(_calculateNet);
  }

  @override
  void dispose() {
    _correctController.dispose();
    _wrongController.dispose();
    _emptyController.dispose();
    super.dispose();
  }

  void _calculateNet() {
    final correct = int.tryParse(_correctController.text) ?? 0;
    final wrong = int.tryParse(_wrongController.text) ?? 0;
    final empty = int.tryParse(_emptyController.text) ?? 0;
    
    setState(() {
      _netScore = correct - (wrong / 4);
      _totalQuestions = correct + wrong + empty;
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
        title: const Text('Soru Girişi'),
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
            _buildQuestionInputs(),
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

  Widget _buildQuestionInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soru Bilgileri',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _correctController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Doğru',
                      prefixIcon: Icon(Icons.check_circle, color: Colors.green),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _wrongController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Yanlış',
                      prefixIcon: Icon(Icons.cancel, color: Colors.red),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _emptyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Boş',
                      prefixIcon: Icon(Icons.radio_button_unchecked, color: Colors.orange),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
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
              Icons.calculate,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text(
              'Net Sonuç',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _netScore.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Toplam $_totalQuestions soru',
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
                   _totalQuestions > 0;

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
    final correct = int.tryParse(_correctController.text) ?? 0;
    final wrong = int.tryParse(_wrongController.text) ?? 0;
    final empty = int.tryParse(_emptyController.text) ?? 0;

    if (correct + wrong + empty == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir soru girmelisiniz')),
      );
      return;
    }

    final session = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _selectedSubject!,
      topic: _selectedTopic!,
      duration: 0, // Soru girişinde süre yok
      correctAnswers: correct,
      wrongAnswers: wrong,
      emptyAnswers: empty,
      date: DateTime.now(),
    );

    await StorageService.saveStudySession(session);

    // Konu ilerlemesini güncelle
    final topicProgress = StorageService.getTopicProgress(_selectedExamType, _selectedSubject!);
    final topicIndex = topicProgress.indexWhere((t) => t.name == _selectedTopic);
    
    if (topicIndex != -1) {
      topicProgress[topicIndex].questionsSolved += (correct + wrong + empty);
    } else {
      topicProgress.add(Topic(
        name: _selectedTopic!,
        questionsSolved: correct + wrong + empty,
      ));
    }
    
    await StorageService.saveTopicProgress(_selectedExamType, _selectedSubject!, topicProgress);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Soru girişi kaydedildi! Net: ${_netScore.toStringAsFixed(2)}'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}