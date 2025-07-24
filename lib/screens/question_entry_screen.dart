// lib/screens/question_entry_screen.dart

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

class _QuestionEntryScreenState extends State<QuestionEntryScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
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
    _setupAnimations();
    _correctController.addListener(_calculateNet);
    _wrongController.addListener(_calculateNet);
    _emptyController.addListener(_calculateNet);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _slideAnimation.value)),
            child: Opacity(
              opacity: _slideAnimation.value,
              child: SingleChildScrollView(
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamTypeSelector() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppThemes.getGradient(StorageService.getTheme()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.quiz, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Sınav Türü', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? AppThemes.getGradient(StorageService.getTheme()) : null,
            color: isSelected ? null : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school, color: Theme.of(context).colorScheme.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Ders Seçin', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  hintText: 'İsteğe bağlı - Ders seçin...',
                  prefixIcon: Icon(Icons.school, color: Theme.of(context).colorScheme.secondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Ders seçilmeyecek')),
                  ...(_subjects.map((subject) {
                    return DropdownMenuItem(value: subject, child: Text(subject));
                  }).toList()),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                    _selectedTopic = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.topic, color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Konu Seçin', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedTopic,
                decoration: InputDecoration(
                  hintText: 'İsteğe bağlı - Konu seçin...',
                  prefixIcon: Icon(Icons.topic, color: Colors.teal),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Konu seçilmeyecek')),
                  ...(_topics.map((topic) {
                    return DropdownMenuItem(
                      value: topic,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(topic, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 14)),
                      ),
                    );
                  }).toList()),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTopic = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInputs() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: Theme.of(context).primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Soru Bilgileri', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildInputField(controller: _correctController, label: 'Doğru', icon: Icons.check_circle, color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField(controller: _wrongController, label: 'Yanlış', icon: Icons.cancel, color: Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField(controller: _emptyController, label: 'Boş', icon: Icons.radio_button_unchecked, color: Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, required Color color}) {
    return SizedBox(
      height: 70,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color, fontSize: 12),
          prefixIcon: Icon(icon, color: color, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: color.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 8,
      shadowColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.calculate, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Net Sonuç', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_netScore.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('Toplam $_totalQuestions soru', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final isValid = _totalQuestions > 0;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isValid ? _saveSession : null,
        icon: const Icon(Icons.save),
        label: const Text('Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: isValid ? Theme.of(context).primaryColor : Colors.grey[300],
          foregroundColor: isValid ? Colors.white : Colors.grey[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isValid ? 4 : 0,
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
        SnackBar(
          content: const Row(children: [Icon(Icons.warning, color: Colors.white), SizedBox(width: 12), Text('En az bir soru girmelisiniz')]),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final session = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _selectedSubject ?? 'Genel',
      topic: _selectedTopic ?? 'Genel',
      duration: 0,
      correctAnswers: correct,
      wrongAnswers: wrong,
      emptyAnswers: empty,
      date: DateTime.now(),
    );

    await StorageService.saveStudySession(session);

    if (_selectedSubject != null && _selectedTopic != null) {
      final topicProgress = StorageService.getTopicProgress(_selectedExamType, _selectedSubject!);
      final topicIndex = topicProgress.indexWhere((t) => t.name == _selectedTopic);
      
      if (topicIndex != -1) {
        topicProgress[topicIndex].questionsSolved += (correct + wrong + empty);
      } else {
        topicProgress.add(Topic(name: _selectedTopic!, questionsSolved: correct + wrong + empty));
      }
      
      await StorageService.saveTopicProgress(_selectedExamType, _selectedSubject!, topicProgress);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Soru girişi kaydedildi! Net: ${_netScore.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }
}