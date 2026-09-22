import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/hadith.dart';

enum ShareCardTheme {
  emerald,
  midnight,
  royalGold,
  parchment,
}

enum ShareCardLanguage {
  both,
  arabicOnly,
  englishOnly,
}

class ShareCardDialog extends StatefulWidget {
  final Hadith hadith;

  const ShareCardDialog({Key? key, required this.hadith}) : super(key: key);

  static void show(BuildContext context, Hadith hadith) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => ShareCardDialog(hadith: hadith),
    );
  }

  @override
  State<ShareCardDialog> createState() => _ShareCardDialogState();
}

class _ShareCardDialogState extends State<ShareCardDialog> {
  final GlobalKey _cardKey = GlobalKey();
  ShareCardTheme _selectedTheme = ShareCardTheme.emerald;
  ShareCardLanguage _selectedLanguage = ShareCardLanguage.both;
  bool _isGeneratingImage = false;

  Future<void> _shareImage() async {
    if (_isGeneratingImage) return;

    setState(() => _isGeneratingImage = true);

    try {
      // Find the render object
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not capture widget image');
      }

      // Render image at high resolution (pixelRatio 3.0 for crisp rendering)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to encode image to PNG');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Write to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hadith_${widget.hadith.id.toString().padLeft(4, '0')}.png');
      await file.writeAsBytes(pngBytes);

      final shareText = '✨ 1001 Authentic Hadith — ${widget.hadith.idStr}\n'
          'Author & Compiler: Ibrahim Sharif Abubakar\n'
          '📖 Read more: https://github.com/SharifIbrahimDev/alfu-hadithin-wa-hadith-1001';

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: shareText,
        subject: '1001 Authentic Hadith ${widget.hadith.idStr}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.share_rounded, color: Color(0xFF14B8A6), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Share Hadith Card',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Theme & Language Selectors
            _buildControlBar(isDark),

            const SizedBox(height: 14),

            // Scrollable Preview of the Card
            Flexible(
              child: SingleChildScrollView(
                child: Center(
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _buildShareCard(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingImage ? null : _shareImage,
                    icon: _isGeneratingImage
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.image_outlined, size: 20),
                    label: Text(
                      _isGeneratingImage ? 'Creating Image…' : 'Share as Image',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(bool isDark) {
    return Column(
      children: [
        // Language Selector Row
        Row(
          children: [
            const Text(
              'Content:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            _buildLangChip('Both', ShareCardLanguage.both),
            const SizedBox(width: 6),
            _buildLangChip('Arabic 🇸🇦', ShareCardLanguage.arabicOnly),
            const SizedBox(width: 6),
            _buildLangChip('English 🇬🇧', ShareCardLanguage.englishOnly),
          ],
        ),
        const SizedBox(height: 10),
        // Theme Selector Row
        Row(
          children: [
            const Text(
              'Theme:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            _buildThemeChip('Emerald', ShareCardTheme.emerald, const Color(0xFF064E3B)),
            const SizedBox(width: 6),
            _buildThemeChip('Midnight', ShareCardTheme.midnight, const Color(0xFF0F172A)),
            const SizedBox(width: 6),
            _buildThemeChip('Royal Gold', ShareCardTheme.royalGold, const Color(0xFF18181B)),
            const SizedBox(width: 6),
            _buildThemeChip('Parchment', ShareCardTheme.parchment, const Color(0xFFFEF3C7)),
          ],
        ),
      ],
    );
  }

  Widget _buildLangChip(String label, ShareCardLanguage lang) {
    final selected = _selectedLanguage == lang;
    return InkWell(
      onTap: () => setState(() => _selectedLanguage = lang),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D9488) : const Color(0xFF0D9488).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF0D9488) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : const Color(0xFF0D9488),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip(String label, ShareCardTheme theme, Color bg) {
    final selected = _selectedTheme == theme;
    return InkWell(
      onTap: () => setState(() => _selectedTheme = theme),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFF59E0B) : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme == ShareCardTheme.parchment ? const Color(0xFF291D11) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildShareCard() {
    final hadith = widget.hadith;

    // Theme properties
    late final List<Color> gradientColors;
    late final Color borderColor;
    late final Color accentGold;
    late final Color primaryTextColor;
    late final Color secondaryTextColor;
    late final Color cardBg;

    switch (_selectedTheme) {
      case ShareCardTheme.emerald:
        gradientColors = [const Color(0xFF064E3B), const Color(0xFF022C22)];
        borderColor = const Color(0xFFF59E0B).withOpacity(0.6);
        accentGold = const Color(0xFFF59E0B);
        primaryTextColor = Colors.white;
        secondaryTextColor = const Color(0xFFD1FAE5);
        cardBg = const Color(0xFF064E3B);
        break;
      case ShareCardTheme.midnight:
        gradientColors = [const Color(0xFF0F172A), const Color(0xFF020617)];
        borderColor = const Color(0xFF14B8A6).withOpacity(0.6);
        accentGold = const Color(0xFF14B8A6);
        primaryTextColor = Colors.white;
        secondaryTextColor = const Color(0xFF94A3B8);
        cardBg = const Color(0xFF0F172A);
        break;
      case ShareCardTheme.royalGold:
        gradientColors = [const Color(0xFF18181B), const Color(0xFF09090B)];
        borderColor = const Color(0xFFFBBF24);
        accentGold = const Color(0xFFFBBF24);
        primaryTextColor = const Color(0xFFFAFAFA);
        secondaryTextColor = const Color(0xFFA1A1AA);
        cardBg = const Color(0xFF18181B);
        break;
      case ShareCardTheme.parchment:
        gradientColors = [const Color(0xFFFFFDF5), const Color(0xFFFEF3C7)];
        borderColor = const Color(0xFFB45309);
        accentGold = const Color(0xFF92400E);
        primaryTextColor = const Color(0xFF1C1917);
        secondaryTextColor = const Color(0xFF78350F);
        cardBg = const Color(0xFFFFFDF5);
        break;
    }

    final showArabic = _selectedLanguage == ShareCardLanguage.both || _selectedLanguage == ShareCardLanguage.arabicOnly;
    final showEnglish = _selectedLanguage == ShareCardLanguage.both || _selectedLanguage == ShareCardLanguage.englishOnly;

    return Container(
      width: 440,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── TOP HEADER ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Book Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentGold.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentGold.withOpacity(0.5)),
                ),
                child: Text(
                  '1001 AUTHENTIC HADITH',
                  style: TextStyle(
                    color: accentGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              // Hadith ID Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentGold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  hadith.idStr,
                  style: TextStyle(
                    color: _selectedTheme == ShareCardTheme.parchment ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bismillah Calligraphy
          Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 17,
                color: accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── ARABIC SECTION ──────────────────────────────────────────
          if (showArabic) ...[
            if (hadith.topicAr.isNotEmpty) ...[
              Text(
                '[الباب: ${hadith.topicAr}]',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: accentGold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              hadith.arabicMatn,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
                height: 2.1,
              ),
            ),
            const SizedBox(height: 8),
            if (hadith.narratorAr.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الراوي: ${hadith.narratorAr}',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13,
                    color: accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],

          // ── ORNATE DIVIDER (when showing both) ───────────────────────
          if (showArabic && showEnglish) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Divider(color: accentGold.withOpacity(0.4), thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '❖',
                    style: TextStyle(color: accentGold, fontSize: 14),
                  ),
                ),
                Expanded(child: Divider(color: accentGold.withOpacity(0.4), thickness: 1)),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // ── ENGLISH SECTION ─────────────────────────────────────────
          if (showEnglish) ...[
            if (hadith.topicEn.isNotEmpty) ...[
              Text(
                hadith.topicEn.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accentGold,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              '"${hadith.englishTranslation}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: primaryTextColor,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hadith.narratorEn.isNotEmpty || hadith.narratorAr.isNotEmpty)
                  Text(
                    hadith.narratorEn.isNotEmpty ? hadith.narratorEn : hadith.narratorAr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: secondaryTextColor,
                    ),
                  ),
                if (hadith.takhrij.isNotEmpty) ...[
                  Text(' • ', style: TextStyle(color: accentGold, fontSize: 12)),
                  Flexible(
                    child: Text(
                      hadith.takhrij,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: 14),

          // ── FOOTER BANNER ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentGold.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ibrahim Sharif Abubakar (إِبْرَاهِيم شَرِيف أَبُوبَكْر)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    Text(
                      'Author & Compiler • Maktaba Shamela Verified',
                      style: TextStyle(
                        fontSize: 9,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Text(
                    hadith.grading.isNotEmpty ? hadith.grading : 'صَحِيحٌ',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF34D399),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
