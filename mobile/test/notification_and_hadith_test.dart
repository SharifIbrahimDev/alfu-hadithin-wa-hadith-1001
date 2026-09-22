import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:alfu_hadithin_wa_hadith/services/hadith_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
  });

  group('Daily Hadith Selection Tests', () {
    test('getDailyHadith returns fallback hadith when empty', () {
      final service = HadithService();
      final daily = service.getDailyHadith();
      expect(daily.id, 1);
      expect(daily.topicEn, 'Actions are judged by intentions');
      expect(daily.arabicMatn, contains('إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ'));
    });
  });

  group('Notification Timezone Scheduling Tests', () {
    test('Calculates +2 minutes in future accurately', () {
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

      // Verify the scheduled time is strictly after now
      expect(scheduledDateTime.isAfter(now), isTrue);
      expect(scheduledTZ.millisecondsSinceEpoch, scheduledDateTime.millisecondsSinceEpoch);

      final diffSeconds = scheduledDateTime.difference(now).inSeconds;
      expect(diffSeconds, greaterThanOrEqualTo(60));
      expect(diffSeconds, lessThanOrEqualTo(120));
      print('✓ +2 mins test scheduled for: $scheduledDateTime (in $diffSeconds seconds)');
    });

    test('Wraps around to tomorrow if scheduled time has already passed today', () {
      final now = DateTime.now();
      // 10 minutes in the past
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
  });
}
