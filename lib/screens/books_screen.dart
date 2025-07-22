import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematik':
        return Icons.calculate;
      case 'türkçe':
      case 'türk dili ve edebiyatı':
        return Icons.menu_book;
      case 'geometri':
        return Icons.square_foot;
      case 'fizik':
        return Icons.science;
      case 'kimya':
        return Icons.biotech;
      case 'biyoloji':
        return Icons.eco;
      case 'tarih':
      case 'tarih-1':
      case 'tarih-2':
        return Icons.history_edu;
      case 'coğrafya':
      case 'coğrafya-1':
      case 'coğrafya-2':
        return Icons.public;
      case 'felsefe':
        return Icons.psychology;
      case 'din kültürü':
        return Icons.mosque;
      default:
        return Icons.book;
    }
  }

  LinearGradient _getBookGradient(String examType) {
    return examType == 'TYT' 
        ? LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [Colors.purple[600]!, Colors.purple[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
  }

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> _books = [];
  Book? _selectedBook;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() {
    setState(() {
      _books = StorageService.getBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedBook == null ? 'Kitaplarım' : _selectedBook!.name),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: _selectedBook != null 
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _selectedBook = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: _selectedBook == null 
            ? [
                IconButton(
                  onPressed: _showAddBookDialog,
                  icon: const Icon(Icons.add),
                ),
              ]
            : [
                IconButton(
                  onPressed: () => _showEditBookDialog(_selectedBook!),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () => _deleteBook(_selectedBook!),
                  icon: const Icon(Icons.delete),
                ),
              ],
      ),
      body: _selectedBook == null 
          ? _buildBooksList() 
          : _buildBookTopics(),
      floatingActionButton: _selectedBook == null 
          ? FloatingActionButton(
              onPressed: _showAddBookDialog,
              backgroundColor: AppTheme.primaryPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBooksList() {
    if (_books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz kitap eklenmemiş',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk kitabınızı eklemek için + butonuna basın',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                gradient: _getBookGradient(book.examType),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSubjectIcon(book.subject),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              book.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.publisher),
                Text('${book.examType} - ${book.subject}'),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  lineHeight: 6,
                  percent: book.completionPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  linearGradient: AppTheme.primaryGradient,
                  barRadius: const Radius.circular(3),
                ),
                const SizedBox(height: 4),
                Text(
                  '${book.completionPercentage.toInt()}% tamamlandı',
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
                _selectedBook = book;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBookTopics() {
    final book = _selectedBook!;
    
    return Column(
      children: [
        // Kitap bilgileri
        Container(
          margin: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: _getBookGradient(book.examType),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getSubjectIcon(book.subject),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              book.publisher,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${book.examType} - ${book.subject}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    lineHeight: 8,
                    percent: book.completionPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    linearGradient: AppTheme.primaryGradient,
                    barRadius: const Radius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${book.topics.where((t) => t.isCompleted).length}/${book.topics.length} konu',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${book.completionPercentage.toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ],
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
            itemCount: book.topics.length,
            itemBuilder: (context, index) {
              final topic = book.topics[index];
              
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
                  onTap: () => _toggleBookTopic(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddBookDialog() {
    final nameController = TextEditingController();
    final publisherController = TextEditingController();
    String selectedExamType = 'TYT';
    String? selectedSubject;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Kitap Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Kitap Adı',
                    prefixIcon: Icon(Icons.book),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: publisherController,
                  decoration: const InputDecoration(
                    labelText: 'Yayınevi',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedExamType,
                  decoration: const InputDecoration(
                    labelText: 'Sınav Türü',
                    prefixIcon: Icon(Icons.quiz),
                  ),
                  items: ['TYT', 'AYT'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedExamType = value!;
                      selectedSubject = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Ders',
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: _getSubjectsForExam(selectedExamType).map((subject) {
                    return DropdownMenuItem(value: subject, child: Text(subject));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSubject = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    publisherController.text.isNotEmpty &&
                    selectedSubject != null) {
                  _addBook(
                    nameController.text,
                    publisherController.text,
                    selectedExamType,
                    selectedSubject!,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBookDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitap Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Konu Ekle'),
              onTap: () {
                Navigator.pop(context);
                _showAddTopicDialog(book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove),
              title: const Text('Konu Çıkar'),
              onTap: () {
                Navigator.pop(context);
                _showRemoveTopicDialog(book);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showAddTopicDialog(Book book) {
    final topicController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konu Ekle'),
        content: TextField(
          controller: topicController,
          decoration: const InputDecoration(
            labelText: 'Konu Adı',
            prefixIcon: Icon(Icons.topic),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (topicController.text.isNotEmpty) {
                _addTopicToBook(book, topicController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showRemoveTopicDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konu Çıkar'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: book.topics.length,
            itemBuilder: (context, index) {
              final topic = book.topics[index];
              return ListTile(
                title: Text(topic.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _removeTopicFromBook(book, index);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  List<String> _getSubjectsForExam(String examType) {
    return examType == 'TYT' 
        ? AppConstants.tytTopics.keys.toList()
        : AppConstants.aytTopics.keys.toList();
  }

  void _addBook(String name, String publisher, String examType, String subject) {
    final topicsMap = examType == 'TYT' 
        ? AppConstants.tytTopics 
        : AppConstants.aytTopics;
    
    final topicNames = topicsMap[subject] ?? [];
    final topics = topicNames.map((name) => Topic(name: name)).toList();
    
    final book = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      publisher: publisher,
      examType: examType,
      subject: subject,
      topics: topics,
    );
    
    StorageService.saveBook(book);
    _loadBooks();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kitap başarıyla eklendi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addTopicToBook(Book book, String topicName) {
    book.topics.add(Topic(name: topicName));
    StorageService.saveBook(book);
    
    setState(() {
      _selectedBook = book;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konu eklendi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeTopicFromBook(Book book, int index) {
    book.topics.removeAt(index);
    StorageService.saveBook(book);
    
    setState(() {
      _selectedBook = book;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konu kaldırıldı!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _toggleBookTopic(int index) {
    final book = _selectedBook!;
    book.topics[index].isCompleted = !book.topics[index].isCompleted;
    
    StorageService.saveBook(book);
    
    setState(() {
      _selectedBook = book;
    });
    
    final message = book.topics[index].isCompleted 
        ? 'Konu tamamlandı! 🎉'
        : 'Konu tamamlanmamış olarak işaretlendi';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: book.topics[index].isCompleted 
            ? Colors.green 
            : Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _deleteBook(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitabı Sil'),
        content: Text('${book.name} kitabını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              StorageService.removeBook(book.id);
              Navigator.pop(context);
              setState(() {
                _selectedBook = null;
              });
              _loadBooks();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kitap silindi!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}