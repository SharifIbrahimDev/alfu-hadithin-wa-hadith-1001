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
  static const int dailyReminderOneShotId = 1002;
  static const int testNotificationId = 9999;
  static const String channelId = 'daily_hadith_reminder_channel_v7';
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
          await androidNotificationPlugin.deleteNotificationChannel('daily_hadith_reminder_channel_v5');
          await androidNotificationPlugin.deleteNotificationChannel('daily_hadith_reminder_channel_v6');
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

      // Cancel any pending test notifications
      try {
        await _notificationsPlugin.cancel(testNotificationId);
      } catch (_) {}

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

  /// Checks whether exact alarms can be scheduled on Android 12+
  Future<bool> canScheduleExactAlarms() async {
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
          } catch (e) {
            debugPrint('Error requesting exact alarm permission: $e');
          }

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

  /// Explicitly prompt for exact alarm permission (Android 12/13/14+)
  Future<void> requestExactAlarmsPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Error in requestExactAlarmsPermission: $e');
    }
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

    // If the scheduled time is in the past or current minute, schedule for tomorrow safely
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
      await _configureLocalTimeZone();
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

      debugPrint('NotificationService: Scheduling daily reminder for $scheduledDate (current local: ${tz.TZDateTime.now(tz.local)})');

      final canExact = await canScheduleExactAlarms();
      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      // ── DUAL RELIABILITY SCHEDULING ─────────────────────────────────────────
      // 1. Primary Daily Recurring Schedule (DateTimeComponents.time)
      try {
        await _notificationsPlugin.zonedSchedule(
          dailyReminderNotificationId,
          title,
          previewText,
          scheduledDate,
          details,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: hadith.id.toString(),
        );
        debugPrint('NotificationService: Primary daily reminder scheduled ($scheduleMode) for $scheduledDate');
      } catch (e) {
        debugPrint('NotificationService: Primary schedule error ($e). Retrying with inexactAllowWhileIdle.');
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
          debugPrint('NotificationService: Recurring inexact fallback scheduled successfully.');
        } catch (e2) {
          debugPrint('NotificationService: Inexact recurring schedule also failed: $e2');
        }
      }

      // 2. Supplementary One-Shot Schedule for the immediate next occurrence
      // (Bypasses aggressive OEM background restrictions on recurring alarms)
      try {
        await _notificationsPlugin.zonedSchedule(
          dailyReminderOneShotId,
          title,
          previewText,
          scheduledDate,
          details,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: hadith.id.toString(),
        );
        debugPrint('NotificationService: Supplementary one-shot alarm scheduled ($scheduleMode) for $scheduledDate');
      } catch (e) {
        debugPrint('NotificationService: Supplementary one-shot schedule error: $e');
      }

      final pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('NotificationService: Active pending requests count = ${pending.length}');
      for (final p in pending) {
        debugPrint('  - ID: ${p.id}, Title: ${p.title}');
      }
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  Future<void> scheduleTestNotification({
    int seconds = 15,
    required Hadith hadith,
  }) async {
    try {
      await requestPermissions();
      await _configureLocalTimeZone();

      _testTimer?.cancel();
      try {
        await _notificationsPlugin.cancel(testNotificationId);
      } catch (_) {}

      final fireTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

      final durationLabel = seconds >= 60
          ? (seconds % 60 == 0 ? '${seconds ~/ 60}m' : '${seconds ~/ 60}m ${seconds % 60}s')
          : '${seconds}s';

      final title = '📖 Hadith Reminder ($durationLabel): ${hadith.topicEn}';
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

      // In-app timer fallback for short tests when app stays open
      if (seconds <= 30) {
        _testTimer = Timer(Duration(seconds: seconds), () async {
          await showInstantTestNotification(hadith: hadith);
        });
      }

      // Android hardware alarm to wake device from deep Doze
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
        debugPrint('NotificationService: Scheduled alarmClock test alarm in $seconds seconds ($fireTime)');
        return;
      } catch (e) {
        debugPrint('alarmClock test failed ($e), trying exactAllowWhileIdle');
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
          debugPrint('NotificationService: Scheduled exactAllowWhileIdle test in $seconds seconds');
        } catch (e2) {
          debugPrint('exactAllowWhileIdle failed ($e2), trying inexact fallback');
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

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error querying pending notifications: $e');
      return [];
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      _testTimer?.cancel();
      await _notificationsPlugin.cancel(dailyReminderNotificationId);
      await _notificationsPlugin.cancel(dailyReminderOneShotId);
      await _notificationsPlugin.cancel(testNotificationId);
      debugPrint('NotificationService: Cancelled daily reminders ($dailyReminderNotificationId, $dailyReminderOneShotId)');
    } catch (e) {
      debugPrint('Error cancelling daily reminder: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      _testTimer?.cancel();
      await _notificationsPlugin.cancelAll();
      debugPrint('NotificationService: Cancelled all notifications');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
