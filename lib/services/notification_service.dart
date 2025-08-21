import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/data_models.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Servisi başlatma
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (e) {
      print("Zaman dilimi yüklenemedi: $e");
    }
  }

  // Ajanda Aktivitesi İçin Bildirim Planlama
  static Future<void> scheduleAgendaNotification(AgendaActivity activity) async {
    if (activity.dateTime.isBefore(DateTime.now())) {
      return;
    }
    final int notificationId = activity.id.hashCode;
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Çalışma Zamanı Geldi! ⏰',
      activity.displayTitle,
      tz.TZDateTime.from(activity.dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'agenda_channel_id_1',
          'Ajanda Hatırlatıcıları',
          channelDescription: 'Ajandaya eklenen aktiviteler için bildirimler.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.blue,
        ),
        iOS: DarwinNotificationDetails(sound: 'default.wav'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // YENİ: Gerekli parametre eklendi
    );
  }

  // Ajanda bildirimini iptal etme
  static Future<void> cancelAgendaNotification(String activityId) async {
    final int notificationId = activityId.hashCode;
    await _notificationsPlugin.cancel(notificationId);
  }

  // Günlük Motivasyon Bildirimi
  static Future<void> scheduleDailyQuoteNotification(List<MotivationQuote> quotes) async {
    if (quotes.isEmpty) return;
    final MotivationQuote randomQuote = quotes[Random().nextInt(quotes.length)];
    const int notificationId = 100;
    final String notificationBody = '"${randomQuote.quote}"\n- ${randomQuote.author}';
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Günün Motivasyonu ✨',
      notificationBody,
      _nextInstanceOfTwelvePm(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation_channel_id_2',
          'Günlük Motivasyon',
          channelDescription: 'Her gün motivasyon sözü gönderen kanal.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: Colors.purple,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // YENİ: Gerekli parametre eklendi
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTwelvePm() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Uygulama Kullanılmadığında Hatırlatma
  static Future<void> resetInactivityReminder() async {
    const int notificationId = 101;
    await _notificationsPlugin.cancel(notificationId);
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Seni Özledik! 👋',
      'Sadece düzenli çalışanlar kazanır. Haydi, hedeflerine bir adım daha yaklaş!',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 36)),
      const NotificationDetails(
         android: AndroidNotificationDetails(
          'inactivity_channel_id_3',
          'Uygulama Hatırlatıcıları',
          channelDescription: 'Uygulama uzun süre kullanılmadığında hatırlatma gönderir.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: Colors.orange,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // YENİ: Gerekli parametre eklendi
    );
  }
}