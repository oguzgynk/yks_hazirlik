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

class _TopicsScreenState extends State<TopicsScreen> {
  String _selectedExamType = 'TYT';
  String? _selectedSubject;
  List<Topic> _topics = [];

  @override
  void initState() {
    super.initState();
    _loadTopics();
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
      body: Column(
        children: [
          _buildExamTypeSelector(),
          Expanded(
            child: _selectedSubject == null 
                ? _buildSubjectsList() 
                : _buildTopicsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExamTypeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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

  Widget _buildSubjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        final completion = _getSubjectCompletion(subject);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
              child: Icon(
                _getSubjectIcon(subject),
                color: AppTheme.primaryPurple,
              ),
            ),
            title: Text(
              subject,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _selectedSubject = subject;
              });
              _loadTopics();
            },
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
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedSubject = null;
                    _topics.clear();
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  _selectedSubject!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Text(
                '${_topics.where((t) => t.isCompleted).length}/${_topics.length}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // İlerleme çubuğu
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: LinearPercentIndicator(
            lineHeight: 8,
            percent: _topics.isEmpty ? 0 : _topics.where((t) => t.isCompleted).length / _topics.length,
            backgroundColor: Colors.grey[300],
            linearGradient: AppTheme.primaryGradient,
            barRadius: const Radius.circular(4),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Konular listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: topic.isCompleted 
                          ? AppTheme.primaryPurple 
                          : Colors.grey[300],
                    ),
                    child: Icon(
                      topic.isCompleted 
                          ? Icons.check 
                          : Icons.radio_button_unchecked,
                      color: topic.isCompleted 
                          ? Colors.white 
                          : Colors.grey[600],
                    ),
                  ),
                  title: Text(
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
                  subtitle: topic.questionsSolved > 0 
                      ? Text('${topic.questionsSolved} soru çözüldü')
                      : null,
                  onTap: () => _toggleTopic(index),
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
        content: Text(message),
        backgroundColor: _topics[index].isCompleted 
            ? Colors.green 
            : Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}