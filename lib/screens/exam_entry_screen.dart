import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class ExamEntryScreen extends StatefulWidget {
  const ExamEntryScreen({super.key});

  @override
  State<ExamEntryScreen> createState() => _ExamEntryScreenState();
}

class _ExamEntryScreenState extends State<ExamEntryScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  String _selectedExamType = 'TYT';
  Map<String, Map<String, int>> _subjectInputs = {};
  double _totalNet = 0.0;
  int _totalQuestions = 0;

  late final TextEditingController _examNameController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _examNameController = TextEditingController();
    _selectedDate = DateTime.now();
    _setupAnimations();
    _initializeInputs();
    // Varsayılan deneme adı
    _examNameController.text = '${_selectedExamType} Denemesi ${DateFormat('dd/MM').format(DateTime.now())}';
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
    _examNameController.dispose();
    super.dispose();
  }

  Widget _buildExamInfoSection() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple.withOpacity(0.05),
              AppTheme.primaryBlue.withOpacity(0.05),
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
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Deneme Bilgileri',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _examNameController,
                decoration: const InputDecoration(
                  labelText: 'Deneme Adı',
                  prefixIcon: Icon(Icons.edit, color: AppTheme.primaryPurple),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deneme Tarihi',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppTheme.primaryPurple,
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
                    _buildExamInfoSection(),
                    const SizedBox(height: 24),
                    _buildResultCard(),
                    const SizedBox(height: 24),
                    _buildSubjectInputs(),
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
              AppTheme.accentBlue.withOpacity(0.05),
              AppTheme.secondaryPurple.withOpacity(0.05),
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
                    gradient: AppTheme.secondaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Deneme Türü',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 8,
      shadowColor: AppTheme.secondaryPurple.withOpacity(0.3),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.secondaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.assignment_turned_in,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Toplam Net',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _totalNet.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Toplam $_totalQuestions soru',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Ders Bazlı Giriş',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 16),
        ..._questionCounts.entries.map((entry) {
          final subject = entry.key;
          final totalQuestions = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
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
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getSubjectIcon(subject),
                          color: AppTheme.primaryPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subject,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$totalQuestions soru',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          subject: subject,
                          type: 'correct',
                          label: 'Doğru',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          subject: subject,
                          type: 'wrong',
                          label: 'Yanlış',
                          icon: Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          subject: subject,
                          type: 'empty',
                          label: 'Boş',
                          icon: Icons.radio_button_unchecked,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPurple.withOpacity(0.1),
                          AppTheme.primaryBlue.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
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
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInputField({
    required String subject,
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color, fontSize: 12),
          prefixIcon: Icon(icon, color: color, size: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
        onChanged: (value) {
          _subjectInputs[subject]![type] = int.tryParse(value) ?? 0;
          _calculateTotals();
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    final isValid = _totalQuestions > 0 && _examNameController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isValid ? _saveExam : null,
        icon: const Icon(Icons.save),
        label: const Text(
          'Denemeyi Kaydet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: isValid ? AppTheme.primaryPurple : Colors.grey[300],
          foregroundColor: isValid ? Colors.white : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isValid ? 4 : 0,
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Matematik':
        return Icons.calculate;
      case 'Türkçe':
      case 'Türk Dili ve Edebiyatı':
        return Icons.menu_book;
      case 'Geometri':
        return Icons.square_foot;
      case 'Fizik':
        return Icons.science;
      case 'Kimya':
        return Icons.biotech;
      case 'Biyoloji':
        return Icons.eco;
      case 'Tarih':
      case 'Tarih-1':
      case 'Tarih-2':
        return Icons.history_edu;
      case 'Coğrafya':
      case 'Coğrafya-1':
      case 'Coğrafya-2':
        return Icons.public;
      case 'Felsefe':
        return Icons.psychology;
      case 'Din Kültürü':
        return Icons.mosque;
      default:
        return Icons.subject;
    }
  }

  Future<void> _saveExam() async {
    if (_totalQuestions == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('En az bir soru girmelisiniz'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_examNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Deneme adı girmelisiniz'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${examResult.examName} kaydedildi! Net: ${_totalNet.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}