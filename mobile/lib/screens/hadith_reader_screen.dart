import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/hadith.dart';
import '../providers/app_provider.dart';

class HadithReaderScreen extends StatefulWidget {
  final int initialHadithId;

  const HadithReaderScreen({Key? key, required this.initialHadithId}) : super(key: key);

  @override
  State<HadithReaderScreen> createState() => _HadithReaderScreenState();
}

class _HadithReaderScreenState extends State<HadithReaderScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final all = provider.service.allHadiths;
    _currentIndex = all.indexWhere((h) => h.id == widget.initialHadithId);
    if (_currentIndex == -1) _currentIndex = 0;

    _pageController = PageController(initialPage: _currentIndex);
    _flutterTts = FlutterTts();
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _toggleSpeak(Hadith hadith) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(hadith.englishTranslation);
      setState(() => _isSpeaking = true);
    }
  }

  void _copyHadith(Hadith hadith) {
    final text = '✨ 1001 Authentic Hadith — ${hadith.idStr}\n'
        'Author & Compiler: Ibrahim Sharif Abubakar\n\n'
        '🇸🇦 [الباب: ${hadith.topicAr}]\n'
        '${hadith.arabicMatn}\n'
        'الراوي: ${hadith.narratorAr}\n\n'
        '🇬🇧 [${hadith.topicEn}]\n'
        '"${hadith.englishTranslation}"\n'
        'Companion Narrator: ${hadith.narratorEn}\n'
        'Reference: ${hadith.takhrij}\n'
        'Grading: ${hadith.grading}\n\n'
        '📖 Read more: https://github.com/SharifIbrahimDev/alfu-hadithin-wa-hadith-1001';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hadith copied to clipboard! 📋'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareHadith(Hadith hadith) {
    Share.share(
      '"${hadith.englishTranslation}"\n\n'
      '${hadith.arabicMatn}\n\n'
      '— 1001 Authentic Hadith (${hadith.idStr})\n'
      'Compiled by Ibrahim Sharif Abubakar',
      subject: '1001 Authentic Hadith ${hadith.idStr}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allHadiths = provider.service.allHadiths;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (allHadiths.isEmpty) {
      return const Scaffold(body: Center(child: Text('No hadiths found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          allHadiths[_currentIndex].idStr,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_up : Icons.volume_mute,
              color: _isSpeaking ? const Color(0xFF14B8A6) : null,
            ),
            tooltip: 'Read Aloud (TTS)',
            onPressed: () => _toggleSpeak(allHadiths[_currentIndex]),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Hadith',
            onPressed: () => _copyHadith(allHadiths[_currentIndex]),
          ),
          IconButton(
            icon: Icon(
              provider.isBookmarked(allHadiths[_currentIndex].id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: provider.isBookmarked(allHadiths[_currentIndex].id)
                  ? const Color(0xFFF59E0B)
                  : null,
            ),
            tooltip: 'Bookmark',
            onPressed: () => provider.toggleBookmark(allHadiths[_currentIndex].id),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _shareHadith(allHadiths[_currentIndex]),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: allHadiths.length,
        onPageChanged: (idx) {
          setState(() {
            _currentIndex = idx;
            if (_isSpeaking) {
              _flutterTts.stop();
              _isSpeaking = false;
            }
          });
        },
        itemBuilder: (context, index) {
          final hadith = allHadiths[index];
          return _buildHadithReaderBody(context, hadith, provider, isDark);
        },
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111B2D) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _currentIndex > 0
                  ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      )
                  : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162238),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Text(
              '${_currentIndex + 1} of ${allHadiths.length}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _currentIndex < allHadiths.length - 1
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      )
                  : null,
              label: const Text('Next'),
              icon: const Icon(Icons.chevron_right),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162238),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithReaderBody(
      BuildContext context, Hadith hadith, AppProvider provider, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🇸🇦 ARABIC SECTION (RTL)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162238) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hadith.topicAr.isNotEmpty)
                  Text(
                    '[الباب: ${hadith.topicAr}]',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  hadith.arabicMatn,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: provider.arabicFontSize,
                    fontWeight: FontWeight.w600,
                    height: 2.1,
                  ),
                ),
                const SizedBox(height: 14),
                if (hadith.narratorAr.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'الراوي: ${hadith.narratorAr}',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          color: Color(0xFF14B8A6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (hadith.takhrij.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'التخريج: ${hadith.takhrij}',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
                if (hadith.benefitsAr.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'الفوائد:\n${hadith.benefitsAr}',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                      height: 1.8,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🇬🇧 ENGLISH SECTION (LTR)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111B2D) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hadith.topicEn.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '"${hadith.englishTranslation}"',
                  style: TextStyle(
                    fontSize: provider.englishFontSize,
                    height: 1.65,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A101D) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMetaRow('Narrator', hadith.narratorEn.isNotEmpty ? hadith.narratorEn : hadith.narratorAr, isDark),
                      const SizedBox(height: 6),
                      _buildMetaRow('Reference', hadith.takhrij, isDark),
                      const SizedBox(height: 6),
                      _buildMetaRow('Grading', hadith.grading, isDark, isGrading: true),
                      if (hadith.benefitsEn.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildMetaRow('Lessons', hadith.benefitsEn, isDark),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, bool isDark, {bool isGrading = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isGrading ? FontWeight.bold : FontWeight.normal,
              color: isGrading
                  ? const Color(0xFF10B981)
                  : (isDark ? Colors.grey[300] : Colors.grey[800]),
            ),
          ),
        ),
      ],
    );
  }
}
