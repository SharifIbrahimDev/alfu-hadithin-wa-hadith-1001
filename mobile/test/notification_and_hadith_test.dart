import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:alfu_hadithin_wa_hadith/services/hadith_service.dart';
import 'package:alfu_hadithin_wa_hadith/services/notification_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    // Configure local timezone matching system offset
    final now = DateTime.now();
    final offsetMs = now.timeZoneOffset.inMilliseconds;
    for (final locName in tz.timeZoneDatabase.locations.keys) {
      final loc = tz.getLocation(locName);
      if (loc.currentTimeZone.offset == offsetMs) {
        tz.setLocalLocation(loc);
        break;
      }
    }
  });

  group('Daily Hadith Selection Tests', () {
    test('getDailyHadith returns valid authentic hadith', () {
      final service = HadithService();
      final daily = service.getDailyHadith();
      expect(daily.id, isPositive);
      expect(daily.topicEn.isNotEmpty, isTrue);
      expect(daily.arabicMatn.isNotEmpty, isTrue);
      print('✓ Daily Hadith: "${daily.topicEn}" (#${daily.id})');
    });
  });

  group('Real-Time Notification Scheduling Tests', () {
    test('Calculates and verifies 10-second exact test alarm', () async {
      final now = DateTime.now();
      final fireTime = now.add(const Duration(seconds: 10));
      final scheduledTZ = tz.TZDateTime.from(fireTime, tz.local);

      final diffSeconds = (scheduledTZ.millisecondsSinceEpoch - now.millisecondsSinceEpoch) / 1000;
      expect(diffSeconds, closeTo(10, 0.05));
      expect(scheduledTZ.millisecondsSinceEpoch, fireTime.millisecondsSinceEpoch);

      print('===========================================================');
      print('⏰ 10-SECOND EXACT TEST ALARM VERIFICATION');
      print('===========================================================');
      print('1. Current Local Time: $now');
      print('2. Fire Target Time:   $fireTime');
      print('3. Scheduled TZ Time:  $scheduledTZ');
      print('4. Epoch Millis Delta: ${(diffSeconds * 1000).toInt()}ms (exact 10.0s)');
      print('===========================================================');
    });

    test('Calculates +2 minutes in future accurately without timezone skew', () {
      final now = DateTime.now();
      final target = now.add(const Duration(minutes: 2));

      var scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        target.hour,
        target.minute,
        0,
      );

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      }

      final scheduledTZ = tz.TZDateTime.from(scheduledDateTime, tz.local);

      expect(scheduledDateTime.isAfter(now), isTrue);
      expect(scheduledTZ.millisecondsSinceEpoch, scheduledDateTime.millisecondsSinceEpoch);

      final diffSeconds = scheduledDateTime.difference(now).inSeconds;
      expect(diffSeconds, greaterThanOrEqualTo(60));
      expect(diffSeconds, lessThanOrEqualTo(120));
      print('✓ +2 mins test scheduled for: $scheduledDateTime (in $diffSeconds seconds)');
    });

    test('Wraps around to tomorrow if scheduled time has already passed today', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(minutes: 10));

      var scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        past.hour,
        past.minute,
        0,
      );

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      }

      final scheduledTZ = tz.TZDateTime.from(scheduledDateTime, tz.local);

      expect(scheduledDateTime.isAfter(now), isTrue);
      expect(scheduledDateTime.day, (now.add(const Duration(days: 1))).day);
      expect(scheduledTZ.millisecondsSinceEpoch, scheduledDateTime.millisecondsSinceEpoch);
      print('✓ Passed time wrapped to tomorrow: $scheduledDateTime');
    });

    test('NotificationService helper functions calculate durations accurately', () {
      final notifService = NotificationService();
      final now = DateTime.now();
      final futureTime = now.add(const Duration(minutes: 30));

      final duration = notifService.getRemainingDuration(futureTime.hour, futureTime.minute);
      expect(duration.inMinutes, greaterThanOrEqualTo(28));
      expect(duration.inMinutes, lessThanOrEqualTo(30));

      final isToday = notifService.isScheduledForToday(futureTime.hour, futureTime.minute);
      expect(isToday, isTrue);
    });
  });
}
