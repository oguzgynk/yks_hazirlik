import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getter for _prefs
  static SharedPreferences get prefs => _prefs;

  // Temel get/set metodları
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Çalışma oturumları
  static Future<void> saveStudySession(StudySession session) async {
    List<String> sessions = getStringList('study_sessions') ?? [];
    sessions.add(session.toJson());
    await setStringList('study_sessions', sessions);
  }

  static List<StudySession> getStudySessions() {
    List<String> sessionsJson = getStringList('study_sessions') ?? [];
    return sessionsJson.map((json) => StudySession.fromJson(json)).toList();
  }

  // Kitaplar
  static Future<void> saveBook(Book book) async {
    List<String> books = getStringList('books') ?? [];
    // Eğer kitap zaten varsa güncelle
    books.removeWhere((bookJson) {
      Book existingBook = Book.fromJson(bookJson);
      return existingBook.id == book.id;
    });
    books.add(book.toJson());
    await setStringList('books', books);
  }

  static List<Book> getBooks() {
    List<String> booksJson = getStringList('books') ?? [];
    return booksJson.map((json) => Book.fromJson(json)).toList();
  }

  static Future<void> removeBook(String bookId) async {
    List<String> books = getStringList('books') ?? [];
    books.removeWhere((bookJson) {
      Book book = Book.fromJson(bookJson);
      return book.id == bookId;
    });
    await setStringList('books', books);
  }

  // Deneme sonuçları
  static Future<void> saveExamResult(ExamResult result) async {
    List<String> results = getStringList('exam_results') ?? [];
    results.add(result.toJson());
    await setStringList('exam_results', results);
  }

  static List<ExamResult> getExamResults() {
    List<String> resultsJson = getStringList('exam_results') ?? [];
    return resultsJson.map((json) => ExamResult.fromJson(json)).toList();
  }

  // Günlük hedefler
  static Future<void> saveDailyGoal(DailyGoal goal) async {
    String goalJson = json.encode(goal.toMap());
    await setString('daily_goal', goalJson);
  }

  static DailyGoal? getDailyGoal() {
    String? goalJson = getString('daily_goal');
    if (goalJson == null) return null;
    return DailyGoal.fromMap(json.decode(goalJson));
  }

  // Pomodoro ayarları
  static Future<void> savePomodoroSettings(PomodoroSettings settings) async {
    String settingsJson = json.encode(settings.toMap());
    await setString('pomodoro_settings', settingsJson);
  }

  static PomodoroSettings getPomodoroSettings() {
    String? settingsJson = getString('pomodoro_settings');
    if (settingsJson == null) return PomodoroSettings();
    return PomodoroSettings.fromMap(json.decode(settingsJson));
  }

  // Konu ilerlemeleri (TYT/AYT)
  static Future<void> saveTopicProgress(String examType, String subject, List<Topic> topics) async {
    String key = '${examType.toLowerCase()}_${subject.toLowerCase()}_topics';
    List<String> topicsJson = topics.map((topic) => json.encode(topic.toMap())).toList();
    await setStringList(key, topicsJson);
  }

  static List<Topic> getTopicProgress(String examType, String subject) {
    String key = '${examType.toLowerCase()}_${subject.toLowerCase()}_topics';
    List<String>? topicsJson = getStringList(key);
    if (topicsJson == null) return [];
    return topicsJson.map((json) => Topic.fromMap(jsonDecode(json))).toList();
  }

  // Premium durum
  static Future<void> setPremiumStatus(bool isPremium) async {
    await setBool('is_premium', isPremium);
  }

  static bool getPremiumStatus() {
    return getBool('is_premium') ?? false;
  }

  // YKS tarihi
  static Future<void> saveYksDate(DateTime date) async {
    await setString('yks_date', date.toIso8601String());
  }

  static DateTime? getYksDate() {
    String? dateString = getString('yks_date');
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  // Çalışma verileri için yardımcı metodlar
  static List<StudySession> getStudySessionsByDateRange(DateTime start, DateTime end) {
    List<StudySession> allSessions = getStudySessions();
    return allSessions.where((session) {
      return session.date.isAfter(start.subtract(const Duration(days: 1))) &&
             session.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  static Map<String, double> getSubjectStats() {
    List<StudySession> sessions = getStudySessions();
    Map<String, double> stats = {};
    
    for (var session in sessions) {
      if (stats.containsKey(session.subject)) {
        stats[session.subject] = stats[session.subject]! + session.netScore;
      } else {
        stats[session.subject] = session.netScore;
      }
    }
    
    return stats;
  }

  static int getTotalStudyMinutes() {
    List<StudySession> sessions = getStudySessions();
    return sessions.fold(0, (total, session) => total + session.duration);
  }

  static int getTotalQuestionsSolved() {
    List<StudySession> sessions = getStudySessions();
    return sessions.fold(0, (total, session) => 
      total + session.correctAnswers + session.wrongAnswers + session.emptyAnswers);
  }

  // Bugünkü veriler
  static List<StudySession> getTodaySessions() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getStudySessionsByDateRange(startOfDay, endOfDay);
  }

  static int getTodayStudyMinutes() {
    List<StudySession> todaySessions = getTodaySessions();
    return todaySessions.fold(0, (total, session) => total + session.duration);
  }

  static int getTodayQuestionsSolved() {
    List<StudySession> todaySessions = getTodaySessions();
    return todaySessions.fold(0, (total, session) => 
      total + session.correctAnswers + session.wrongAnswers + session.emptyAnswers);
  }

  // Haftalık veriler
  static List<StudySession> getWeeklySessions() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return getStudySessionsByDateRange(startOfWeek, endOfWeek);
  }

  // Aylık veriler
  static List<StudySession> getMonthlySessions() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    return getStudySessionsByDateRange(startOfMonth, endOfMonth);
  }
}