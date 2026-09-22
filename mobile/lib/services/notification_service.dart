import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/hadith.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderNotificationId = 1001;
  static const int testNotificationId = 9999;
  static const String channelId = 'daily_hadith_channel';
  static const String channelName = 'Daily Hadith Reminder';
  static const String channelDescription =
      'Daily authentic Hadith reminders and notifications from 1001 Authentic Hadith';

  Function(int hadithId)? _onNotificationSelected;

  Future<void> initialize({Function(int hadithId)? onSelectHadith}) async {
    _onNotificationSelected = onSelectHadith;

    try {
      // Initialize timezones
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Error initializing timezones: $e');
    }

    try {
      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS / macOS Darwin settings
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            final hadithId = int.tryParse(response.payload!);
            if (hadithId != null && _onNotificationSelected != null) {
              _onNotificationSelected!(hadithId);
            }
          }
        },
      );

      // Create High-Priority Notification Channel for Android
      final androidNotificationPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidNotificationPlugin != null) {
        await androidNotificationPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during NotificationService initialize: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final granted = await androidImplementation.requestNotificationsPermission();
          return granted ?? false;
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        final darwinImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (darwinImplementation != null) {
          final granted = await darwinImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return true;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    } catch (_) {
      final now = DateTime.now();
      var scheduledDate = tz.TZDateTime.from(
        DateTime(now.year, now.month, now.day, hour, minute),
        tz.UTC,
      );
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.UTC))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    }
  }

  NotificationDetails _buildNotificationDetails({
    required String title,
    required String body,
    required String subText,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: subText,
        htmlFormatContentTitle: false,
        htmlFormatBigText: false,
      ),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
  }

  Future<void> scheduleDailyHadithReminder({
    required int hour,
    required int minute,
    required Hadith hadith,
  }) async {
    try {
      // Cancel existing scheduled daily reminder
      await cancelDailyReminder();

      final scheduledDate = _nextInstanceOfTime(hour, minute);
      final title = '📖 Daily Hadith: ${hadith.topicEn}';
      final previewText = hadith.englishTranslation.isNotEmpty
          ? (hadith.englishTranslation.length > 200
              ? '${hadith.englishTranslation.substring(0, 197)}...'
              : hadith.englishTranslation)
          : hadith.arabicMatn;
      final subText = 'Hadith #${hadith.id} • ${hadith.chapterTitleEn}';

      final details = _buildNotificationDetails(
        title: title,
        body: previewText,
        subText: subText,
      );

      await _notificationsPlugin.zonedSchedule(
        dailyReminderNotificationId,
        title,
        previewText,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: hadith.id.toString(),
      );
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  Future<void> showInstantTestNotification({required Hadith hadith}) async {
    try {
      final title = '📖 Daily Hadith: ${hadith.topicEn}';
      final previewText = hadith.englishTranslation.isNotEmpty
          ? (hadith.englishTranslation.length > 200
              ? '${hadith.englishTranslation.substring(0, 197)}...'
              : hadith.englishTranslation)
          : hadith.arabicMatn;
      final subText = 'Hadith #${hadith.id} • ${hadith.chapterTitleEn}';

      final details = _buildNotificationDetails(
        title: title,
        body: previewText,
        subText: subText,
      );

      await _notificationsPlugin.show(
        testNotificationId,
        title,
        previewText,
        details,
        payload: hadith.id.toString(),
      );
    } catch (e) {
      debugPrint('Error showing instant test notification: $e');
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      await _notificationsPlugin.cancel(dailyReminderNotificationId);
    } catch (e) {
      debugPrint('Error cancelling daily reminder: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
