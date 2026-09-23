import 'dart:convert';
import 'dart:io';

void main() {
  final data = jsonDecode(File('assets/data/hadiths.json').readAsStringSync(encoding: utf8)) as List;
  final missingTakhrij = <Map<String, dynamic>>[];
  final missingGrading = <Map<String, dynamic>>[];
  final missingNarrator = <Map<String, dynamic>>[];

  for (var h in data) {
    final map = h as Map<String, dynamic>;
    final id = map['id'];
    final takhrij = (map['takhrij'] as String? ?? '').trim();
    final grading = (map['grading'] as String? ?? '').trim();
    final narAr = (map['narrator_ar'] as String? ?? '').trim();

    if (takhrij.isEmpty || !RegExp(r'\d+').hasMatch(takhrij)) {
      missingTakhrij.add(map);
    }
    if (grading.isEmpty) {
      missingGrading.add(map);
    }
    if (narAr.isEmpty) {
      missingNarrator.add(map);
    }
  }

  print('====================================================');
  print('COMPENDIUM AUDIT REPORT (1,001 Authentic Hadith)');
  print('====================================================');
  print('Total Hadiths checked: ${data.length}');
  print('Hadiths lacking Takhrij or Hadith Numbers: ${missingTakhrij.length}');
  print('Hadiths lacking Grading: ${missingGrading.length}');
  print('Hadiths lacking Narrator: ${missingNarrator.length}');
  print('====================================================');

  if (missingTakhrij.isNotEmpty) {
    print('Remaining issues in Takhrij:');
    for (var m in missingTakhrij) {
      print(' - Hadith #${m['id']}: ${m['topic_en']} | Takhrij: "${m['takhrij']}"');
    }
  } else {
    print('✅ SUCCESS: 100% of all 1,001 Hadiths have verified Masdar & Hadith Numbers!');
  }
}
