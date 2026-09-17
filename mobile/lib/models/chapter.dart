class Chapter {
  final int id;
  final String filename;
  final String arabicTitle;
  final String englishTitle;
  final int hadithCount;
  final int startId;
  final int endId;

  Chapter({
    required this.id,
    required this.filename,
    required this.arabicTitle,
    required this.englishTitle,
    required this.hadithCount,
    required this.startId,
    required this.endId,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int? ?? 0,
      filename: json['filename'] as String? ?? '',
      arabicTitle: json['arabic_title'] as String? ?? '',
      englishTitle: json['english_title'] as String? ?? '',
      hadithCount: json['hadith_count'] as int? ?? 0,
      startId: json['start_id'] as int? ?? 0,
      endId: json['end_id'] as int? ?? 0,
    );
  }
}
