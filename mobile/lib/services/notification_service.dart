import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  static const String channelId = 'daily_hadith_reminder_channel_v5';
  static const String channelName = 'Daily Hadith Reminder';
  static const String channelDescription =
      'Daily authentic Hadith reminders and notifications from 1001 Authentic Hadith';

  Function(int hadithId)? _onNotificationSelected;
  bool _initialized = false;
  Timer? _testTimer;

  Future<void> initialize({Function(int hadithId)? onSelectHadith}) async {
    if (_initialized && onSelectHadith == null) return;
    if (onSelectHadith != null) {
      _onNotificationSelected = onSelectHadith;
    }

    await _configureLocalTimeZone();

    try {
      // Android settings - use standard app launcher icon
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS / macOS Darwin settings
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false, // Explicitly requested via UI/startup
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

      // Create High-Priority Notification Channel for Android 8.0+
      final androidNotificationPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidNotificationPlugin != null) {
        // Clean up legacy channel IDs if they exist
        try {
          await androidNotificationPlugin.deleteNotificationChannel('daily_hadith_reminder_channel_v1');
          await androidNotificationPlugin.deleteNotificationChannel('daily_hadith_reminder_channel_v2');
          await androidNotificationPlugin.deleteNotificationChannel('daily_hadith_reminder_channel_v3');
          await androidNotificationPlugin.deleteNotificationChannel('daily_hadith_reminder_channel_v4');
        } catch (_) {}

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
      debugPrint('NotificationService: Initialized successfully with channel $channelId');
    } catch (e) {
      debugPrint('Error during NotificationService initialize: $e');
    }
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      if (tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('NotificationService: Local timezone initialized to $timeZoneName');
        return;
      }
    } catch (e) {
      debugPrint('NotificationService: Timezone lookup by name failed ($e). Attempting offset matching.');
    }

    // Offset-based fallback for OEM ROMs (Samsung, Infinix, Xiaomi)
    try {
      final now = DateTime.now();
      final offsetMs = now.timeZoneOffset.inMilliseconds;

      for (final locName in tz.timeZoneDatabase.locations.keys) {
        final loc = tz.getLocation(locName);
        if (tz.TZDateTime.from(now, loc).timeZoneOffset.inMilliseconds == offsetMs) {
          tz.setLocalLocation(loc);
          debugPrint('NotificationService: Local timezone matched by offset ($offsetMs ms) -> $locName');
          return;
        }
      }
    } catch (e) {
      debugPrint('NotificationService: Offset fallback error: $e');
    }

    // Default to UTC location if all else fails
    try {
      tz.setLocalLocation(tz.getLocation('UTC'));
    } catch (_) {}
  }

  /// Checks whether notifications are currently allowed by the OS
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final areEnabled =
              await androidImplementation.areNotificationsEnabled();
          return areEnabled ?? false;
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        final darwinImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (darwinImplementation != null) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking notification status: $e');
    }
    return true;
  }

  /// Requests runtime notification and exact alarm permissions
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
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    // If the scheduled time is in the past or current second, schedule for tomorrow
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Duration getRemainingDuration(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
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
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(
      tz.local,
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

      // Attempt exactAllowWhileIdle first for repeating daily schedule
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
        debugPrint('Scheduled exactAllowWhileIdle daily reminder for $scheduledDate');
      } catch (e) {
        debugPrint('exactAllowWhileIdle failed, falling back to inexactAllowWhileIdle: $e');
        try {
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
          debugPrint('Scheduled inexactAllowWhileIdle daily reminder for $scheduledDate');
        } catch (e2) {
          debugPrint('Error in fallback daily reminder: $e2');
        }
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

      _testTimer?.cancel();
      final fireTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

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

      // 1. In-app Timer backup for when the user stays inside the app
      _testTimer = Timer(Duration(seconds: seconds), () async {
        await showInstantTestNotification(hadith: hadith);
      });

      // 2. Android scheduled Alarm for when screen is locked or app is in background
      try {
        await _notificationsPlugin.zonedSchedule(
          testNotificationId,
          title,
          previewText,
          fireTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: hadith.id.toString(),
        );
        debugPrint('Scheduled exactAllowWhileIdle test notification in $seconds seconds ($fireTime)');
      } catch (e) {
        debugPrint('exactAllowWhileIdle failed, trying alarmClock: $e');
        try {
          await _notificationsPlugin.zonedSchedule(
            testNotificationId,
            title,
            previewText,
            fireTime,
            details,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: hadith.id.toString(),
          );
        } catch (e2) {
          debugPrint('alarmClock failed, trying inexact: $e2');
          await _notificationsPlugin.zonedSchedule(
            testNotificationId,
            title,
            previewText,
            fireTime,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: hadith.id.toString(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in scheduleTestNotification: $e');
    }
  }

  Future<void> showInstantTestNotification({required Hadith hadith}) async {
    try {
      await requestPermissions();

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
      debugPrint('NotificationService: Instant notification sent');
    } catch (e) {
      debugPrint('Error showing instant test notification: $e');
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      _testTimer?.cancel();
      await _notificationsPlugin.cancel(dailyReminderNotificationId);
    } catch (e) {
      debugPrint('Error cancelling daily reminder: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      _testTimer?.cancel();
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
