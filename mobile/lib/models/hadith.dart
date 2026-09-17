class Hadith {
  final int id;
  final String idStr;
  final int chapterId;
  final String chapterTitleAr;
  final String chapterTitleEn;
  final String topicAr;
  final String topicEn;
  final String arabicMatn;
  final String narratorAr;
  final String narratorEn;
  final String englishTranslation;
  final String takhrij;
  final String grading;
  final String benefitsAr;
  final String benefitsEn;

  Hadith({
    required this.id,
    required this.idStr,
    required this.chapterId,
    required this.chapterTitleAr,
    required this.chapterTitleEn,
    required this.topicAr,
    required this.topicEn,
    required this.arabicMatn,
    required this.narratorAr,
    required this.narratorEn,
    required this.englishTranslation,
    required this.takhrij,
    required this.grading,
    required this.benefitsAr,
    required this.benefitsEn,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] as int? ?? 0,
      idStr: json['id_str'] as String? ?? '',
      chapterId: json['chapter_id'] as int? ?? 0,
      chapterTitleAr: json['chapter_title_ar'] as String? ?? '',
      chapterTitleEn: json['chapter_title_en'] as String? ?? '',
      topicAr: json['topic_ar'] as String? ?? '',
      topicEn: json['topic_en'] as String? ?? '',
      arabicMatn: json['arabic_matn'] as String? ?? '',
      narratorAr: json['narrator_ar'] as String? ?? '',
      narratorEn: json['narrator_en'] as String? ?? '',
      englishTranslation: json['english_translation'] as String? ?? '',
      takhrij: json['takhrij'] as String? ?? '',
      grading: json['grading'] as String? ?? 'Sahih',
      benefitsAr: json['benefits_ar'] as String? ?? '',
      benefitsEn: json['benefits_en'] as String? ?? '',
    );
  }
}
