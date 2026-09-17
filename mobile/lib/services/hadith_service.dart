import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hadith.dart';
import '../models/chapter.dart';

class HadithService {
  List<Hadith> _hadiths = [];
  List<Chapter> _chapters = [];

  List<Hadith> get allHadiths => _hadiths;
  List<Chapter> get allChapters => _chapters;

  Future<void> loadData() async {
    try {
      final hadithsJsonStr = await rootBundle.loadString('assets/data/hadiths.json');
      final List<dynamic> hadithList = jsonDecode(hadithsJsonStr);
      _hadiths = hadithList.map((j) => Hadith.fromJson(j as Map<String, dynamic>)).toList();

      final chaptersJsonStr = await rootBundle.loadString('assets/data/chapters.json');
      final Map<String, dynamic> chaptersMap = jsonDecode(chaptersJsonStr);
      final List<dynamic> chaptersList = chaptersMap['chapters'] as List<dynamic>? ?? [];
      _chapters = chaptersList.map((j) => Chapter.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading hadith service data: $e');
    }
  }

  List<Hadith> getHadithsForChapter(int chapterId) {
    return _hadiths.where((h) => h.chapterId == chapterId).toList();
  }

  Hadith? getHadithById(int id) {
    try {
      return _hadiths.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Hadith getDailyHadith() {
    if (_hadiths.isEmpty) {
      return Hadith(
        id: 1,
        idStr: '#0001',
        chapterId: 0,
        chapterTitleAr: 'مقدمة في الإخلاص',
        chapterTitleEn: 'Prologue: Sincerity',
        topicAr: 'إنما الأعمال بالنيات',
        topicEn: 'Actions are judged by intentions',
        arabicMatn: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        narratorAr: 'عمر بن الخطاب',
        narratorEn: 'Umar ibn al-Khattab',
        englishTranslation: 'Actions are judged only by intentions.',
        takhrij: 'Sahih al-Bukhari',
        grading: 'Sahih',
        benefitsAr: '',
        benefitsEn: '',
      );
    }
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _hadiths[dayOfYear % _hadiths.length];
  }

  List<Hadith> search(String query) {
    final raw = query.trim().toLowerCase();
    if (raw.isEmpty) return _hadiths;

    final normQ = _normalizeArabic(raw);

    return _hadiths.where((h) {
      if (h.id.toString() == raw || h.idStr.toLowerCase().contains(raw)) return true;
      if (h.englishTranslation.toLowerCase().contains(raw) ||
          h.topicEn.toLowerCase().contains(raw) ||
          h.narratorEn.toLowerCase().contains(raw)) return true;

      final normMatn = _normalizeArabic(h.arabicMatn);
      final normTopicAr = _normalizeArabic(h.topicAr);
      return normMatn.contains(normQ) || normTopicAr.contains(normQ);
    }).toList();
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // Remove Tashkeel
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .toLowerCase();
  }
}
