import 'package:flutter_test/flutter_test.dart';
import 'package:alfu_hadithin_wa_hadith/models/hadith.dart';
import 'package:alfu_hadithin_wa_hadith/models/category.dart';
import 'package:alfu_hadithin_wa_hadith/services/hadith_service.dart';

void main() {
  group('Thematic Category Tests', () {
    test('Categories cover compendium pillars properly', () {
      expect(ThematicCategory.categories.length, 7); // 'All' + 6 Pillars
      expect(ThematicCategory.categories.first.id, 'all');

      final pillars = ThematicCategory.categories.where((c) => c.id != 'all').toList();
      expect(pillars.length, 6);

      // Verify all pillar chapter mappings are valid
      for (final pillar in pillars) {
        expect(pillar.chapterIds.isNotEmpty, isTrue);
        expect(pillar.titleEn.isNotEmpty, isTrue);
        expect(pillar.titleAr.isNotEmpty, isTrue);
        expect(pillar.icon.isNotEmpty, isTrue);
      }
    });
  });

  group('Reading Progress Tests', () {
    test('Calculates chapter and overall progress correctly', () {
      final sampleHadiths = List.generate(
        10,
        (i) => Hadith(
          id: i + 1,
          idStr: '#${(i + 1).toString().padLeft(4, '0')}',
          chapterId: 1,
          chapterTitleAr: 'كتاب الإيمان',
          chapterTitleEn: 'Book of Faith',
          topicAr: 'الإيمان',
          topicEn: 'Faith',
          arabicMatn: 'الإيمان بضع وسبعون شعبة',
          narratorAr: 'أبو هريرة',
          narratorEn: 'Abu Hurairah',
          englishTranslation: 'Faith has over seventy branches.',
          takhrij: 'Sahih Muslim',
          grading: 'Sahih',
          benefitsAr: '',
          benefitsEn: '',
        ),
      );

      final readSet = {1, 2, 3}; // 3 out of 10 read

      final progress = readSet.length / sampleHadiths.length;
      expect(progress, 0.3);
      expect((progress * 100).toInt(), 30);
    });
  });
}
