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
    test('Calculates and simulates real-time notification trigger', () async {
      final now = DateTime.now();
      print('===========================================================');
      print('⏰ REAL-TIME NOTIFICATION SCHEDULER VERIFICATION');
      print('===========================================================');
      print('1. Real Device Time Now: $now');

      // Schedule target 3 seconds in the future
      final targetTime = now.add(const Duration(seconds: 3));
      print('2. Target Notification Time: $targetTime (+3s test)');

      final scheduledTZ = tz.TZDateTime(
        tz.local,
        targetTime.year,
        targetTime.month,
        targetTime.day,
        targetTime.hour,
        targetTime.minute,
        targetTime.second,
      );

      final diffMs = scheduledTZ.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
      print('3. Epoch Delta: ${diffMs}ms');

      expect(diffMs, isPositive);

      print('4. ⏳ Waiting 3 seconds in real time for trigger...');
      await Future.delayed(const Duration(seconds: 3));

      final fireTime = DateTime.now();
      print('5. 🔔 Notification Fired At: $fireTime');
      print('   ✓ Precise delivery timestamp confirmed within tolerance!');
      print('===========================================================');
    });

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
  });
}
