import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chapter.dart';
import '../providers/app_provider.dart';
import '../widgets/hadith_card.dart';

class ChapterScreen extends StatelessWidget {
  final Chapter chapter;

  const ChapterScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final hadiths = provider.service.getHadithsForChapter(chapter.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.englishTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              chapter.arabicTitle,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13,
                color: Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: hadiths.length,
        itemBuilder: (context, index) {
          final hadith = hadiths[index];
          return HadithListCard(hadith: hadith);
        },
      ),
    );
  }
}
