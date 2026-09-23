import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('assets/data/hadiths.json');
  final list = jsonDecode(await file.readAsString(encoding: utf8)) as List;

  int updated = 0;
  for (var item in list) {
    final map = item as Map<String, dynamic>;
    var narAr = (map['narrator_ar'] as String? ?? '').trim();
    var narEn = (map['narrator_en'] as String? ?? '').trim();
    final matn = (map['arabic_matn'] as String? ?? '').trim();

    if (narAr.isEmpty) {
      // Try extract from matn starting with عَنْ ... قَالَ or similar
      final match = RegExp(r'^عَنْ\s+([^،:]+?)(?:،|\s+قَالَ|\s+عَنِ|\s+أَنَّ|\s+رَضِيَ)').firstMatch(matn);
      if (match != null) {
        narAr = 'عَنْ ${match.group(1)!.trim()} رَضِيَ اللَّهُ عَنْهُ.';
        map['narrator_ar'] = narAr;
        updated++;
      } else if (narEn.isNotEmpty) {
        narAr = narEn;
        map['narrator_ar'] = narAr;
        updated++;
      }
    }

    if (narEn.isEmpty && narAr.isNotEmpty) {
      map['narrator_en'] = narAr;
    }
  }

  final encoder = const JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(list), encoding: utf8);
  print('Updated $updated missing narrators in assets/data/hadiths.json');
}
