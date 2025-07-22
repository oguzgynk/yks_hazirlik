import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class NetCalculatorScreen extends StatefulWidget {
  const NetCalculatorScreen({super.key});

  @override
  State<NetCalculatorScreen> createState() => _NetCalculatorScreenState();
}

class _NetCalculatorScreenState extends State<NetCalculatorScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  String _selectedExamType = 'TYT';
  Map<String, Map<String, int>> _subjectInputs = {};
  double _totalNet = 0.0;
  int _totalQuestions = 0;
  
  // Hızlı hesaplama için
  final _quickCorrectController = TextEditingController();
  final _quickWrongController = TextEditingController();
  final _quickEmptyController = TextEditingController();
  double _quickNet = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeInputs();
    _setupQuickCalculator();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quickCorrectController.dispose();
    _quickWrongController.dispose();
    _quickEmptyController.dispose();
    super.dispose();
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
    });
    _calculateTotals();
  }

  void _setupQuickCalculator() {
    _quickCorrectController.addListener(_calculateQuickNet);
    _quickWrongController.addListener(_calculateQuickNet);
    _quickEmptyController.addListener(_calculateQuickNet);
  }

  void _calculateQuickNet() {
    final correct = int.tryParse(_quickCorrectController.text) ?? 0;
    final wrong = int.tryParse(_quickWrongController.text) ?? 0;
    
    setState(() {
      _quickNet = correct - (wrong / 4);
    });
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
        title: const Text('Net Hesaplayıcı'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPurple,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Hızlı Hesaplama'),
            Tab(text: 'Detaylı Hesaplama'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickCalculator(),
          _buildDetailedCalculator(),
        ],
      ),
    );
  }

  Widget _buildQuickCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hızlı Net Hesaplama',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Doğru ve yanlış sayısını girerek hızlıca net hesaplayın',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quickCorrectController,
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
                          controller: _quickWrongController,
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
                          controller: _quickEmptyController,
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
          ),
          const SizedBox(height: 20),
          
          // Sonuç kartı
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.calculate,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Net Sonuç',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _quickNet.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Net = Doğru - (Yanlış ÷ 4)',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // İpuçları kartı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Net Hesaplama İpuçları',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTip('• Her 4 yanlış 1 doğruyu götürür'),
                  _buildTip('• Boş sorular hesaplamayı etkilemez'),
                  _buildTip('• Net sayınız negatif de olabilir'),
                  _buildTip('• Emin olmadığınız sorularda risk almayın'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildExamTypeSelector(),
          const SizedBox(height: 20),
          _buildResultCard(),
          const SizedBox(height: 20),
          _buildSubjectInputs(),
          const SizedBox(height: 20),
          _buildClearButton(),
        ],
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
              '${_selectedExamType} - Toplam $_totalQuestions soru',
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
                      Icon(
                        _getSubjectIcon(subject),
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
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

  Widget _buildClearButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            for (String subject in _subjectInputs.keys) {
              _subjectInputs[subject] = {
                'correct': 0,
                'wrong': 0,
                'empty': 0,
              };
            }
          });
          _calculateTotals();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tüm değerler temizlendi'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Temizle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        tip,
        style: Theme.of(context).textTheme.bodyMedium,
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
}