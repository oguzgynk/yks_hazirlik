import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/theme.dart'; // Eğer AppTheme kullanılıyorsa
import '../services/storage_service.dart';
import '../models/data_models.dart';

// Import sıralaması ve diğer tanımlamalar bu noktadan sonra başlamalı

class ExamEntryScreen extends StatefulWidget {
  const ExamEntryScreen({super.key});

  @override
  State<ExamEntryScreen> createState() => _ExamEntryScreenState();
}

class _ExamEntryScreenState extends State<ExamEntryScreen> {
  String _selectedExamType = 'TYT';
  Map<String, Map<String, int>> _subjectInputs = {};
  double _totalNet = 0.0;
  int _totalQuestions = 0;

  // Yeni alanlar - Sınıfın içinde tanımlanmalı
  late final TextEditingController _examNameController; // late final olarak tanımlandı
  late DateTime _selectedDate; // late olarak tanımlandı

  @override
  void initState() {
    super.initState();
    _examNameController = TextEditingController(); // initState içinde initialize edildi
    _selectedDate = DateTime.now(); // initState içinde başlangıç değeri atandı
    _initializeInputs();
    // Varsayılan deneme adı
    _examNameController.text = '${_selectedExamType} Denemesi ${DateFormat('dd/MM').format(DateTime.now())}';
  }

  @override
  void dispose() {
    _examNameController.dispose();
    super.dispose();
  }

  // _buildExamInfoSection metodunu sınıfın içine taşıdık
  Widget _buildExamInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deneme Bilgileri',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _examNameController, // Artık erişilebilir
              decoration: const InputDecoration(
                labelText: 'Deneme Adı',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate, // Metod artık erişilebilir
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Deneme Tarihi',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate), // Artık erişilebilir
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _selectDate metodunu sınıfın içine taşıdık
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context, // Artık erişilebilir
      initialDate: _selectedDate, // Artık erişilebilir
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() { // Artık erişilebilir
        _selectedDate = picked;
      });
    }
  }

  void _initializeInputs() {
    setState(() {
      _subjectInputs.clear();
      final subjects = _selectedExamType == 'TYT'
          ? AppConstants.tytQuestionCounts
          : AppConstants.aytQuestionCounts;

      for (String subject in subjects.keys) {
        _subjectInputs[subject] = {
          'correct': 0,
          'wrong': 0,
          'empty': 0,
        };
      }

      // Deneme adını güncelle
      _examNameController.text = '${_selectedExamType} Denemesi ${DateFormat('dd/MM').format(DateTime.now())}';
    });
    _calculateTotals();
  }

  void _calculateTotals() {
    double totalNet = 0.0;
    int totalQuestions = 0;

    for (String subject in _subjectInputs.keys) {
      final correct = _subjectInputs[subject]!['correct']!;
      final wrong = _subjectInputs[subject]!['wrong']!;
      final empty = _subjectInputs[subject]!['empty']!;

      totalNet += correct - (wrong / 4);
      totalQuestions += correct + wrong + empty;
    }

    setState(() {
      _totalNet = totalNet;
      _totalQuestions = totalQuestions;
    });
  }

  Map<String, int> get _questionCounts {
    return _selectedExamType == 'TYT'
        ? AppConstants.tytQuestionCounts
        : AppConstants.aytQuestionCounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deneme Girişi'),
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
            _buildExamInfoSection(), // Şimdi sınıfın içinde
            const SizedBox(height: 24),
            _buildResultCard(),
            const SizedBox(height: 24),
            _buildSubjectInputs(),
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
              'Deneme Türü',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton('TYT', _selectedExamType == 'TYT', () {
                    setState(() {
                      _selectedExamType = 'TYT';
                    });
                    _initializeInputs();
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleButton('AYT', _selectedExamType == 'AYT', () {
                    setState(() {
                      _selectedExamType = 'AYT';
                    });
                    _initializeInputs();
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
              Icons.assignment_turned_in,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text(
              'Toplam Net',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _totalNet.toStringAsFixed(2),
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

  Widget _buildSubjectInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ders Bazlı Giriş',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ..._questionCounts.entries.map((entry) {
          final subject = entry.key;
          final totalQuestions = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        subject,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '$totalQuestions soru',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Doğru',
                            prefixIcon: Icon(Icons.check_circle, color: Colors.green),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            _subjectInputs[subject]!['correct'] = int.tryParse(value) ?? 0;
                            _calculateTotals();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Yanlış',
                            prefixIcon: Icon(Icons.cancel, color: Colors.red),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            _subjectInputs[subject]!['wrong'] = int.tryParse(value) ?? 0;
                            _calculateTotals();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Boş',
                            prefixIcon: Icon(Icons.radio_button_unchecked, color: Colors.orange),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            _subjectInputs[subject]!['empty'] = int.tryParse(value) ?? 0;
                            _calculateTotals();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net: ${(_subjectInputs[subject]!['correct']! - (_subjectInputs[subject]!['wrong']! / 4)).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryPurple,
                            ),
                      ),
                      Text(
                        'Toplam: ${_subjectInputs[subject]!['correct']! + _subjectInputs[subject]!['wrong']! + _subjectInputs[subject]!['empty']!}/$totalQuestions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSaveButton() {
    final isValid = _totalQuestions > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? _saveExam : null,
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
            'Denemeyi Kaydet',
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

  Future<void> _saveExam() async {
    if (_totalQuestions == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir soru girmelisiniz')),
      );
      return;
    }

    if (_examNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deneme adı girmelisiniz')),
      );
      return;
    }

    Map<String, StudySession> subjectResults = {};

    for (String subject in _subjectInputs.keys) {
      final correct = _subjectInputs[subject]!['correct']!;
      final wrong = _subjectInputs[subject]!['wrong']!;
      final empty = _subjectInputs[subject]!['empty']!;

      if (correct + wrong + empty > 0) {
        subjectResults[subject] = StudySession(
          id: '${DateTime.now().millisecondsSinceEpoch}_$subject',
          subject: subject,
          topic: 'Deneme',
          duration: 0,
          correctAnswers: correct,
          wrongAnswers: wrong,
          emptyAnswers: empty,
          date: _selectedDate,
          isExam: true,
          examType: _selectedExamType,
        );

        // Her dersin sonucunu ayrı ayrı kaydet
        await StorageService.saveStudySession(subjectResults[subject]!);
      }
    }

    // Deneme sonucunu kaydet
    final examResult = ExamResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      examType: _selectedExamType,
      examName: _examNameController.text.trim(),
      examDate: _selectedDate,
      subjectResults: subjectResults,
      createdDate: DateTime.now(),
    );

    await StorageService.saveExamResult(examResult);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${examResult.examName} kaydedildi! Net: ${_totalNet.toStringAsFixed(2)}'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}