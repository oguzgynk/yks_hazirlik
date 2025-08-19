// lib/screens/books_screen.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Book> _books = [];
  Book? _selectedBook;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadBooks();
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

  void _loadBooks() {
    setState(() {
      _books = StorageService.getBooks();
    });
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematik': return Icons.calculate;
      case 'türkçe':
      case 'türk dili ve edebiyatı': return Icons.menu_book;
      case 'geometri': return Icons.square_foot;
      case 'fizik': return Icons.bolt;
      case 'kimya': return Icons.science;
      case 'biyoloji': return Icons.biotech;
      case 'tarih':
      case 'tarih-1':
      case 'tarih-2': return Icons.history_edu;
      case 'coğrafya':
      case 'coğrafya-1':
      case 'coğrafya-2': return Icons.public;
      case 'felsefe': return Icons.psychology;
      case 'din kültürü': return Icons.mosque;
      default: return Icons.book;
    }
  }

  LinearGradient _getBookGradient(String examType) {
    return examType == 'TYT' 
        ? LinearGradient(colors: [Colors.blue[600]!, Colors.blue[400]!], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : LinearGradient(colors: [Colors.purple[600]!, Colors.purple[400]!], begin: Alignment.topLeft, end: Alignment.bottomRight);
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
              )
            : null,
        actions: _selectedBook != null
            ? [
                IconButton(
                  onPressed: () => _showEditBookDialog(_selectedBook!),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteBook(_selectedBook!),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _selectedBook == null 
            ? _buildBooksList() 
            : _buildBookTopics(),
      ),
      floatingActionButton: _selectedBook == null 
          ? FloatingActionButton.extended(
              onPressed: _showAddBookDialog,
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Kitap Ekle',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBooksList() {
    if (_books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.library_books,
                  size: 80,
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Henüz kitap eklenmemiş',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'İlk kitabınızı eklemek için aşağıdaki "Kitap Ekle" butonuna basın.\n\nKitaplarınızı ekleyerek konularınızı takip edebilir, ilerlemenizi izleyebilirsiniz.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        
        return Card(
          key: ValueKey(book.id),
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedBook = book;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: _getBookGradient(book.examType),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (book.examType == 'TYT' ? Colors.blue : Colors.purple).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.publisher,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: book.examType == 'TYT' 
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${book.examType} - ${book.subject}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: book.examType == 'TYT' ? Colors.blue[700] : Colors.purple[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearPercentIndicator(
                          lineHeight: 6,
                          percent: book.completionPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          linearGradient: AppThemes.getGradient(StorageService.getTheme()),
                          barRadius: const Radius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${book.completionPercentage.toInt()}% tamamlandı',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              '${book.topics.where((t) => t.isCompleted).length}/${book.topics.length} konu',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildBookTopics() {
    final book = _selectedBook!;
    
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shadowColor: (book.examType == 'TYT' ? Colors.blue : Colors.purple).withOpacity(0.3),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (book.examType == 'TYT' ? Colors.blue : Colors.purple).withOpacity(0.1),
                    (book.examType == 'TYT' ? Colors.blue : Colors.purple).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: _getBookGradient(book.examType),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (book.examType == 'TYT' ? Colors.blue : Colors.purple).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(_getSubjectIcon(book.subject), color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.name, style: Theme.of(context).textTheme.headlineSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(book.publisher, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: _getBookGradient(book.examType),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${book.examType} - ${book.subject}',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearPercentIndicator(
                    lineHeight: 10,
                    percent: book.completionPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    linearGradient: AppThemes.getGradient(StorageService.getTheme()),
                    barRadius: const Radius.circular(5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${book.topics.where((t) => t.isCompleted).length}/${book.topics.length} konu tamamlandı',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppThemes.getGradient(StorageService.getTheme()),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${book.completionPercentage.toInt()}%',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: book.topics.length,
            itemBuilder: (context, index) {
              final topic = book.topics[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                child: InkWell(
                  onTap: () => _toggleBookTopic(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: topic.isCompleted ? AppThemes.getGradient(StorageService.getTheme()) : null,
                            color: topic.isCompleted ? null : Colors.grey[300],
                          ),
                          child: Icon(
                            topic.isCompleted ? Icons.check : Icons.radio_button_unchecked,
                            color: topic.isCompleted ? Colors.white : Colors.grey[600],
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
                                  decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                                  color: topic.isCompleted ? Colors.grey[600] : null,
                                ),
                              ),
                              if (topic.questionsSolved > 0) 
                                Text(
                                  '${topic.questionsSolved} soru çözüldü',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                              style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
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
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Kitap Adı', prefixIcon: Icon(Icons.book), border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: publisherController, decoration: InputDecoration(labelText: 'Yayınevi', prefixIcon: Icon(Icons.business), border: OutlineInputBorder())),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedExamType,
                  decoration: InputDecoration(labelText: 'Sınav Türü', prefixIcon: Icon(Icons.quiz), border: OutlineInputBorder()),
                  items: ['TYT', 'AYT'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
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
                  decoration: InputDecoration(labelText: 'Ders', prefixIcon: Icon(Icons.school), border: OutlineInputBorder()),
                  items: _getSubjectsForExam(selectedExamType).map((subject) => DropdownMenuItem(value: subject, child: Text(subject))).toList(),
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && publisherController.text.isNotEmpty && selectedSubject != null) {
                  _addBook(nameController.text, publisherController.text, selectedExamType, selectedSubject!);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
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
              leading: Icon(Icons.add, color: Colors.green),
              title: const Text('Konu Ekle'),
              onTap: () {
                Navigator.pop(context);
                _showAddTopicDialog(book);
              },
            ),
            ListTile(
              leading: Icon(Icons.remove, color: Colors.red),
              title: const Text('Konu Çıkar'),
              onTap: () {
                Navigator.pop(context);
                _showRemoveTopicDialog(book);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
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
        content: TextField(controller: topicController, decoration: InputDecoration(labelText: 'Konu Adı', prefixIcon: Icon(Icons.topic), border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (topicController.text.isNotEmpty) {
                _addTopicToBook(book, topicController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
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
                  icon: Icon(Icons.delete, color: Colors.red),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
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
   

    final topicsMap = examType == 'TYT' ? AppConstants.tytTopics : AppConstants.aytTopics;
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
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Kitap başarıyla eklendi!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Konu eklendi!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Konu kaldırıldı!'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        content: Row(
          children: [
            Icon(book.topics[index].isCompleted ? Icons.check_circle : Icons.undo, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: book.topics[index].isCompleted ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Kitap silindi!'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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