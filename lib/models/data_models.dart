import 'dart:convert';

// Motivasyon sözleri
class MotivationQuote {
  final String quote;
  final String author;

  MotivationQuote({required this.quote, required this.author});

  Map<String, dynamic> toMap() {
    return {'quote': quote, 'author': author};
  }

  factory MotivationQuote.fromMap(Map<String, dynamic> map) {
    return MotivationQuote(
      quote: map['quote'] ?? '',
      author: map['author'] ?? '',
    );
  }
}

// Günlük hedefler
class DailyGoal {
  final int studyHours;
  final int questionCount;
  final DateTime date;

  DailyGoal({
    required this.studyHours,
    required this.questionCount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'studyHours': studyHours,
      'questionCount': questionCount,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory DailyGoal.fromMap(Map<String, dynamic> map) {
    return DailyGoal(
      studyHours: map['studyHours']?.toInt() ?? 0,
      questionCount: map['questionCount']?.toInt() ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}

// Çalışma kayıtları
class StudySession {
  final String id;
  final String subject;
  final String topic;
  final int duration; // dakika
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;
  final DateTime date;
  final bool isExam;
  final String examType; // TYT, AYT

  StudySession({
    required this.id,
    required this.subject,
    required this.topic,
    required this.duration,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
    required this.date,
    this.isExam = false,
    this.examType = '',
  });

  double get netScore => correctAnswers - (wrongAnswers / 4);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'topic': topic,
      'duration': duration,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'emptyAnswers': emptyAnswers,
      'date': date.millisecondsSinceEpoch,
      'isExam': isExam,
      'examType': examType,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] ?? '',
      subject: map['subject'] ?? '',
      topic: map['topic'] ?? '',
      duration: map['duration']?.toInt() ?? 0,
      correctAnswers: map['correctAnswers']?.toInt() ?? 0,
      wrongAnswers: map['wrongAnswers']?.toInt() ?? 0,
      emptyAnswers: map['emptyAnswers']?.toInt() ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isExam: map['isExam'] ?? false,
      examType: map['examType'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory StudySession.fromJson(String source) => StudySession.fromMap(json.decode(source));
}

// Konu modeli
class Topic {
  final String name;
  bool isCompleted;
  int questionsSolved;

  Topic({
    required this.name,
    this.isCompleted = false,
    this.questionsSolved = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'questionsSolved': questionsSolved,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      questionsSolved: map['questionsSolved']?.toInt() ?? 0,
    );
  }
}

// Ders modeli
class Subject {
  final String name;
  final List<Topic> topics;
  final int totalQuestions;

  Subject({
    required this.name,
    required this.topics,
    required this.totalQuestions,
  });

  double get completionPercentage {
    if (topics.isEmpty) return 0;
    int completedTopics = topics.where((topic) => topic.isCompleted).length;
    return (completedTopics / topics.length) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'topics': topics.map((x) => x.toMap()).toList(),
      'totalQuestions': totalQuestions,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      name: map['name'] ?? '',
      topics: List<Topic>.from(map['topics']?.map((x) => Topic.fromMap(x)) ?? []),
      totalQuestions: map['totalQuestions']?.toInt() ?? 0,
    );
  }
}

// Kitap modeli
class Book {
  final String id;
  final String name;
  final String publisher;
  final String examType; // TYT, AYT
  final String subject;
  final List<Topic> topics;

  Book({
    required this.id,
    required this.name,
    required this.publisher,
    required this.examType,
    required this.subject,
    required this.topics,
  });

  double get completionPercentage {
    if (topics.isEmpty) return 0;
    int completedTopics = topics.where((topic) => topic.isCompleted).length;
    return (completedTopics / topics.length) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'publisher': publisher,
      'examType': examType,
      'subject': subject,
      'topics': topics.map((x) => x.toMap()).toList(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      publisher: map['publisher'] ?? '',
      examType: map['examType'] ?? '',
      subject: map['subject'] ?? '',
      topics: List<Topic>.from(map['topics']?.map((x) => Topic.fromMap(x)) ?? []),
    );
  }

  String toJson() => json.encode(toMap());
  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));
}

// Deneme sonuçları
class ExamResult {
  final String id;
  final String examType; // TYT, AYT
  final String examName; // Kullanıcının girdiği deneme adı
  final DateTime examDate; // Kullanıcının seçtiği tarih
  final Map<String, StudySession> subjectResults;
  final DateTime createdDate; // Sistemin kaydettiği tarih

  ExamResult({
    required this.id,
    required this.examType,
    required this.examName,
    required this.examDate,
    required this.subjectResults,
    required this.createdDate,
  });

  double get totalNet {
    return subjectResults.values.fold(0.0, (sum, session) => sum + session.netScore);
  }

  int get totalCorrect {
    return subjectResults.values.fold(0, (sum, session) => sum + session.correctAnswers);
  }

  int get totalWrong {
    return subjectResults.values.fold(0, (sum, session) => sum + session.wrongAnswers);
  }

  int get totalEmpty {
    return subjectResults.values.fold(0, (sum, session) => sum + session.emptyAnswers);
  }

  int get totalQuestions {
    return totalCorrect + totalWrong + totalEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examType': examType,
      'examName': examName,
      'examDate': examDate.millisecondsSinceEpoch,
      'subjectResults': subjectResults.map((key, value) => MapEntry(key, value.toMap())),
      'createdDate': createdDate.millisecondsSinceEpoch,
    };
  }

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      id: map['id'] ?? '',
      examType: map['examType'] ?? '',
      examName: map['examName'] ?? 'Deneme',
      examDate: DateTime.fromMillisecondsSinceEpoch(map['examDate'] ?? map['date'] ?? DateTime.now().millisecondsSinceEpoch),
      subjectResults: Map<String, StudySession>.from(
        map['subjectResults']?.map((key, value) => MapEntry(key, StudySession.fromMap(value))) ?? {},
      ),
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate'] ?? map['date'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  String toJson() => json.encode(toMap());
  factory ExamResult.fromJson(String source) => ExamResult.fromMap(json.decode(source));
}

// Pomodoro ayarları
class PomodoroSettings {
  final int workDuration; // dakika
  final int breakDuration; // dakika
  final bool includeInStudyTime;

  PomodoroSettings({
    this.workDuration = 25,
    this.breakDuration = 5,
    this.includeInStudyTime = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'includeInStudyTime': includeInStudyTime,
    };
  }

  factory PomodoroSettings.fromMap(Map<String, dynamic> map) {
    return PomodoroSettings(
      workDuration: map['workDuration']?.toInt() ?? 25,
      breakDuration: map['breakDuration']?.toInt() ?? 5,
      includeInStudyTime: map['includeInStudyTime'] ?? true,
    );
  }
}

// Ajenda aktivite türleri
enum AgendaActivityType {
  studyTopic,    // Konu çalışma
  solveQuestions, // Soru çözme
  other,         // Diğer
}

// Ajenda aktivitesi
class AgendaActivity {
  final String id;
  final String title;
  final AgendaActivityType type;
  final DateTime dateTime;
  final int duration; // dakika
  final bool isCompleted;
  final String? examType; // TYT/AYT (konu çalışma için)
  final String? subject; // Ders
  final String? topic; // Konu
  final String? bookId; // Kitap ID'si (soru çözme için)
  final String? bookName; // Kitap adı
  final bool autoCompleteBookTopic; // Kitap konusunu otomatik tamamla
  final String? customTitle; // Diğer aktiviteler için özel başlık
  final DateTime createdDate;

  AgendaActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.duration,
    this.isCompleted = false,
    this.examType,
    this.subject,
    this.topic,
    this.bookId,
    this.bookName,
    this.autoCompleteBookTopic = false,
    this.customTitle,
    required this.createdDate,
  });

  String get displayTitle {
    switch (type) {
      case AgendaActivityType.studyTopic:
        return '$examType - $subject: $topic';
      case AgendaActivityType.solveQuestions:
        if (bookName != null && bookName!.isNotEmpty) {
          return '$bookName${topic != null ? " - $topic" : ""}';
        }
        return subject != null ? '$subject${topic != null ? " - $topic" : ""}' : 'Soru Çözme';
      case AgendaActivityType.other:
        return customTitle ?? title;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'duration': duration,
      'isCompleted': isCompleted,
      'examType': examType,
      'subject': subject,
      'topic': topic,
      'bookId': bookId,
      'bookName': bookName,
      'autoCompleteBookTopic': autoCompleteBookTopic,
      'customTitle': customTitle,
      'createdDate': createdDate.millisecondsSinceEpoch,
    };
  }

  factory AgendaActivity.fromMap(Map<String, dynamic> map) {
    return AgendaActivity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: AgendaActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => AgendaActivityType.other,
      ),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      duration: map['duration']?.toInt() ?? 60,
      isCompleted: map['isCompleted'] ?? false,
      examType: map['examType'],
      subject: map['subject'],
      topic: map['topic'],
      bookId: map['bookId'],
      bookName: map['bookName'],
      autoCompleteBookTopic: map['autoCompleteBookTopic'] ?? false,
      customTitle: map['customTitle'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate']),
    );
  }

  String toJson() => json.encode(toMap());
  factory AgendaActivity.fromJson(String source) => AgendaActivity.fromMap(json.decode(source));

  AgendaActivity copyWith({
    String? id,
    String? title,
    AgendaActivityType? type,
    DateTime? dateTime,
    int? duration,
    bool? isCompleted,
    String? examType,
    String? subject,
    String? topic,
    String? bookId,
    String? bookName,
    bool? autoCompleteBookTopic,
    String? customTitle,
    DateTime? createdDate,
  }) {
    return AgendaActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      examType: examType ?? this.examType,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      autoCompleteBookTopic: autoCompleteBookTopic ?? this.autoCompleteBookTopic,
      customTitle: customTitle ?? this.customTitle,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}