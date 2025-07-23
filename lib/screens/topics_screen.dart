import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedExamType = 'TYT';
  String? _selectedSubject;
  List<Topic> _topics = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadTopics();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadTopics() {
    if (_selectedSubject != null) {
      final savedTopics = StorageService.getTopicProgress(_selectedExamType, _selectedSubject!);
      final allTopics = _getSubjectTopics();
      
      setState(() {
        _topics = allTopics.map((topicName) {
          final savedTopic = savedTopics.firstWhere(
            (t) => t.name == topicName,
            orElse: () => Topic(name: topicName),
          );
          return savedTopic;
        }).toList();
      });
    }
  }

  List<String> _getSubjectTopics() {
    if (_selectedSubject == null) return [];
    
    final topicsMap = _selectedExamType == 'TYT' 
        ? AppConstants.tytTopics 
        : AppConstants.aytTopics;
    
    return topicsMap[_selectedSubject!] ?? [];
  }

  Map<String, List<String>> get _currentTopicsMap {
    return _selectedExamType == 'TYT' 
        ? AppConstants.tytTopics 
        : AppConstants.aytTopics;
  }

  List<String> get _subjects {
    return _currentTopicsMap.keys.toList();
  }

  double _getSubjectCompletion(String subject) {
    final topics = StorageService.getTopicProgress(_selectedExamType, subject);
    final allTopics = _currentTopicsMap[subject] ?? [];
    
    if (allTopics.isEmpty) return 0;
    
    int completedCount = 0;
    for (String topicName in allTopics) {
      final topic = topics.firstWhere(
        (t) => t.name == topicName,
        orElse: () => Topic(name: topicName),
      );
      if (topic.isCompleted) completedCount++;
    }
    
    return (completedCount / allTopics.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konular'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildExamTypeSelector(),
            Expanded(
              child: _selectedSubject == null 
                  ? _buildSubjectsList() 
                  : _buildTopicsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamTypeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
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
                      Icons.quiz,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        _selectedSubject = null;
                        _topics.clear();
                      });
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToggleButton('AYT', _selectedExamType == 'AYT', () {
                      setState(() {
                        _selectedExamType = 'AYT';
                        _selectedSubject = null;
                        _topics.clear();
                      });
                    }),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildSubjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        final completion = _getSubjectCompletion(subject);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedSubject = subject;
              });
              _loadTopics();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSubjectIcon(subject),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearPercentIndicator(
                          lineHeight: 6,
                          percent: completion / 100,
                          backgroundColor: Colors.grey[300],
                          linearGradient: AppTheme.primaryGradient,
                          barRadius: const Radius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${completion.toInt()}% tamamlandı',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.primaryPurple,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopicsList() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedSubject = null;
                            _topics.clear();
                          });
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(4),
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
                      Expanded(
                        child: Text(
                          _selectedSubject!,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_topics.where((t) => t.isCompleted).length}/${_topics.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // İlerleme çubuğu
                  LinearPercentIndicator(
                    lineHeight: 8,
                    percent: _topics.isEmpty ? 0 : _topics.where((t) => t.isCompleted).length / _topics.length,
                    backgroundColor: Colors.grey[300],
                    linearGradient: AppTheme.primaryGradient,
                    barRadius: const Radius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Konular listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                child: InkWell(
                  onTap: () => _toggleTopic(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: topic.isCompleted 
                                ? AppTheme.primaryGradient
                                : null,
                            color: topic.isCompleted 
                                ? null
                                : Colors.grey[300],
                          ),
                          child: Icon(
                            topic.isCompleted 
                                ? Icons.check 
                                : Icons.radio_button_unchecked,
                            color: topic.isCompleted 
                                ? Colors.white 
                                : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  decoration: topic.isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                  color: topic.isCompleted 
                                      ? Colors.grey[600] 
                                      : null,
                                ),
                              ),
                              if (topic.questionsSolved > 0) 
                                Text(
                                  '${topic.questionsSolved} soru çözüldü',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (topic.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Tamamlandı',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  void _toggleTopic(int index) {
    setState(() {
      _topics[index].isCompleted = !_topics[index].isCompleted;
    });
    
    // Değişiklikleri kaydet
    StorageService.saveTopicProgress(_selectedExamType, _selectedSubject!, _topics);
    
    // Başarı mesajı göster
    final message = _topics[index].isCompleted 
        ? 'Konu tamamlandı! 🎉'
        : 'Konu tamamlanmamış olarak işaretlendi';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _topics[index].isCompleted ? Icons.check_circle : Icons.undo,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: _topics[index].isCompleted 
            ? Colors.green 
            : Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}