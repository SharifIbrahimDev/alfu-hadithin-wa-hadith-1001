import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hadith.dart';
import '../providers/app_provider.dart';
import '../screens/hadith_reader_screen.dart';
import '../widgets/share_card_dialog.dart';

class HadithListCard extends StatelessWidget {
  final Hadith hadith;
  final String? highlightQuery;

  const HadithListCard({Key? key, required this.hadith, this.highlightQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRead = provider.isRead(hadith.id);
    final isBookmarked = provider.isBookmarked(hadith.id);

    final chapter = provider.service.allChapters
        .where((c) => c.id == hadith.chapterId)
        .firstOrNull;
    final chapterLabel = chapter?.englishTitle ??
        (hadith.chapterTitleEn.isNotEmpty
            ? hadith.chapterTitleEn
            : 'Chapter ${hadith.chapterId}');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
      ),
      elevation: 0,
      color: isDark ? const Color(0xFF162238) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HadithReaderScreen(initialHadithId: hadith.id),
            ),
          );
        },
        onLongPress: () {
          ShareCardDialog.show(context, hadith);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isRead
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : const Color(0xFF0D9488).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRead
                        ? const Color(0xFF10B981).withOpacity(0.4)
                        : const Color(0xFF0D9488).withOpacity(0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${hadith.id}',
                  style: TextStyle(
                    color: isRead ? const Color(0xFF10B981) : const Color(0xFF14B8A6),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hadith.topicAr.isNotEmpty ? hadith.topicAr : hadith.arabicMatn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildHighlightedText(
                      text: hadith.topicEn.isNotEmpty ? hadith.topicEn : hadith.englishTranslation,
                      query: highlightQuery,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapterLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (isBookmarked) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.bookmark_rounded, size: 14, color: Color(0xFFF59E0B)),
                        ],
                        if (isRead) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hadith.grading.isNotEmpty ? hadith.grading : 'Sahih',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText({
    required String text,
    required String? query,
    required bool isDark,
  }) {
    final baseStyle = TextStyle(
      fontSize: 13,
      color: isDark ? Colors.grey[400] : Colors.grey[700],
    );

    if (query == null || query.trim().isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final q = query.trim().toLowerCase();
    final lower = text.toLowerCase();
    final index = lower.indexOf(q);

    if (index == -1) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final before = text.substring(0, index);
    final match = text.substring(index, index + q.length);
    final after = text.substring(index + q.length);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: const TextStyle(
              backgroundColor: Color(0xFFF59E0B),
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
