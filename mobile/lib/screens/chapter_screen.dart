import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (chapter.id == 21 || hadiths.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.englishTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                chapter.arabicTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Epilogue',
              onPressed: () {
                _shareEpilogue(context);
              },
            ),
          ],
        ),
        body: _EpilogueView(chapter: chapter, isDark: isDark),
      );
    }

    final readCount = hadiths.where((h) => provider.isRead(h.id)).length;
    final totalCount = hadiths.length;
    final progress = totalCount > 0 ? (readCount / totalCount) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.englishTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              chapter.arabicTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13,
                color: Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chapter Progress & Stats Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$readCount of $totalCount Hadiths completed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: isDark ? Colors.white12 : Colors.black12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: hadiths.length,
              itemBuilder: (context, index) {
                final hadith = hadiths[index];
                return HadithListCard(hadith: hadith);
              },
            ),
          ),
        ],
      ),
    );
  }

  static void _shareEpilogue(BuildContext context) {
    const shareText = '''📜 خَاتِمَةُ كِتَابِ «أَلْفُ حَدِيثٍ وَحَدِيثٌ — 1001 Authentic Hadith»
بِقَلَمِ الْمُؤَلِّفِ وَالْجَامِعِ: إِبْرَاهِيم شَرِيف أَبُوبَكْر (Ibrahim Sharif Abubakar)

🌟 حَمْدُ اللَّهِ وَالثَّنَاءُ عَلَيْهِ:
«الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ... اللَّهُمَّ إِنِّي أَسْأَلُكَ أَنْ تَجْعَلَ عَمَلِي هَذَا خَالِصًا لِوَجْهِكَ الْكَرِيمِ، وَاغْفِرْ لِي وَلِوَالِدَيَّ وَلِمَشَايِخِي وَلِكُلِّ مَنْ قَرَأَ هَذَا الْكِتَابَ أَوْ عَمِلَ بِمَا فِيهِ.»

تم بحمد الله وتوفيقه في 10 محرم 1448 هـ (يوم عاشوراء) — 25 يونيو 2026م.
📖 تطبيق ألف حديث وحديث — 1001 Authentic Hadith''';

    Share.share(shareText, subject: 'Epilogue — 1001 Authentic Hadith');
  }
}

class _EpilogueView extends StatelessWidget {
  final Chapter chapter;
  final bool isDark;

  const _EpilogueView({Key? key, required this.chapter, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Hero Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F766E).withOpacity(0.4), const Color(0xFFD97706).withOpacity(0.2)]
                    : [const Color(0xFFCCFBF1), const Color(0xFFFEF3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF0D9488).withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                const Text('📜', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 8),
                const Text(
                  'خَاتِمَةُ الْكِتَابِ وَوَصِيَّتِي',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F766E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Epilogue & Author\'s Concluding Testament',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Author & Timeline Badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'AUTHOR & COMPILER • الْمُؤَلِّفُ وَالْجَامِعُ',
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Ibrahim Sharif Abubakar',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'إِبْرَاهِيم شَرِيف أَبُوبَكْر',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Divider(height: 20),
                      Text(
                        '📅 Completed on: Thursday, 10 Muharram 1448 AH (Day of \'Ashura)\n25 June 2026 (25/06/2026) | 10/01/1448 هـ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Basmalah Callout
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
            ),
            child: Column(
              children: const [
                Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'In the Name of Allah, the Entirely Merciful, the Especially Merciful',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 1: Praise & Gratitude (Arabic)
          _buildArabicCard(
            title: '🌟 حَمْدُ اللَّهِ وَالثَّنَاءُ عَلَيْهِ عَلَى إِتْمَامِ هَذَا الْمُصَنَّفِ',
            content:
                'الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ، وَبِفَضْلِهِ وَتَوْفِيقِهِ تَتَنَزَّلُ الْبَرَكَاتُ، وَالصَّلَاةُ وَالسَّلَامُ الْأَتَمَّانِ الْأَكْمَلَانِ عَلَى خَاتَمِ النَّبِيِّينَ وَإِمَامِ الْمُرْسَلِينَ، نَبِيِّنَا وَحَبِيبِنَا مُحَمَّدٍ، وَعَلَى آلِهِ وَصَحْبِهِ أَجْمَعِينَ.\n\n'
                'أَمَّا بَعْدُ:\n'
                'فَإِنِّي أَحْمَدُ اللَّهَ تَعَالَى حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ عَلَى أَنْ وَفَّقَنِي وَيَسَّرَ لِي إِتْمَامَ هَذَا الْكِتَابِ الْجَامِعِ: «أَلْفُ حَدِيثٍ وَحَدِيثٌ — 1001 Authentic Hadith»، الَّذِي بَذَلْتُ فِيهِ جُهْدِي فِي جَمْعِ صِحَاحِ السُّنَّةِ النَّبَوِيَّةِ وَتَنْقِيحِهَا وَتَبْوِيبِهَا لِتَكُونَ مَعِينًا صَافِيًا لِكُلِّ مُسْلِمٍ يَبْحَثُ عَنْ نُورِ الْوَحْيِ وَهَدْيِ الْمُصْطَفَى ﷺ.\n\n'
                'وَقَدْ تَمَّ الْفَرَاغُ مِنْ جَمْعِ هَذَا الْكِتَابِ الْمُبَارَكِ وَتَحْرِيرِهِ وَمُرَاجَعَتِهِ كَامِلًا بِفَضْلِ اللَّهِ وَمَنِّهِ فِي يَوْمِ الْخَمِيسِ 10 مِنْ شَهْرِ مُحَرَّمٍ لِعَامِ 1448 هـ (يَوْمِ عَاشُورَاءَ)، الْمُوَافِقِ 25 مِنْ شَهْرِ يُونْيُو لِعَامِ 2026م (10/01/1448 هـ — 25/06/2026م)، بَعْدَ رِحْلَةٍ عِلْمِيَّةٍ مُبَارَكَةٍ اسْتَمَرَّتْ مُنْذُ 2 رَمَضَانَ 1445 هـ (12 مَارِسَ 2024م).',
            cardBg: cardBg,
            borderColor: borderColor,
          ),

          const SizedBox(height: 16),

          // Section 2: Author's 4 Golden Testaments
          _buildArabicCard(
            title: '🕊️ وَصِيَّتِي لَكَ أَخِي الْقَارِئَ وَطَالِبَ الْعِلْمِ',
            content:
                'إِنَّ الْغَايَةَ الَّتِي مِنْ أَجْلِهَا جَمَعْتُ هَذِهِ الْأَحَادِيثَ لَيْسَتْ لِتُقْرَأَ كَلِمَاتٍ مُجَرَّدَةً أَوْ لِتُحْفَظَ أَلْفَاظًا فِي الصُّدُورِ فَحَسْبُ، بَلْ لِتَتَحَوَّلَ إِلَى مَنْهَجِ حَيَاةٍ، وَعَمَلٍ خَالِصٍ، وَخُلُقٍ رَفِيعٍ يُتَمَثَّلُ فِي سُلُوكِكَ الْيَوْمِيِّ.\n\n'
                'لِذَا فَإِنِّي أُوصِي نَفْسِي الْمُقَصِّرَةَ وَأُوصِيكَ بِمَا يَلِي:\n\n'
                '1️⃣ إِخْلَاصُ النِّيَّةِ لِلَّهِ تَعَالَى: اجْعَلْ قِرَاءَتَكَ وَتَعَلُّمَكَ لِهَذَا الْكِتَابِ ابْتِغَاءَ رِضْوَانِ اللَّهِ وَرَفْعِ الْجَهْلِ عَنْ نَفْسِكَ.\n\n'
                '2️⃣ الْعَمَلُ بِمَا تَعَلَّمْتَ: كُلَّمَا مَرَرْتَ بِحَدِيثٍ صَحِيحٍ فِي هَذَا السِّفْرِ، فَاعْزِمْ عَلَى تَطْبِيقِهِ وَالْعَمَلِ بِهِ لِتَكُونَ مِنْ أَهْلِ السُّنَّةِ قَوْلًا وَعَمَلًا.\n\n'
                '3️⃣ تَعْلِيمُهُ لِأَهْلِ بَيْتِكَ وَإِخْوَانِكَ: اجْعَلْ لِهَذَا الْكِتَابِ نَصِيبًا فِي مَجَالِسِ أُسْرَتِكَ، فَاقْرَأْ عَلَيْهِمْ مِنْ أَحَادِيثِهِ وَدَارِسْهُمْ فَوَائِدَهُ.\n\n'
                '4️⃣ الثَّبَاتُ عَلَى السُّنَّةِ: اعْتَصِمْ بِهَدْيِ النَّبِيِّ ﷺ وَسُنَّتِهِ الصَّحِيحَةِ فِي زَمَنِ الْفِتَنِ وَالشُّبُهَاتِ.',
            cardBg: cardBg,
            borderColor: borderColor,
          ),

          const SizedBox(height: 16),

          // Section 3: Concluding Du'a
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFFEF9C3), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20, color: Color(0xFFF59E0B)),
                      tooltip: 'Copy Du\'a',
                      onPressed: () {
                        const duaText = '''🤲 دُعَائِي وَابْتِهَالِي إِلَى اللَّهِ تَعَالَى:
• اللَّهُمَّ إِنِّي أَسْأَلُكَ أَنْ تَجْعَلَ عَمَلِي هَذَا خَالِصًا لِوَجْهِكَ الْكَرِيمِ، لَا تَبْتَغِي بِهِ نَفْسِي جَاهًا وَلَا سُمْعَةً وَلَا عَرَضًا مِنْ عَرَضِ الدُّنْيَا.
• اللَّهُمَّ اغْفِرْ لِي، وَلِوَالِدَيَّ، وَلِمَشَايِخِي وَمُعَلِّمِيَّ، وَلِكُلِّ مَنْ قَرَأَ هَذَا الْكِتَابَ أَوْ عَمِلَ بِمَا فِيهِ أَوْ دَلَّ عَلَيْهِ.
• اللَّهُمَّ اجْعَلْ هَذَا الْعَمَلَ ذُخْرًا لِي وَلِوَالِدَيَّ فِي مَوَازِينِ الْحَسَنَاتِ، وَحُجَّةً لِي لَا عَلَيَّ يَوْمَ لِقَائِكَ.
وَآخِرُ دَعْوَايَ أَنِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ.''';
                        Clipboard.setData(const ClipboardData(text: duaText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Du\'a copied to clipboard!')),
                        );
                      },
                    ),
                    const Text(
                      '🤲 دُعَائِي وَابْتِهَالِي إِلَى اللَّهِ تَعَالَى',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• اللَّهُمَّ إِنِّي أَسْأَلُكَ أَنْ تَجْعَلَ عَمَلِي هَذَا خَالِصًا لِوَجْهِكَ الْكَرِيمِ، لَا تَبْتَغِي بِهِ نَفْسِي جَاهًا وَلَا سُمْعَةً وَلَا عَرَضًا مِنْ عَرَضِ الدُّنْيَا.\n\n'
                  '• اللَّهُمَّ اغْفِرْ لِي، وَلِوَالِدَيَّ، وَلِمَشَايِخِي وَمُعَلِّمِيَّ، وَلِكُلِّ مَنْ قَرَأَ هَذَا الْكِتَابَ أَوْ عَمِلَ بِمَا فِيهِ أَوْ دَلَّ عَلَيْهِ.\n\n'
                  '• اللَّهُمَّ اجْعَلْ هَذَا الْعَمَلَ ذُخْرًا لِي وَلِوَالِدَيَّ فِي مَوَازِينِ الْحَسَنَاتِ، وَحُجَّةً لِي لَا عَلَيَّ يَوْمَ لِقَائِكَ.\n\n'
                  'وَآخِرُ دَعْوَايَ أَنِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ، وَصَلَّى اللَّهُ وَسَلَّمَ وَبَارَكَ عَلَى نَبِيِّنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ أَجْمَعِينَ.',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 17,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'كَتَبَهُ بِيَدِهِ الْفَقِيرُ إِلَى عَفْوِ رَبِّهِ:',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'إِبْرَاهِيم شَرِيف أَبُوبَكْر',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                      ),
                      Text(
                        'غَفَرَ اللَّهُ لَهُ وَلِوَالِدَيْهِ وَلِلْمُسْلِمِينَ',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // English Testament Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '🇬🇧 Author\'s Concluding Epilogue (English Rendering)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
                SizedBox(height: 12),
                Text(
                  'Praise and Gratitude upon Completion:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '"All praise is due to Allah, by Whose favor all good deeds reach fruition. I praise and thank my Lord profusely for enabling me and granting me the strength to complete this unified encyclopedia: 1001 Authentic Hadith (أَلْفُ حَدِيثٍ وَحَدِيثٌ). I have poured my earnest dedication into curating, verifying, and classifying these authentic prophetic gems so that they may serve as a pure and accessible fountain of light for every believer."',
                  style: TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                SizedBox(height: 14),
                Text(
                  'Personal Testament to the Seeker of Knowledge:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 6),
                Text('1. Sincerity (Ikhlas): Study these prophetic words purely seeking Allah\'s Pleasure.', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 4),
                Text('2. Action upon Knowledge (\'Amal): Resolve firmly to practice every authentic tradition in your daily conduct.', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 4),
                Text('3. Teaching Household: Read and discuss these hadiths within your family circle.', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 4),
                Text('4. Steadfast Adherence: Hold fast to the Sunnah in all circumstances.', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 14),
                Text(
                  'Concluding Supplication (Du\'a):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '"O Allah, I beseech You to make this work purely for Your Noble Countenance. O Allah, forgive me, my parents, my teachers, and every soul who reads, practices, or shares this work. Make this compendium a lasting treasure in my scale of good deeds on the Day of Judgment. All praise belongs to Allah, Lord of all the worlds."',
                  style: TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Sources & Scholarly Accreditation Seal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Color(0xFF0D9488), size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Verified Scholarly Compendium',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '1001 Hadiths verified via Maktaba Shamela across Sahih al-Bukhari, Sahih Muslim, Sunan Abi Dawud, Jami` at-Tirmidhi, Sunan an-Nasa\'i, Sunan Ibn Majah, Muwatta Malik, and Musnad Ahmad.',
                        style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildArabicCard({
    required String title,
    required String content,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D9488),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
