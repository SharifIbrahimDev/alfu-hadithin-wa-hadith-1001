import 'dart:convert';
import 'dart:io';

import 'populate_all_takhrij_data.dart';
import 'populate_all_takhrij_data_part2.dart';
import 'populate_all_takhrij_data_part3.dart';
import 'populate_all_takhrij_data_part4.dart';
import 'populate_all_takhrij_data_part5.dart';

void main() async {
  final file = File('assets/data/hadiths.json');
  if (!file.existsSync()) {
    print('Error: assets/data/hadiths.json not found from current directory.');
    return;
  }

  final jsonStr = await file.readAsString(encoding: utf8);
  final List<dynamic> list = jsonDecode(jsonStr);

  final Map<int, TakhrijEntry> allEntries = {
    ...takhrijData,
    ...takhrijDataPart2,
    ...takhrijDataPart3,
    ...takhrijDataPart4,
    ...takhrijDataPart5,
  };

  print('Total Takhrij records prepared: ${allEntries.length}');

  int updatedCount = 0;
  for (var item in list) {
    final map = item as Map<String, dynamic>;
    final id = map['id'] as int;

    if (allEntries.containsKey(id)) {
      final entry = allEntries[id]!;
      map['takhrij'] = entry.takhrij;
      map['grading'] = entry.grading;
      if (entry.narratorAr.isNotEmpty && (map['narrator_ar'] == null || (map['narrator_ar'] as String).isEmpty)) {
        map['narrator_ar'] = entry.narratorAr;
      }
      if (entry.narratorEn.isNotEmpty && (map['narrator_en'] == null || (map['narrator_en'] as String).isEmpty)) {
        map['narrator_en'] = entry.narratorEn;
      }
      updatedCount++;
    }
  }

  final encoder = const JsonEncoder.withIndent('  ');
  final updatedJsonStr = encoder.convert(list);
  await file.writeAsString(updatedJsonStr, encoding: utf8);

  print('Successfully updated $updatedCount hadiths in assets/data/hadiths.json!');
}
