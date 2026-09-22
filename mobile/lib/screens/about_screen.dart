import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Compendium Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D9488).withOpacity(0.2),
                    const Color(0xFFF59E0B).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('📖', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  const Text(
                    'أَلْفُ حَدِيثٍ وَحَدِيثٌ',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1001 Authentic Hadith Compendium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14B8A6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Author Attribution Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A101D) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                      ),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'AUTHOR & COMPILER • الْمُؤَلِّفُ وَالْجَامِعُ وَالْمُحَقِّقُ',
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Ibrahim Sharif Abubakar',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'إِبْرَاهِيم شَرِيف أَبُوبَكْر',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scholarly Texts (Muqaddimah, Tamheed, Khatimah)
            _buildBookSectionTile(
              context: context,
              icon: Icons.history_edu,
              titleArabic: 'مُقَدِّمَةُ الْمُؤَلِّفِ',
              titleEnglish: 'Author\'s Preface (Al-Muqaddimah)',
              description: 'Began: 2 Ramadan 1445 AH (12/03/2024)',
              isDark: isDark,
              onTap: () => _showTextModal(
                context,
                title: 'المُقَدِّمَةُ — Author\'s Preface',
                arabicContent: '''إِنَّ الْحَمْدَ لِلَّهِ، نَحْمَدُهُ وَنَسْتَعِينُهُ وَنَسْتَغْفِرُهُ، وَنَعُوذُ بِاللَّهِ مِنْ شُرُورِ أَنْفُسِنَا وَمِنْ سَيِّئَاتِ أَعْمَالِنَا، مَنْ يَهْدِهِ اللَّهُ فَلَا مُضِلَّ لَهُ، وَمَنْ يُضْلِلْ فَلَا هَادِيَ لَهُ.

وَأَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ ﷺ.

أَمَّا بَعْدُ:
فَإِنَّ كِتَابَ اللَّهِ تَعَالَى وَسُنَّةَ نَبِيِّهِ الْمُصْطَفَى ﷺ هُمَا مَنْبَعُ الْهِدَايَةِ، وَعِصْمَةُ الْمُسْلِمِ فِي أَمْرِ دِينِهِ وَدُنْيَاهُ. وَقَدْ رَأَيْتُ أَنَّ مِنْ أَعْظَمِ مَا أَتَقَرَّبُ بِهِ إِلَى رَبِّي جَلَّ وَعَلَا، وَأَنْفَعُ بِهِ إِخْوَانِي الْمُسْلِمِينَ، أَنْ أَقُومَ بِجَمْعِ هَذَا الْمُصَنَّفِ الْجَامِعِ: «أَلْفُ حَدِيثٍ وَحَدِيثٌ».

وَقَدْ شَرَعْتُ فِي جَمْعِ هَذَا الْكِتَابِ الْمُبَارَكِ وَتَحْرِيرِهِ فِي يَوْمِ الثُّلَاثَاءِ 2 مِنْ رَمَضَانَ 1445 هـ (12/03/2024م)، سَائِلًا الْمَوْلَى أَنْ يَتَقَبَّلَهُ مِنِّي بِقَبُولٍ حَسَنٍ.''',
                englishContent: '''"All praise is due to Allah; I praise Him, seek His aid, and ask His forgiveness. Whomever Allah guides, none can misguide; and whomever He allows to stray, none can guide. I bear witness that there is no deity worthy of worship except Allah alone without partner, and I bear witness that Muhammad ﷺ is His faithful servant and final Messenger."

I commenced the research and compilation of this compendium—«1001 Authentic Hadith (أَلْفُ حَدِيثٍ وَحَدِيثٌ)»—on Tuesday, 2 Ramadan 1445 AH (12 March 2024 / 12/03/2024) to provide every Muslim family with an accessible, authenticated treasury of prophetic wisdom. I pray that Allah accepts this humble effort purely for His sake.''',
              ),
            ),

            const SizedBox(height: 12),

            _buildBookSectionTile(
              context: context,
              icon: Icons.menu_book,
              titleArabic: 'تَمْهِيدُ الْكِتَابِ وَمَنْهَجِي',
              titleEnglish: 'My Methodology (Al-Tamheed)',
              description: 'Authenticity standards and classification principles',
              isDark: isDark,
              onTap: () => _showTextModal(
                context,
                title: 'التَّمْهِيدُ — My Scholarly Methodology',
                arabicContent: '''لَقَدِ الْتَزَمْتُ فِي إِعْدَادِ وَتَحْقِيقِ هَذَا الْمُصَنَّفِ بِمَنْهَجٍ عِلْمِيٍّ دَقِيقٍ:

1. الِاقْتِصَارُ عَلَى الصَّحِيحِ وَالثَّابِتِ: شَرَطْتُ عَلَى نَفْسِي أَلَّا أُودِعَ فِي هَذَا الْكِتَابِ إِلَّا مَا صَحَّ أَوْ حَسُنَ عَنْ رَسُولِ اللَّهِ ﷺ مِنْ أُمَّهَاتِ كُتُبِ السُّنَّةِ (صَحِيحِ الْبُخَارِيِّ، صَحِيحِ مُسْلِمٍ، السُّئَنِ الْأَرْبَعَةِ، مُوَطَّإِ مَالِكٍ، وَمُسْنَدِ أَحْمَدَ).
2. التَّبْوِيبُ الْمَوْضُوعِيُّ الشَّامِلُ: قَسَّمْتُ الْكِتَابَ إِلَى 20 بَابًا مَوْضُوعِيًّا يَحْوِي كُلُّ بَابٍ 50 حَدِيثًا صَحِيحًا مُسْتَهَلَّةً بِحَدِيثِ النِّيَّةِ (1001 حَدِيثٍ تَامَّةً).
3. الضَّبْطُ التَّامُّ بِالتَّشْكِيلِ لِتَيْسِيرِ الْقِرَاءَةِ وَالْحِفْظِ.
4. التَّخْرِيجُ الْعِلْمِيُّ الْمُوَثَّقُ مَعَ أَرْقَامِ الْأَحَادِيثِ فِي الْمَكْتَبَةِ الشَّامِلَةِ.
5. اسْتِنْبَاطُ الْفَوَائِدِ وَالْعِبَرِ الْعَقَدِيَّةِ وَالْفِقْهِيَّةِ وَالتَّرْبَوِيَّةِ.
6. التَّرْجَمَةُ الْإِنْجِلِيزِيَّةُ الْمُتْقَنَةُ لِعُمُومِ النَّفْعِ.''',
                englishContent: '''In compiling and editing this compendium, I have strictly adhered to the following scholarly methodology:

1. Strict Authenticity Standard: I have included only strictly authenticated (Sahih and established Hasan) traditions from canonical collections.
2. Comprehensive Thematic Structure: I have organized the work into 20 thematic chapters of exactly 50 hadiths each, preceded by the Intention Prologue (1001 Hadiths total).
3. Complete Diacritics: I have fully vocalized every Arabic text for flawless recitation.
4. Canonical Referencing: I have documented exact sources and international numbering via Maktaba Shamela.
5. Practical Takeaways: I have derived actionable benefits after each narration.
6. Faithful English Translations for worldwide accessibility.''',
              ),
            ),

            const SizedBox(height: 12),

            _buildBookSectionTile(
              context: context,
              icon: Icons.verified_outlined,
              titleArabic: 'خَاتِمَةُ الْكِتَابِ وَوَصِيَّتِي',
              titleEnglish: 'Author\'s Epilogue & Testament (Al-Khatimah)',
              description: 'Completed: 10 Muharram 1448 AH (25/06/2026)',
              isDark: isDark,
              onTap: () => _showTextModal(
                context,
                title: 'الخَاتِمَةُ — Author\'s Testament',
                arabicContent: '''الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ. أَحْمَدُ اللَّهَ تَعَالَى عَلَى أَنْ وَفَّقَنِي لِإِتْمَامِ هَذَا السِّفْرِ الْمُبَارَكِ «أَلْفُ حَدِيثٍ وَحَدِيثٌ».

وَقَدْ تَمَّ الْفَرَاغُ مِنْ جَمْعِهِ وَتَحْرِيرِهِ كَامِلًا بِفَضْلِ اللَّهِ فِي: يَوْمِ الْخَمِيسِ 10 مُحَرَّمٍ 1448 هـ — يَوْمِ عَاشُورَاءَ (25/06/2026م).

وَصِيَّتِي لَكَ أَخِي الْقَارِئَ وَطَالِبَ الْعِلْمِ:
1. إِخْلَاصُ النِّيَّةِ لِلَّهِ تَعَالَى فِي طَلَبِ الْعِلْمِ.
2. الْعَمَلُ بِمَا تَعَلَّمْتَ مِنْ سُنَّةِ نَبِيِّكَ ﷺ.
3. تَعْلِيمُهُ لِأَهْلِ بَيْتِكَ وَأَبْنَائِكَ وَجَعْلُهُ مَنْهَجَ تَرْبِيَةٍ.
4. الثَّبَاتُ عَلَى هَدْيِ السُّنَّةِ عِنْدَ الْفِتَنِ.

اللَّهُمَّ اجْعَلْ عَمَلِي هَذَا خَالِصًا لِوَجْهِكَ الْكَرِيمِ، وَاغْفِرْ لِي وَلِوَالِدَيَّ وَلِمَشَايِخِي وَلِكُلِّ مَنْ قَرَأَهُ أَوْ عَمِلَ بِهِ. وَآخِرُ دَعْوَايَ أَنِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ.''',
                englishContent: '''"All praise belongs to Allah, by Whose grace all good deeds reach fruition. I praise and thank my Lord for granting me the strength to complete «1001 Authentic Hadith» on Thursday, 10 Muharram 1448 AH / Day of 'Ashura (25 June 2026 / 25/06/2026), begun on Tuesday, 2 Ramadan 1445 AH (12/03/2024)."

My Personal Advice to You, Dear Reader:
1. Pure Sincerity (Ikhlas): Seek this knowledge purely for Allah's Pleasure.
2. Action: Strive to implement every authentic sunnah you learn.
3. Family Circles: Teach these traditions to your children and household.
4. Steadfastness: Hold fast to the Sunnah in all circumstances.

O Allah, make this work purely for Your Noble Countenance, forgive me, my parents, my teachers, and every reader who learns and practices this light. Amin.''',
              ),
            ),

            const SizedBox(height: 24),

            // Metadata info
            Text(
              '1001 Authentic Hadith • 1st Complete Edition\nVerified via Maktaba Shamela',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildBookSectionTile({
    required BuildContext context,
    required IconData icon,
    required String titleArabic,
    required String titleEnglish,
    required String description,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162238) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF14B8A6)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        titleEnglish,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titleArabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: Color(0xFF14B8A6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  static void _showTextModal(
    BuildContext context, {
    required String title,
    required String arabicContent,
    required String englishContent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              // Arabic Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162238) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF0D9488).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  arabicContent,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 17,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // English Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162238) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  englishContent,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
