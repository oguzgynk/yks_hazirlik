// lib/screens/net_calculator_screen.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';

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
      final subjects = _getQuestionCounts();
      
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

  Map<String, int> _getQuestionCounts() {
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
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              icon: Icon(Icons.speed),
              text: 'Hızlı Hesaplama',
            ),
            Tab(
              icon: Icon(Icons.calculate),
              text: 'Detaylı Hesaplama',
            ),
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
            elevation: 8,
            shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppThemes.getGradient(StorageService.getTheme()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.speed, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hızlı Net Hesaplama', style: Theme.of(context).textTheme.headlineSmall),
                            Text(
                              'Doğru ve yanlış sayısını girerek hızlıca net hesaplayın',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildInputField(controller: _quickCorrectController, label: 'Doğru', icon: Icons.check_circle, color: Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInputField(controller: _quickWrongController, label: 'Yanlış', icon: Icons.cancel, color: Colors.red)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInputField(controller: _quickEmptyController, label: 'Boş', icon: Icons.radio_button_unchecked, color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 12,
            shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppThemes.getGradient(StorageService.getTheme()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.calculate, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text('Net Sonuç', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(
                    _quickNet.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Net = Doğru - (Yanlış ÷ 4)',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('İpuçları', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTip('Her 4 yanlış 1 doğruyu götürür'),
                  _buildTip('Boş sorular hesaplamayı etkilemez'),
                  _buildTip('Net sayınız negatif de olabilir'),
                  _buildTip('Emin olmadığınız sorularda risk almayın'),
                  _buildTip('Yüksek net için doğru/yanlış dengesine dikkat edin'),
                ],
              ),
            ),
          ),
        ],
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: color.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: Theme.of(context).textTheme.bodyMedium)),
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
          _buildDetailedResultCard(),
          const SizedBox(height: 20),
          _buildSubjectInputs(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildExamTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sınav Türü',
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
        child: Container(
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

  Widget _buildDetailedResultCard() {
    return Card(
      elevation: 8,
      shadowColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
              child: const Icon(Icons.assignment_turned_in, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Toplam Net', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              _totalNet.toStringAsFixed(2),
              style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_selectedExamType - Toplam $_totalQuestions soru',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectInputs() {
    final questionCounts = _getQuestionCounts();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Ders Bazlı Giriş', style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: 16),
        ...questionCounts.entries.map((entry) {
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getSubjectIcon(subject), color: Theme.of(context).primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subject,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$totalQuestions soru',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildSubjectInputField(subject: subject, type: 'correct', label: 'Doğru', icon: Icons.check_circle, color: Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSubjectInputField(subject: subject, type: 'wrong', label: 'Yanlış', icon: Icons.cancel, color: Colors.red)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSubjectInputField(subject: subject, type: 'empty', label: 'Boş', icon: Icons.radio_button_unchecked, color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net: ${(_subjectInputs[subject]!['correct']! - (_subjectInputs[subject]!['wrong']! / 4)).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        Text(
                          'Toplam: ${_subjectInputs[subject]!['correct']! + _subjectInputs[subject]!['wrong']! + _subjectInputs[subject]!['empty']!}/$totalQuestions',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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

  Widget _buildSubjectInputField({required String subject, required String type, required String label, required IconData icon, required Color color}) {
    return TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color, fontSize: 12),
        prefixIcon: Icon(icon, color: color, size: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: color.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: color)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        isDense: true,
      ),
      onChanged: (value) {
        _subjectInputs[subject]![type] = int.tryParse(value) ?? 0;
        _calculateTotals();
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _initializeInputs(); // Bu metod hem state'i hem de controllerları sıfırlar
              _quickCorrectController.clear();
              _quickWrongController.clear();
              _quickEmptyController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm değerler temizlendi'), backgroundColor: Colors.orange),
              );
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Temizle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sonuç kopyalandı: ${_totalNet.toStringAsFixed(2)} net'), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Paylaş'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
  
  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Türkçe': return Icons.menu_book;
      case 'Sosyal Bilimler': return Icons.public;
      case 'Matematik': return Icons.calculate;
      case 'Fen Bilimleri': return Icons.science;
      case 'Türk Dili ve Edebiyatı-Sosyal Bilimler-1': return Icons.library_books;
      case 'Sosyal Bilimler-2': return Icons.history_edu;
      default: return Icons.subject;
    }
  }
}