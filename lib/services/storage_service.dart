// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

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
  
  // YENİ VE GÜNCELLENMİŞ BÖLÜM: TEMA YÖNETİMİ
  static Future<void> saveTheme(String themeName) async {
    await _prefs.setString('theme_name', themeName);
  }

  static String getTheme() {
    return _prefs.getString('theme_name') ?? 'light';
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
    books.removeWhere((bookJson) => Book.fromJson(bookJson).id == book.id);
    books.add(book.toJson());
    await setStringList('books', books);
  }

  static List<Book> getBooks() {
    List<String> booksJson = getStringList('books') ?? [];
    return booksJson.map((json) => Book.fromJson(json)).toList();
  }

  static Future<void> removeBook(String bookId) async {
    List<String> books = getStringList('books') ?? [];
    books.removeWhere((bookJson) => Book.fromJson(bookJson).id == bookId);
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

  // Konu ilerlemeleri
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

  // YKS tarihi
  static Future<void> saveYksDate(DateTime date) async {
    await setString('yks_date', date.toIso8601String());
  }

  static DateTime? getYksDate() {
    String? dateString = getString('yks_date');
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  // Ajenda aktiviteleri
  static Future<void> saveAgendaActivity(AgendaActivity activity) async {
    List<String> activities = getStringList('agenda_activities') ?? [];
    activities.removeWhere((actJson) => AgendaActivity.fromJson(actJson).id == activity.id);
    activities.add(activity.toJson());
    await setStringList('agenda_activities', activities);
  }

  static List<AgendaActivity> getAgendaActivities() {
    List<String> activitiesJson = getStringList('agenda_activities') ?? [];
    return activitiesJson.map((json) => AgendaActivity.fromJson(json)).toList();
  }

  static Future<void> removeAgendaActivity(String activityId) async {
    List<String> activities = getStringList('agenda_activities') ?? [];
    activities.removeWhere((actJson) => AgendaActivity.fromJson(actJson).id == activityId);
    await setStringList('agenda_activities', activities);
  }

  static List<AgendaActivity> getAgendaActivitiesForDate(DateTime date) {
    List<AgendaActivity> allActivities = getAgendaActivities();
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    return allActivities.where((activity) => activity.dateTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && activity.dateTime.isBefore(endOfDay)).toList();
  }

  static List<AgendaActivity> getAgendaActivitiesForWeek(DateTime date) {
    List<AgendaActivity> allActivities = getAgendaActivities();
    DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));
    return allActivities.where((activity) => activity.dateTime.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && activity.dateTime.isBefore(endOfWeek)).toList();
  }

  // Bildirim ayarları
  static Future<void> setNotificationEnabled(bool enabled) async {
    await setBool('notifications_enabled', enabled);
  }

  static bool getNotificationEnabled() {
    return getBool('notifications_enabled') ?? true;
  }

  static Future<void> updateLastSeenDate() {
  final now = DateTime.now().toIso8601String();
  return _prefs.setString('lastSeenDate', now);
}

  // Çalışma verileri için yardımcı metodlar
  static List<StudySession> getStudySessionsByDateRange(DateTime start, DateTime end) {
    List<StudySession> allSessions = getStudySessions();
    return allSessions.where((session) => session.date.isAfter(start.subtract(const Duration(days: 1))) && session.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  static int getTotalStudyMinutes() {
    List<StudySession> sessions = getStudySessions();
    return sessions.fold(0, (total, session) => total + session.duration);
  }

  static int getTodayStudyMinutes() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    return getStudySessionsByDateRange(startOfDay, endOfDay).fold(0, (total, session) => total + session.duration);
  }

  static int getTodayQuestionsSolved() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    return getStudySessionsByDateRange(startOfDay, endOfDay).fold(0, (total, session) => total + session.correctAnswers + session.wrongAnswers + session.emptyAnswers);
  }
}