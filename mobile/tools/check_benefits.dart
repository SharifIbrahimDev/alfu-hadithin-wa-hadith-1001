import 'dart:convert';
import 'dart:io';

void main() {
  final data = jsonDecode(File('assets/data/hadiths.json').readAsStringSync(encoding: utf8)) as List;
  
  final missingBenefitsAr = <int>[];
  final missingBenefitsEn = <int>[];
  final shortBenefitsAr = <int>[];
  final shortBenefitsEn = <int>[];
  
  for (var h in data) {
    final map = h as Map<String, dynamic>;
    final id = map['id'] as int;
    final bAr = (map['benefits_ar'] as String? ?? '').trim();
    final bEn = (map['benefits_en'] as String? ?? '').trim();
    
    if (bAr.isEmpty) {
      missingBenefitsAr.add(id);
    } else if (bAr.length < 15) {
      shortBenefitsAr.add(id);
    }
    
    if (bEn.isEmpty) {
      missingBenefitsEn.add(id);
    } else if (bEn.length < 15) {
      shortBenefitsEn.add(id);
    }
  }
  
  print('====================================================');
  print('FAWAIDUL HADITH (BENEFITS) AUDIT REPORT');
  print('====================================================');
  print('Total Hadiths: ${data.length}');
  print('Missing Arabic Benefits (benefits_ar): ${missingBenefitsAr.length}');
  print('Missing English Benefits (benefits_en): ${missingBenefitsEn.length}');
  print('Suspiciously Short Arabic Benefits: ${shortBenefitsAr.length}');
  print('Suspiciously Short English Benefits: ${shortBenefitsEn.length}');
  print('====================================================');
  
  print('Missing Arabic Benefits IDs:');
  print(missingBenefitsAr);
  
  print('Missing English Benefits IDs:');
  print(missingBenefitsEn);
  
  if (shortBenefitsAr.isNotEmpty) {
    print('Short Arabic Benefits IDs: $shortBenefitsAr');
  }
  if (shortBenefitsEn.isNotEmpty) {
    print('Short English Benefits IDs: $shortBenefitsEn');
  }
}
