import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  List<AgendaActivity> _activities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadActivities() {
    setState(() {
      if (_tabController.index == 0) {
        // Günlük görünüm
        _activities = StorageService.getAgendaActivitiesForDate(_selectedDate);
      } else {
        // Haftalık görünüm
        _activities = StorageService.getAgendaActivitiesForWeek(_selectedDate);
      }
      _activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajandam'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPurple,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: Colors.grey,
          onTap: (index) => _loadActivities(),
          tabs: const [
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyView(),
          _buildWeeklyView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivityDialog,
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDailyView() {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: _buildActivitiesList(),
        ),
      ],
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      children: [
        _buildWeekSelector(),
        Expanded(
          child: _buildActivitiesList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                  _loadActivities();
                },
                icon: const Icon(Icons.chevron_left),
              ),
              GestureDetector(
                onTap: _selectDate,
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      DateFormat('EEEE', 'tr_TR').format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                  _loadActivities();
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                  });
                  _loadActivities();
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Column(
                children: [
                  Text(
                    '${DateFormat('dd MMM', 'tr_TR').format(startOfWeek)} - ${DateFormat('dd MMM yyyy', 'tr_TR').format(endOfWeek)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Haftalık Görünüm',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 7));
                  });
                  _loadActivities();
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesList() {
    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz aktivite eklenmemiş',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk aktivitenizi eklemek için + butonuna basın',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(AgendaActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showActivityDetails(activity),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: activity.isCompleted 
                      ? Colors.green.withOpacity(0.1)
                      : _getActivityColor(activity.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  activity.isCompleted 
                      ? Icons.check_circle
                      : _getActivityIcon(activity.type),
                  color: activity.isCompleted 
                      ? Colors.green
                      : _getActivityColor(activity.type),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.displayTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: activity.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(activity.dateTime),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.duration} dk',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (_tabController.index == 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM EEEE', 'tr_TR').format(activity.dateTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleActivityAction(value, activity),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(
                          activity.isCompleted ? Icons.undo : Icons.check,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(activity.isCompleted ? 'Geri Al' : 'Tamamla'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(AgendaActivityType type) {
    switch (type) {
      case AgendaActivityType.studyTopic:
        return Icons.school;
      case AgendaActivityType.solveQuestions:
        return Icons.quiz;
      case AgendaActivityType.other:
        return Icons.event;
    }
  }

  Color _getActivityColor(AgendaActivityType type) {
    switch (type) {
      case AgendaActivityType.studyTopic:
        return AppTheme.primaryPurple;
      case AgendaActivityType.solveQuestions:
        return AppTheme.primaryBlue;
      case AgendaActivityType.other:
        return AppTheme.accentBlue;
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadActivities();
    }
  }

  void _showAddActivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AddActivityDialog(
        selectedDate: _selectedDate,
        onActivityAdded: _loadActivities,
      ),
    );
  }

  void _showActivityDetails(AgendaActivity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ActivityDetailsSheet(
        activity: activity,
        onActivityUpdated: _loadActivities,
      ),
    );
  }

  void _handleActivityAction(String action, AgendaActivity activity) async {
    switch (action) {
      case 'complete':
        final updatedActivity = activity.copyWith(isCompleted: !activity.isCompleted);
        await StorageService.saveAgendaActivity(updatedActivity);
        
        // Eğer kitap konusunu otomatik tamamlama seçili ise
        if (updatedActivity.isCompleted && 
            updatedActivity.autoCompleteBookTopic && 
            updatedActivity.bookId != null && 
            updatedActivity.topic != null) {
          await _autoCompleteBookTopic(updatedActivity);
        }
        
        _loadActivities();
        break;
      case 'edit':
        _showEditActivityDialog(activity);
        break;
      case 'delete':
        _showDeleteConfirmation(activity);
        break;
    }
  }

  Future<void> _autoCompleteBookTopic(AgendaActivity activity) async {
    List<Book> books = StorageService.getBooks();
    Book? book = books.firstWhere(
      (b) => b.id == activity.bookId,
      orElse: () => books.first,
    );
    
    if (book != null) {
      // Kitaptaki konuyu tamamla
      for (int i = 0; i < book.topics.length; i++) {
        if (book.topics[i].name == activity.topic) {
          book.topics[i].isCompleted = true;
          break;
        }
      }
      await StorageService.saveBook(book);
    }
  }

  void _showEditActivityDialog(AgendaActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AddActivityDialog(
        selectedDate: activity.dateTime,
        existingActivity: activity,
        onActivityAdded: _loadActivities,
      ),
    );
  }

  void _showDeleteConfirmation(AgendaActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktiviteyi Sil'),
        content: Text('${activity.displayTitle} aktivitesini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.removeAgendaActivity(activity.id);
              Navigator.pop(context);
              _loadActivities();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class AddActivityDialog extends StatefulWidget {
  final DateTime selectedDate;
  final AgendaActivity? existingActivity;
  final VoidCallback onActivityAdded;

  const AddActivityDialog({
    super.key,
    required this.selectedDate,
    this.existingActivity,
    required this.onActivityAdded,
  });

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  AgendaActivityType _selectedType = AgendaActivityType.studyTopic;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _duration = 60;
  String _customTitle = '';
  String? _examType;
  String? _subject;
  String? _topic;
  String? _bookId;
  String? _bookName;
  bool _autoCompleteBookTopic = false;

  final _customTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    
    if (widget.existingActivity != null) {
      final activity = widget.existingActivity!;
      _selectedType = activity.type;
      _selectedDate = DateTime(activity.dateTime.year, activity.dateTime.month, activity.dateTime.day);
      _selectedTime = TimeOfDay.fromDateTime(activity.dateTime);
      _duration = activity.duration;
      _customTitle = activity.customTitle ?? '';
      _examType = activity.examType;
      _subject = activity.subject;
      _topic = activity.topic;
      _bookId = activity.bookId;
      _bookName = activity.bookName;
      _autoCompleteBookTopic = activity.autoCompleteBookTopic;
      _customTitleController.text = _customTitle;
    }
  }

  @override
  void dispose() {
    _customTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingActivity == null ? 'Aktivite Ekle' : 'Aktiviteyi Düzenle'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActivityTypeSelector(),
              const SizedBox(height: 16),
              _buildDateTimeSelector(),
              const SizedBox(height: 16),
              _buildDurationSelector(),
              const SizedBox(height: 16),
              _buildActivitySpecificFields(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveActivity,
          child: Text(widget.existingActivity == null ? 'Ekle' : 'Güncelle'),
        ),
      ],
    );
  }

  Widget _buildActivityTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aktivite Türü'),
        const SizedBox(height: 8),
        DropdownButtonFormField<AgendaActivityType>(
          value: _selectedType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(
              value: AgendaActivityType.studyTopic,
              child: Text('Konu Çalışacağım'),
            ),
            DropdownMenuItem(
              value: AgendaActivityType.solveQuestions,
              child: Text('Soru Çözeceğim'),
            ),
            DropdownMenuItem(
              value: AgendaActivityType.other,
              child: Text('Diğer'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
              // Reset fields when type changes
              _examType = null;
              _subject = null;
              _topic = null;
              _bookId = null;
              _bookName = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tarih'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saat'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: Text(
                    _selectedTime.format(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Süre (dakika)'),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _duration.toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            _duration = int.tryParse(value) ?? 60;
          },
        ),
      ],
    );
  }

  Widget _buildActivitySpecificFields() {
    switch (_selectedType) {
      case AgendaActivityType.studyTopic:
        return _buildStudyTopicFields();
      case AgendaActivityType.solveQuestions:
        return _buildSolveQuestionsFields();
      case AgendaActivityType.other:
        return _buildOtherFields();
    }
  }

  Widget _buildStudyTopicFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _examType,
          decoration: const InputDecoration(
            labelText: 'Sınav Türü',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: ['TYT', 'AYT'].map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _examType = value;
              _subject = null;
              _topic = null;
            });
          },
        ),
        const SizedBox(height: 16),
        if (_examType != null) ...[
          DropdownButtonFormField<String>(
            value: _subject,
            decoration: const InputDecoration(
              labelText: 'Ders',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _getSubjects().map((subject) {
              return DropdownMenuItem(value: subject, child: Text(subject));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _subject = value;
                _topic = null;
              });
            },
          ),
          const SizedBox(height: 16),
        ],
        if (_subject != null) ...[
          DropdownButtonFormField<String>(
            value: _topic,
            decoration: const InputDecoration(
              labelText: 'Konu',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _getTopics().map((topic) {
              return DropdownMenuItem(
                value: topic,
                child: Text(
                  topic,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _topic = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSolveQuestionsFields() {
    List<Book> books = StorageService.getBooks();
    
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _bookId,
          decoration: const InputDecoration(
            labelText: 'Kitap (İsteğe bağlı)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Kitap seçmeyin'),
            ),
            ...books.map((book) {
              return DropdownMenuItem(
                value: book.id,
                child: Text(book.name),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _bookId = value;
              if (value != null) {
                Book selectedBook = books.firstWhere((b) => b.id == value);
                _bookName = selectedBook.name;
                _subject = selectedBook.subject;
              } else {
                _bookName = null;
                _subject = null;
              }
              _topic = null;
            });
          },
        ),
        const SizedBox(height: 16),
        if (_bookId == null) ...[
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Ders',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              _subject = value;
            },
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Konu (İsteğe bağlı)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            _topic = value.isEmpty ? null : value;
          },
        ),
        if (_bookId != null && _topic != null) ...[
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Tamamladığımda kitaptaki konuyu da tamamla'),
            value: _autoCompleteBookTopic,
            onChanged: (value) {
              setState(() {
                _autoCompleteBookTopic = value ?? false;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOtherFields() {
    return TextFormField(
      controller: _customTitleController,
      decoration: const InputDecoration(
        labelText: 'Aktivite Başlığı',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        _customTitle = value;
      },
    );
  }

  List<String> _getSubjects() {
  if (_examType == 'TYT') {
    return AppConstants.tytTopics.keys.toList();
  } else if (_examType == 'AYT') {
    return AppConstants.aytTopics.keys.toList();
  }
  return [];
}

  List<String> _getTopics() {
    if (_examType == 'TYT') {
      return AppConstants.tytTopics[_subject] ?? [];
    } else {
      return AppConstants.aytTopics[_subject] ?? [];
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveActivity() async {
    if (!_validateFields()) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final activity = AgendaActivity(
      id: widget.existingActivity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _getActivityTitle(),
      type: _selectedType,
      dateTime: dateTime,
      duration: _duration,
      isCompleted: widget.existingActivity?.isCompleted ?? false,
      examType: _examType,
      subject: _subject,
      topic: _topic,
      bookId: _bookId,
      bookName: _bookName,
      autoCompleteBookTopic: _autoCompleteBookTopic,
      customTitle: _customTitle.isEmpty ? null : _customTitle,
      createdDate: widget.existingActivity?.createdDate ?? DateTime.now(),
    );

    await StorageService.saveAgendaActivity(activity);
    Navigator.pop(context);
    widget.onActivityAdded();
  }

  String _getActivityTitle() {
    switch (_selectedType) {
      case AgendaActivityType.studyTopic:
        return '$_examType - $_subject: $_topic';
      case AgendaActivityType.solveQuestions:
        if (_bookName != null) {
          return '$_bookName${_topic != null ? " - $_topic" : ""}';
        }
        return '$_subject${_topic != null ? " - $_topic" : ""}';
      case AgendaActivityType.other:
        return _customTitle;
    }
  }

  bool _validateFields() {
    switch (_selectedType) {
      case AgendaActivityType.studyTopic:
        return _examType != null && _subject != null && _topic != null;
      case AgendaActivityType.solveQuestions:
        return _subject != null;
      case AgendaActivityType.other:
        return _customTitle.isNotEmpty;
    }
  }
}

class ActivityDetailsSheet extends StatelessWidget {
  final AgendaActivity activity;
  final VoidCallback onActivityUpdated;

  const ActivityDetailsSheet({
    super.key,
    required this.activity,
    required this.onActivityUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aktivite Detayları',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Başlık', activity.displayTitle),
          _buildDetailRow('Tarih', DateFormat('dd MMMM yyyy EEEE', 'tr_TR').format(activity.dateTime)),
          _buildDetailRow('Saat', DateFormat('HH:mm').format(activity.dateTime)),
          _buildDetailRow('Süre', '${activity.duration} dakika'),
          _buildDetailRow('Durum', activity.isCompleted ? 'Tamamlandı' : 'Bekliyor'),
          if (activity.examType != null) _buildDetailRow('Sınav Türü', activity.examType!),
          if (activity.subject != null) _buildDetailRow('Ders', activity.subject!),
          if (activity.topic != null) _buildDetailRow('Konu', activity.topic!),
          if (activity.bookName != null) _buildDetailRow('Kitap', activity.bookName!),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final updatedActivity = activity.copyWith(isCompleted: !activity.isCompleted);
                    await StorageService.saveAgendaActivity(updatedActivity);
                    Navigator.pop(context);
                    onActivityUpdated();
                  },
                  child: Text(activity.isCompleted ? 'Geri Al' : 'Tamamla'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Kapat', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}