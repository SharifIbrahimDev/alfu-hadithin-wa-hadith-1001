import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/hadith.dart';
import '../providers/app_provider.dart';
import '../widgets/share_card_dialog.dart';

enum TtsPhase { idle, arabic, english }

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
  TtsPhase _ttsPhase = TtsPhase.idle;
  TtsPlaybackMode _currentPlayMode = TtsPlaybackMode.both;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final all = provider.service.allHadiths;
    _currentIndex = all.indexWhere((h) => h.id == widget.initialHadithId);
    if (_currentIndex == -1) _currentIndex = 0;

    _pageController = PageController(initialPage: _currentIndex);
    _flutterTts = FlutterTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (all.isNotEmpty && _currentIndex >= 0 && _currentIndex < all.length) {
        provider.recordReadingPosition(all[_currentIndex].id);
      }
    });

    _flutterTts.setCompletionHandler(() async {
      if (!mounted) return;
      if (_ttsPhase == TtsPhase.arabic && _currentPlayMode == TtsPlaybackMode.both) {
        // Transition from Arabic to English with smooth pause
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted && _ttsPhase == TtsPhase.arabic) {
          final p = Provider.of<AppProvider>(context, listen: false);
          final hadith = p.service.allHadiths[_currentIndex];
          _playEnglish(hadith, p);
        }
      } else {
        if (mounted) {
          setState(() {
            _ttsPhase = TtsPhase.idle;
          });
        }
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _ttsPhase = TtsPhase.idle;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  String _cleanArabic(String text) {
    return text.replaceAll('«', '').replaceAll('»', '').replaceAll('"', '').trim();
  }

  String _cleanEnglish(String text) {
    return text.replaceAll('*', '').replaceAll('"', '').replaceAll('“', '').replaceAll('”', '').trim();
  }

  Future<void> _stopTts() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _ttsPhase = TtsPhase.idle;
      });
    }
  }

  Future<void> _playArabic(Hadith hadith, AppProvider provider, {required bool continueToEnglish}) async {
    await _flutterTts.stop();
    setState(() {
      _ttsPhase = TtsPhase.arabic;
      _currentPlayMode = continueToEnglish ? TtsPlaybackMode.both : TtsPlaybackMode.arabicOnly;
    });

    try {
      await _flutterTts.setLanguage("ar-SA");
      await _flutterTts.setSpeechRate(provider.arabicSpeechRate);
      final text = _cleanArabic(hadith.arabicMatn);
      await _flutterTts.speak(text);
    } catch (_) {
      try {
        await _flutterTts.setLanguage("ar");
        await _flutterTts.setSpeechRate(provider.arabicSpeechRate);
        final text = _cleanArabic(hadith.arabicMatn);
        await _flutterTts.speak(text);
      } catch (_) {
        if (continueToEnglish) {
          _playEnglish(hadith, provider);
        } else {
          _stopTts();
        }
      }
    }
  }

  Future<void> _playEnglish(Hadith hadith, AppProvider provider) async {
    await _flutterTts.stop();
    setState(() {
      _ttsPhase = TtsPhase.english;
      if (_currentPlayMode != TtsPlaybackMode.both) {
        _currentPlayMode = TtsPlaybackMode.englishOnly;
      }
    });

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(provider.englishSpeechRate);
    final text = _cleanEnglish(hadith.englishTranslation);
    await _flutterTts.speak(text);
  }

  void _toggleGlobalSpeak(Hadith hadith, AppProvider provider) {
    if (_ttsPhase != TtsPhase.idle) {
      _stopTts();
    } else {
      switch (provider.ttsMode) {
        case TtsPlaybackMode.both:
          _playArabic(hadith, provider, continueToEnglish: true);
          break;
        case TtsPlaybackMode.arabicOnly:
          _playArabic(hadith, provider, continueToEnglish: false);
          break;
        case TtsPlaybackMode.englishOnly:
          _playEnglish(hadith, provider);
          break;
      }
    }
  }

  void _showTtsOptionsSheet(BuildContext context, Hadith hadith, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF111B2D) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.volume_up, color: Color(0xFF14B8A6), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Audio Recitation (TTS)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildTtsPlayTile(
                  icon: Icons.sync_alt_rounded,
                  title: 'Play Both (Arabic + English)',
                  subtitle: 'Recites Arabic Matn first, then English translation',
                  color: const Color(0xFF0D9488),
                  isPlaying: _ttsPhase != TtsPhase.idle && _currentPlayMode == TtsPlaybackMode.both,
                  onTap: () {
                    Navigator.pop(ctx);
                    _playArabic(hadith, provider, continueToEnglish: true);
                  },
                ),
                const SizedBox(height: 8),
                _buildTtsPlayTile(
                  icon: Icons.translate_rounded,
                  title: 'Recite Arabic Only 🇸🇦',
                  subtitle: 'Vocalizes the original Arabic text with Tashkeel',
                  color: const Color(0xFF10B981),
                  isPlaying: _ttsPhase == TtsPhase.arabic && _currentPlayMode == TtsPlaybackMode.arabicOnly,
                  onTap: () {
                    Navigator.pop(ctx);
                    _playArabic(hadith, provider, continueToEnglish: false);
                  },
                ),
                const SizedBox(height: 8),
                _buildTtsPlayTile(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Read English Only 🇬🇧',
                  subtitle: 'Speaks the verified English translation',
                  color: const Color(0xFFF59E0B),
                  isPlaying: _ttsPhase == TtsPhase.english && _currentPlayMode == TtsPlaybackMode.englishOnly,
                  onTap: () {
                    Navigator.pop(ctx);
                    _playEnglish(hadith, provider);
                  },
                ),
                if (_ttsPhase != TtsPhase.idle) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _stopTts();
                      },
                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
                      label: const Text('Stop Audio Playback', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTtsPlayTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isPlaying,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isPlaying ? color.withOpacity(0.18) : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying ? color : color.withOpacity(0.18),
            width: isPlaying ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(isPlaying ? Icons.stop_rounded : icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isPlaying ? color : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (isPlaying)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Playing',
                  style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
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
    ShareCardDialog.show(context, hadith);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allHadiths = provider.service.allHadiths;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (allHadiths.isEmpty) {
      return const Scaffold(body: Center(child: Text('No hadiths found')));
    }

    final currentHadith = allHadiths[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentHadith.idStr,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
        ),
        actions: [
          // Audio action with options on long press
          IconButton(
            icon: Icon(
              _ttsPhase == TtsPhase.arabic
                  ? Icons.volume_up
                  : _ttsPhase == TtsPhase.english
                      ? Icons.record_voice_over
                      : Icons.volume_up_outlined,
              color: _ttsPhase == TtsPhase.arabic
                  ? const Color(0xFF14B8A6)
                  : _ttsPhase == TtsPhase.english
                      ? const Color(0xFFF59E0B)
                      : null,
            ),
            tooltip: _ttsPhase == TtsPhase.arabic
                ? 'Reciting Arabic... (Tap to stop)'
                : _ttsPhase == TtsPhase.english
                    ? 'Reading English... (Tap to stop)'
                    : 'Read Aloud (TTS)',
            onPressed: () => _toggleGlobalSpeak(currentHadith, provider),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Audio Options',
            onPressed: () => _showTtsOptionsSheet(context, currentHadith, provider),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Hadith',
            onPressed: () => _copyHadith(currentHadith),
          ),
          IconButton(
            icon: Icon(
              provider.isBookmarked(currentHadith.id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: provider.isBookmarked(currentHadith.id)
                  ? const Color(0xFFF59E0B)
                  : null,
            ),
            tooltip: 'Bookmark',
            onPressed: () => provider.toggleBookmark(currentHadith.id),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _shareHadith(currentHadith),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: allHadiths.length,
        onPageChanged: (idx) {
          setState(() {
            _currentIndex = idx;
            if (_ttsPhase != TtsPhase.idle) {
              _flutterTts.stop();
              _ttsPhase = TtsPhase.idle;
            }
          });
          if (idx >= 0 && idx < allHadiths.length) {
            provider.recordReadingPosition(allHadiths[idx].id);
          }
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
    final isArabicPlaying = _ttsPhase == TtsPhase.arabic;
    final isEnglishPlaying = _ttsPhase == TtsPhase.english;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🇸🇦 ARABIC SECTION (RTL)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162238) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isArabicPlaying
                    ? const Color(0xFF14B8A6)
                    : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                width: isArabicPlaying ? 2.0 : 1.0,
              ),
              boxShadow: isArabicPlaying
                  ? [
                      BoxShadow(
                        color: const Color(0xFF14B8A6).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Topic & Arabic Recite Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Arabic Audio Pill Button
                    InkWell(
                      onTap: () {
                        if (isArabicPlaying) {
                          _stopTts();
                        } else {
                          _playArabic(hadith, provider, continueToEnglish: false);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isArabicPlaying
                              ? const Color(0xFF14B8A6)
                              : const Color(0xFF14B8A6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF14B8A6).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isArabicPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                              size: 14,
                              color: isArabicPlaying ? Colors.white : const Color(0xFF14B8A6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isArabicPlaying ? 'إيقاف' : '🇸🇦 استمع',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isArabicPlaying ? Colors.white : const Color(0xFF14B8A6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hadith.topicAr.isNotEmpty)
                      Expanded(
                        child: Text(
                          '[الباب: ${hadith.topicAr}]',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                  ],
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111B2D) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isEnglishPlaying
                    ? const Color(0xFFF59E0B)
                    : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                width: isEnglishPlaying ? 2.0 : 1.0,
              ),
              boxShadow: isEnglishPlaying
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hadith.topicEn.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // English Audio Pill Button
                    InkWell(
                      onTap: () {
                        if (isEnglishPlaying) {
                          _stopTts();
                        } else {
                          _playEnglish(hadith, provider);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEnglishPlaying
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFF59E0B).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isEnglishPlaying ? Icons.stop_rounded : Icons.record_voice_over_rounded,
                              size: 14,
                              color: isEnglishPlaying ? Colors.white : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isEnglishPlaying ? 'Stop' : '🇬🇧 Listen',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isEnglishPlaying ? Colors.white : const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
