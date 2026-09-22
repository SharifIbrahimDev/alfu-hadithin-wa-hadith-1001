import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/hadith.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderNotificationId = 1001;
  static const int testNotificationId = 9999;
  static const String channelId = 'daily_hadith_reminder_channel_v3';
  static const String channelName = 'Daily Hadith Reminder';
  static const String channelDescription =
      'Daily authentic Hadith reminders and notifications from 1001 Authentic Hadith';

  Function(int hadithId)? _onNotificationSelected;
  bool _initialized = false;

  Future<void> initialize({Function(int hadithId)? onSelectHadith}) async {
    if (_initialized && onSelectHadith == null) return;
    _onNotificationSelected = onSelectHadith;

    await _configureLocalTimeZone();

    try {
      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS / macOS Darwin settings
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
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
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            showBadge: true,
          ),
        );
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Error during NotificationService initialize: $e');
    }
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('NotificationService: Local timezone initialized to $timeZoneName');
      return;
    } catch (e) {
      debugPrint('NotificationService: Timezone lookup by name failed ($e). Attempting offset matching.');
    }

    // Offset-based fallback for OEM ROMs (Infinix/Transsion/Xiaomi) returning non-standard TZ strings
    try {
      final now = DateTime.now();
      final offsetMs = now.timeZoneOffset.inMilliseconds;
      for (final locName in tz.timeZoneDatabase.locations.keys) {
        final loc = tz.getLocation(locName);
        if (loc.currentTimeZone.offset == offsetMs) {
          tz.setLocalLocation(loc);
          debugPrint('NotificationService: Local timezone matched by offset ($offsetMs ms) -> $locName');
          return;
        }
      }
    } catch (e) {
      debugPrint('NotificationService: Offset fallback error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final notifGranted =
              await androidImplementation.requestNotificationsPermission();
          try {
            await androidImplementation.requestExactAlarmsPermission();
          } catch (_) {}
          return notifGranted ?? false;
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
    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    // If the scheduled time is in the past or current second/minute that already started, wrap to tomorrow
    if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return tz.TZDateTime.from(scheduled, tz.local);
  }

  Duration getRemainingDuration(int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );
    if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled.difference(now);
  }

  bool isScheduledForToday(int hour, int minute) {
    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );
    return scheduled.isAfter(now);
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
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      ticker: 'Daily Hadith Reminder',
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

      try {
        await _notificationsPlugin.zonedSchedule(
          dailyReminderNotificationId,
          title,
          previewText,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: hadith.id.toString(),
        );
        debugPrint('Scheduled exact daily reminder for $scheduledDate (local: ${scheduledDate.toLocal()})');
      } catch (e) {
        debugPrint('Exact alarm fallback to inexact: $e');
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
        debugPrint('Scheduled inexact daily reminder for $scheduledDate');
      }
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  Future<void> scheduleTestNotification({
    int seconds = 10,
    required Hadith hadith,
  }) async {
    try {
      await requestPermissions();

      final fireTime = DateTime.now().add(Duration(seconds: seconds));
      final scheduledDate = tz.TZDateTime.from(fireTime, tz.local);

      final title = '📖 Test Hadith (${seconds}s): ${hadith.topicEn}';
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

      try {
        await _notificationsPlugin.cancel(testNotificationId);
      } catch (_) {}

      try {
        await _notificationsPlugin.zonedSchedule(
          testNotificationId,
          title,
          previewText,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: hadith.id.toString(),
        );
        debugPrint('Scheduled exact test notification in $seconds seconds ($scheduledDate)');
      } catch (e) {
        debugPrint('Exact test alarm fallback to inexact: $e');
        await _notificationsPlugin.zonedSchedule(
          testNotificationId,
          title,
          previewText,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: hadith.id.toString(),
        );
      }
    } catch (e) {
      debugPrint('Error in scheduleTestNotification: $e');
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
