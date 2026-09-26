import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../models/chapter.dart';
import '../models/hadith.dart';
import '../providers/app_provider.dart';
import '../widgets/share_card_dialog.dart';
import 'pdf_viewer_screen.dart';

enum BookSection {
  frontMatter,
  muqaddimah,
  tamheed,
  compendium,
  khatimah,
}

class BookReaderScreen extends StatefulWidget {
  final int initialHadithId;
  final int? initialChapterId;

  const BookReaderScreen({
    Key? key,
    this.initialHadithId = 1,
    this.initialChapterId,
  }) : super(key: key);

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late ScrollController _scrollController;
  int _selectedChapterId = 0;
  BookSection _currentSection = BookSection.compendium;
  final TextEditingController _jumpController = TextEditingController();

  late FlutterTts _flutterTts;
  int? _playingHadithId;
  bool _isPlaying = false;

  // Typography settings overrides (local to reader or linked with provider)
  double _arabicFontSize = 22.0;
  double _englishFontSize = 15.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.initialChapterId != null) {
      _selectedChapterId = widget.initialChapterId!;
    }

    _flutterTts = FlutterTts();
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _playingHadithId = null;
          _isPlaying = false;
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _playingHadithId = null;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _jumpController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleAudio(Hadith hadith, AppProvider provider) async {
    if (_isPlaying && _playingHadithId == hadith.id) {
      await _flutterTts.stop();
      setState(() {
        _playingHadithId = null;
        _isPlaying = false;
      });
      return;
    }

    await _flutterTts.stop();
    setState(() {
      _playingHadithId = hadith.id;
      _isPlaying = true;
    });

    try {
      if (provider.ttsMode == TtsPlaybackMode.englishOnly) {
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.setSpeechRate(provider.englishSpeechRate);
        await _flutterTts.speak(hadith.englishTranslation);
      } else {
        await _flutterTts.setLanguage('ar');
        await _flutterTts.setSpeechRate(provider.arabicSpeechRate);
        await _flutterTts.speak(hadith.arabicMatn);
      }
    } catch (e) {
      debugPrint('TTS error: $e');
      if (mounted) {
        setState(() {
          _playingHadithId = null;
          _isPlaying = false;
        });
      }
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showChapterSelectSheet(List<Chapter> chapters, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
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
              const SizedBox(height: 12),
              const Text(
                'Table of Contents (فِهْرِسُ الْكِتَابِ)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Front matter quick jumps
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSectionChip('Title & Cover', BookSection.frontMatter),
                    const SizedBox(width: 8),
                    _buildSectionChip('Muqaddimah', BookSection.muqaddimah),
                    const SizedBox(width: 8),
                    _buildSectionChip('Tamheed', BookSection.tamheed),
                    const SizedBox(width: 8),
                    _buildSectionChip('Khatimah', BookSection.khatimah),
                  ],
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final ch = chapters[index];
                    final isSelected = _currentSection == BookSection.compendium && _selectedChapterId == ch.id;

                    return ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      tileColor: isSelected ? const Color(0xFF0D9488).withOpacity(0.15) : null,
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0D9488) : (isDark ? const Color(0xFF162238) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${ch.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                          ),
                        ),
                      ),
                      title: Text(
                        ch.englishTitle,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                          color: isSelected ? const Color(0xFF14B8A6) : null,
                        ),
                      ),
                      subtitle: Text(
                        ch.arabicTitle,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontFamily: 'Amiri', fontSize: 13, color: Color(0xFFF59E0B)),
                      ),
                      trailing: Text(
                        '#${ch.startId.toString().padLeft(4, '0')}–#${ch.endId.toString().padLeft(4, '0')}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      onTap: () {
                        setState(() {
                          _currentSection = BookSection.compendium;
                          _selectedChapterId = ch.id;
                        });
                        Navigator.pop(ctx);
                        _scrollToTop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionChip(String title, BookSection section) {
    final isSelected = _currentSection == section;
    return ChoiceChip(
      label: Text(title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: const Color(0xFF0D9488),
      labelStyle: TextStyle(color: isSelected ? Colors.white : null),
      onSelected: (val) {
        if (val) {
          setState(() {
            _currentSection = section;
          });
          Navigator.pop(context);
          _scrollToTop();
        }
      },
    );
  }

  void _showJumpToHadithDialog(AppProvider provider) {
    _jumpController.text = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.search_rounded, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text('Jump to Hadith #'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a Hadith number between 1 and 1001:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jumpController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'e.g. 100',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(_jumpController.text.trim());
              if (val != null && val >= 1 && val <= 1001) {
                final hadith = provider.service.getHadithById(val);
                if (hadith != null) {
                  setState(() {
                    _currentSection = BookSection.compendium;
                    _selectedChapterId = hadith.chapterId;
                  });
                  Navigator.pop(ctx);
                  _scrollToTop();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid Hadith number (1 to 1001)'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Jump'),
          ),
        ],
      ),
    );
  }

  void _showTypographySheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Reading Typography Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Arabic Font Size:'),
                  Text('${_arabicFontSize.toInt()} pt', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6))),
                ],
              ),
              Slider(
                value: _arabicFontSize,
                min: 16.0,
                max: 36.0,
                divisions: 10,
                activeColor: const Color(0xFF0D9488),
                onChanged: (val) {
                  setModalState(() => _arabicFontSize = val);
                  setState(() => _arabicFontSize = val);
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('English Font Size:'),
                  Text('${_englishFontSize.toInt()} pt', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6))),
                ],
              ),
              Slider(
                value: _englishFontSize,
                min: 12.0,
                max: 24.0,
                divisions: 6,
                activeColor: const Color(0xFF0D9488),
                onChanged: (val) {
                  setModalState(() => _englishFontSize = val);
                  setState(() => _englishFontSize = val);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chapters = provider.service.allChapters;

    final currentChapter = chapters.firstWhere(
      (c) => c.id == _selectedChapterId,
      orElse: () => chapters.isNotEmpty ? chapters.first : Chapter(id: 0, englishTitle: 'Prologue', arabicTitle: 'المقدمة', hadithCount: 1, startId: 1, endId: 1, description: ''),
    );

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _showChapterSelectSheet(chapters, isDark),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSection == BookSection.compendium
                          ? 'Chapter ${currentChapter.id}: ${currentChapter.englishTitle}'
                          : _getSectionTitleEn(_currentSection),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _currentSection == BookSection.compendium
                          ? currentChapter.arabicTitle
                          : _getSectionTitleAr(_currentSection),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 12, color: Color(0xFFF59E0B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF14B8A6)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Adjust Typography',
            onPressed: () => _showTypographySheet(isDark),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Jump to Hadith #',
            onPressed: () => _showJumpToHadithDialog(provider),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFF59E0B)),
            tooltip: 'Export / Download PDF',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfViewerScreen(
                    chapter: _currentSection == BookSection.compendium ? currentChapter : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildContent(context, provider, currentChapter, isDark),
      bottomNavigationBar: _buildBottomBar(context, chapters, isDark),
    );
  }

  String _getSectionTitleEn(BookSection s) {
    switch (s) {
      case BookSection.frontMatter:
        return 'Title & Book Cover';
      case BookSection.muqaddimah:
        return 'Author\'s Preface (Al-Muqaddimah)';
      case BookSection.tamheed:
        return 'Scholarly Methodology (Al-Tamheed)';
      case BookSection.compendium:
        return '1001 Authentic Hadith Compendium';
      case BookSection.khatimah:
        return 'Author\'s Epilogue & Testament (Al-Khatimah)';
    }
  }

  String _getSectionTitleAr(BookSection s) {
    switch (s) {
      case BookSection.frontMatter:
        return '«أَلْفُ حَدِيثٍ وَحَدِيثٌ»';
      case BookSection.muqaddimah:
        return 'مُقَدِّمَةُ الْمُؤَلِّفِ';
      case BookSection.tamheed:
        return 'تَمْهِيدُ الْكِتَابِ وَمَنْهَجِي';
      case BookSection.compendium:
        return 'المتن والأحاديث النبوية';
      case BookSection.khatimah:
        return 'خَاتِمَةُ الْكِتَابِ وَالْوَصِيَّةُ';
    }
  }

  Widget _buildContent(BuildContext context, AppProvider provider, Chapter currentChapter, bool isDark) {
    switch (_currentSection) {
      case BookSection.frontMatter:
        return _buildFrontMatterView(isDark);
      case BookSection.muqaddimah:
        return _buildMuqaddimahView(isDark);
      case BookSection.tamheed:
        return _buildTamheedView(isDark);
      case BookSection.khatimah:
        return _buildKhatimahView(isDark);
      case BookSection.compendium:
        return _buildHadithCompendiumView(context, provider, currentChapter, isDark);
    }
  }

  Widget _buildFrontMatterView(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162238) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5), width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '«أَلْفُ حَدِيثٍ وَحَدِيثٌ فِي صَحِيحِ سُنَنِ خَيْرِ الْبَرِيَّةِ ﷺ»',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '1001 AUTHENTIC HADITH',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The Definitive Thematic Compendium of Strictly Authentic Prophetic Traditions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF59E0B), thickness: 1),
                const SizedBox(height: 16),
                const Text(
                  'AUTHOR, COMPILER & RESEARCHER\nالمؤلف والجامع والمحقق',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ibrahim Sharif Abubakar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF14B8A6)),
                ),
                const Text(
                  'إِبْرَاهِيم شَرِيف أَبُوبَكْر',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF14B8A6)),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentSection = BookSection.compendium;
                      _selectedChapterId = 0;
                    });
                    _scrollToTop();
                  },
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text('Begin Reading Compendium'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuqaddimahView(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderCard(
            titleEn: 'Author\'s Scholarly Preface',
            titleAr: 'مُقَدِّمَةُ الْمُؤَلِّفِ',
            dateInfo: 'Began: 2 Ramadan 1445 AH (12/03/2024)',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162238) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'خُطْبَةُ الْحَاجَةِ:',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF14B8A6)),
                ),
                const SizedBox(height: 8),
                const Text(
                  '''إِنَّ الْحَمْدَ لِلَّهِ، نَحْمَدُهُ وَنَسْتَعِينُهُ وَنَسْتَغْفِرُهُ، وَنَعُوذُ بِاللَّهِ مِنْ شُرُورِ أَنْفُسِنَا وَمِنْ سَيِّئَاتِ أَعْمَالِنَا، مَنْ يَهْدِهِ اللَّهُ فَلَا مُضِلَّ لَهُ، وَمَنْ يُضْلِلْ فَلَا هَادِيَ لَهُ.

وَأَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ ﷺ.

أَمَّا بَعْدُ:
فَإِنَّ كِتَابَ اللَّهِ تَعَالَى وَسُنَّةَ نَبِيِّهِ الْمُصْطَفَى ﷺ هُمَا مَنْبَعُ الْهِدَايَةِ، وَعِصْمَةُ الْمُسْلِمِ فِي أَمْرِ دِينِهِ وَدُنْيَاهُ. وَقَدْ رَأَيْتُ أَنَّ مِنْ أَعْظَمِ مَا أَتَقَرَّبُ بِهِ إِلَى رَبِّي جَلَّ وَعَلَا، وَأَنْفَعُ بِهِ إِخْوَانِي الْمُسْلِمِينَ، أَنْ أَقُومَ بِجَمْعِ هَذَا الْمُصَنَّفِ الْجَامِعِ: «أَلْفُ حَدِيثٍ وَحَدِيثٌ».

وَقَدْ شَرَعْتُ فِي جَمْعِ هَذَا الْكِتَابِ الْمُبَارَكِ وَتَحْرِيرِهِ فِي يَوْمِ الثُّلَاثَاءِ 2 مِنْ رَمَضَانَ 1445 هـ (12/03/2024م)، سَائِلًا الْمَوْلَى أَنْ يَتَقَبَّلَهُ مِنِّي بِقَبُولٍ حَسَنٍ.''',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 17, height: 1.8),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  '''"All praise is due to Allah; I praise Him, seek His aid, and ask His forgiveness. Whomever Allah guides, none can misguide; and whomever He allows to stray, none can guide. I bear witness that there is no deity worthy of worship except Allah alone without partner, and I bear witness that Muhammad ﷺ is His faithful servant and final Messenger."

I commenced the research and compilation of this compendium—«1001 Authentic Hadith (أَلْفُ حَدِيثٍ وَحَدِيثٌ)»—on Tuesday, 2 Ramadan 1445 AH (12 March 2024 / 12/03/2024) to provide every Muslim with an accessible, verified treasury of prophetic wisdom. I pray that Allah accepts this humble effort purely for His sake.''',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTamheedView(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderCard(
            titleEn: 'Scholarly Methodology (Al-Tamheed)',
            titleAr: 'تَمْهِيدُ الْكِتَابِ وَمَنْهَجُ التَّحْقِيقِ',
            dateInfo: 'Authenticity & Arrangement Standards',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162238) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Methodological Foundations:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF14B8A6)),
                ),
                const SizedBox(height: 12),
                _buildMethodologyTile('1. Strict Authenticity Standard', 'Every single Hadith has been verified against canonical Sunnah authorities (Sahih al-Bukhari, Sahih Muslim, Sunan Abi Dawud, Jami\' at-Tirmidhi, Sunan an-Nasa\'i, Sunan Ibn Majah, Muwatta Malik, and Musnad Ahmad). Weak narrations are completely excluded.'),
                _buildMethodologyTile('2. Symmetrical 20-Chapter Structure', 'The book contains exactly 20 thematic chapters of 50 Hadiths each, preceded by Hadith #1 on Sincerity & Intention, totaling precisely 1001 Hadiths.'),
                _buildMethodologyTile('3. Full Diacritics (Tashkeel)', 'All Arabic texts are completely vocalized with precise diacritics to ensure error-free recitation.'),
                _buildMethodologyTile('4. International Takhrij', 'Referenced with exact chapter and Hadith numbering via Maktaba Shamela.'),
                _buildMethodologyTile('5. Fawa\'idul Hadith (الفوائد والعبر)', 'Every narration is accompanied by core spiritual, doctrinal, and practical lessons from Ahlus Sunnah commentaries.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKhatimahView(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderCard(
            titleEn: 'Author\'s Epilogue & Final Testament',
            titleAr: 'خَاتِمَةُ الْكِتَابِ وَالْوَصِيَّةُ',
            dateInfo: 'Completed: 10 Muharram 1448 AH (25/06/2026)',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162238) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '''الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ. أَحْمَدُ اللَّهَ تَعَالَى عَلَى أَنْ وَفَّقَنِي لِإِتْمَامِ هَذَا السِّفْرِ الْمُبَارَكِ «أَلْفُ حَدِيثٍ وَحَدِيثٌ».

وَقَدْ تَمَّ الْفَرَاغُ مِنْ جَمْعِهِ وَتَحْرِيرِهِ كَامِلًا بِفَضْلِ اللَّهِ فِي: يَوْمِ الْخَمِيسِ 10 مُحَرَّمٍ 1448 هـ — يَوْمِ عَاشُورَاءَ (25/06/2026م).

وَصِيَّتِي لَكَ أَخِي الْقَارِئَ وَطَالِبَ الْعِلْمِ:
1. إِخْلَاصُ النِّيَّةِ لِلَّهِ تَعَالَى فِي طَلَبِ الْعِلْمِ.
2. الْعَمَلُ بِمَا تَعَلَّمْتَ مِنْ سُنَّةِ نَبِيِّكَ ﷺ.
3. تَعْلِيمُهُ لِأَهْلِ بَيْتِكَ وَأَبْنَائِكَ وَجَعْلُهُ مَنْهَجَ تَرْبِيَةٍ.
4. الثَّبَاتُ عَلَى هَدْيِ السُّنَّةِ عِنْدَ الْفِتَنِ.

اللَّهُمَّ اجْعَلْ عَمَلِي هَذَا خَالِصًا لِوَجْهِكَ الْكَرِيمِ، وَاغْفِرْ لِي وَلِوَالِدَيَّ وَلِمَشَايِخِي وَلِكُلِّ مَنْ قَرَأَهُ أَوْ عَمِلَ بِهِ. وَآخِرُ دَعْوَايَ أَنِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ.''',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 17, height: 1.8),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  '''"All praise belongs to Allah, by Whose grace all good deeds reach fruition. I praise and thank my Lord for granting me the strength to complete «1001 Authentic Hadith» on Thursday, 10 Muharram 1448 AH / Day of 'Ashura (25 June 2026 / 25/06/2026)."

My Personal Advice to You, Dear Reader:
1. Pure Sincerity (Ikhlas): Seek this knowledge purely for Allah's Pleasure.
2. Action: Strive to implement every authentic sunnah you learn.
3. Family Circles: Teach these traditions to your children and household.
4. Steadfastness: Hold fast to the Sunnah in all circumstances.

O Allah, make this work purely for Your Noble Countenance, forgive me, my parents, my teachers, and every reader who learns and practices this light. Amin.''',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCompendiumView(
    BuildContext context,
    AppProvider provider,
    Chapter currentChapter,
    bool isDark,
  ) {
    final hadiths = provider.service.getHadithsForChapter(currentChapter.id);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Chapter Banner Header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  currentChapter.arabicTitle,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentChapter.englishTitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hadiths #${currentChapter.startId.toString().padLeft(4, '0')} to #${currentChapter.endId.toString().padLeft(4, '0')} (${hadiths.length} Authentic Hadiths)',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),

        // List of Hadiths in Chapter
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final h = hadiths[index];
              final isBookmarked = provider.isBookmarked(h.id);
              final isRead = provider.isRead(h.id);

              return _buildHadithReaderCard(
                context: context,
                hadith: h,
                provider: provider,
                isBookmarked: isBookmarked,
                isRead: isRead,
                isDark: isDark,
              );
            },
            childCount: hadiths.length,
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  Widget _buildHadithReaderCard({
    required BuildContext context,
    required Hadith hadith,
    required AppProvider provider,
    required bool isBookmarked,
    required bool isRead,
    required bool isDark,
  }) {
    final isCurrentPlaying = _isPlaying && _playingHadithId == hadith.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162238) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlaying
              ? const Color(0xFF14B8A6)
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
          width: isCurrentPlaying ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Hadith Number, Topic, Audio & Bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hadith.idStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    hadith.topicEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF14B8A6),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isCurrentPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                      color: isCurrentPlaying ? const Color(0xFFF59E0B) : const Color(0xFF14B8A6),
                      size: 22,
                    ),
                    tooltip: isCurrentPlaying ? 'Stop Audio' : 'Recite Hadith',
                    onPressed: () => _toggleAudio(hadith, provider),
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isBookmarked ? const Color(0xFFF59E0B) : Colors.grey,
                      size: 22,
                    ),
                    tooltip: 'Bookmark Hadith',
                    onPressed: () => provider.toggleBookmark(hadith.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Arabic Matn Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0D9488).withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hadith.arabicMatn,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: _arabicFontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (hadith.narratorAr.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'الراوي: ${hadith.narratorAr}',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: _arabicFontSize * 0.7,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // English Translation
          Text(
            '"${hadith.englishTranslation}"',
            style: TextStyle(
              fontSize: _englishFontSize,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey[200] : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          // Takhrij and Grading Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '📖 ${hadith.takhrij}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    hadith.grading,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fawa'idul Hadith / Lessons Card (Dual Language)
          if (hadith.benefitsAr.isNotEmpty || hadith.benefitsEn.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132238) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF10B981)),
                      SizedBox(width: 6),
                      Text(
                        'Key Lessons & Benefits (الفوائد والعبر)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  if (hadith.benefitsAr.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hadith.benefitsAr,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 13, height: 1.5, color: Color(0xFF0D9488)),
                    ),
                  ],
                  if (hadith.benefitsEn.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hadith.benefitsEn,
                      style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          // Action Buttons: Share, Mark Read
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => ShareCardDialog.show(context, hadith),
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('Share Card', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => provider.toggleRead(hadith.id),
                icon: Icon(
                  isRead ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  size: 16,
                  color: isRead ? const Color(0xFF10B981) : Colors.grey,
                ),
                label: Text(
                  isRead ? 'Read' : 'Mark as Read',
                  style: TextStyle(
                    fontSize: 12,
                    color: isRead ? const Color(0xFF10B981) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderCard({
    required String titleEn,
    required String titleAr,
    required String dateInfo,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162238) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF14B8A6))),
              Text(titleAr, textDirection: TextDirection.rtl, style: const TextStyle(fontFamily: 'Amiri', fontSize: 16, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(dateInfo, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildMethodologyTile(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: Color(0xFF14B8A6), fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.grey),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6))),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<Chapter> chapters, bool isDark) {
    final currentIndex = chapters.indexWhere((c) => c.id == _selectedChapterId);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < chapters.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111B2D) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: hasPrev
                  ? () {
                      setState(() {
                        _currentSection = BookSection.compendium;
                        _selectedChapterId = chapters[currentIndex - 1].id;
                      });
                      _scrollToTop();
                    }
                  : null,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Previous Chapter', style: TextStyle(fontSize: 12)),
            ),
            IconButton(
              icon: const Icon(Icons.toc_rounded, color: Color(0xFF14B8A6)),
              tooltip: 'Contents Sheet',
              onPressed: () => _showChapterSelectSheet(chapters, isDark),
            ),
            TextButton.icon(
              onPressed: hasNext
                  ? () {
                      setState(() {
                        _currentSection = BookSection.compendium;
                        _selectedChapterId = chapters[currentIndex + 1].id;
                      });
                      _scrollToTop();
                    }
                  : null,
              icon: const Text('Next Chapter', style: TextStyle(fontSize: 12)),
              label: const Icon(Icons.arrow_forward_rounded, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
