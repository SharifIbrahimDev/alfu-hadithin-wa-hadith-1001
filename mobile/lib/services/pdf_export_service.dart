import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/chapter.dart';
import '../models/hadith.dart';
import 'hadith_service.dart';

class PdfExportService {
  /// Generate the Complete 1,001 Hadith Compendium as a high-quality PDF document.
  static Future<Uint8List> buildCompleteBookPdf({
    required HadithService service,
    void Function(double progress, String status)? onProgress,
  }) async {
    final pdf = pw.Document(
      title: '1001 Authentic Hadith: The Definitive Thematic Compendium',
      author: 'Ibrahim Sharif Abubakar (إبراهيم شريف أبوبكر)',
      subject: 'Authentic Prophetic Traditions (ألف حديث وحديث في صحيح سنن خير البرية ﷺ)',
      keywords: 'Hadith, Sunnah, Bukhari, Muslim, Islam, Fawaid, Authentic',
    );

    onProgress?.call(0.05, 'Loading Arabic & English Typography...');

    // Load custom fonts for Arabic and English rendering
    final arabicFont = await PdfGoogleFonts.amiriRegular();
    final arabicBoldFont = await PdfGoogleFonts.amiriBold();
    final englishFont = await PdfGoogleFonts.plusJakartaSansRegular();
    final englishBoldFont = await PdfGoogleFonts.plusJakartaSansBold();
    final englishItalicFont = await PdfGoogleFonts.plusJakartaSansItalic();

    final theme = pw.ThemeData.withFont(
      base: englishFont,
      bold: englishBoldFont,
      italic: englishItalicFont,
    );

    const primaryColor = PdfColor.fromInt(0xFF0D9488); // Teal
    const secondaryColor = PdfColor.fromInt(0xFF0F172A); // Slate dark
    const goldColor = PdfColor.fromInt(0xFFD97706); // Amber gold
    const lightBgColor = PdfColor.fromInt(0xFFF8FAFC); // Light grey slate

    // ==========================================
    // 1. TITLE & COVER PAGE
    // ==========================================
    onProgress?.call(0.1, 'Generating Cover & Front Matter...');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: goldColor, width: 3),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                    font: arabicBoldFont,
                    fontSize: 22,
                    color: goldColor,
                  ),
                ),
                pw.SizedBox(height: 28),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    '«أَلْفُ حَدِيثٍ وَحَدِيثٌ فِي صَحِيحِ سُنَنِ خَيْرِ الْبَرِيَّةِ ﷺ»',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      font: arabicBoldFont,
                      fontSize: 24,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  '1001 AUTHENTIC HADITH',
                  style: pw.TextStyle(
                    font: englishBoldFont,
                    fontSize: 22,
                    color: secondaryColor,
                    letterSpacing: 2.0,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'The Definitive Thematic Compendium of Strictly Authentic Prophetic Traditions',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: englishFont,
                    fontSize: 13,
                    color: PdfColor.fromInt(0xFF475569),
                  ),
                ),
                pw.SizedBox(height: 36),
                pw.Divider(color: goldColor, thickness: 1.5, indent: 40, endIndent: 40),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Author & Compiler (المؤلف والجامع والمحقق):',
                  style: pw.TextStyle(font: englishFont, fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Ibrahim Sharif Abubakar',
                  style: pw.TextStyle(
                    font: englishBoldFont,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  'إِبْرَاهِيم شَرِيف أَبُوبَكْر',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                    font: arabicBoldFont,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 36),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: lightBgColor,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '100% Authentic Traditions from Canonical Sunnah Authorities',
                        style: pw.TextStyle(font: englishBoldFont, fontSize: 10, color: secondaryColor),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Sahih al-Bukhari • Sahih Muslim • Sunan Abi Dawud • Jami\' at-Tirmidhi • Sunan an-Nasa\'i • Sunan Ibn Majah • Muwatta Malik • Musnad Ahmad',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: englishFont, fontSize: 8.5, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  '1st Scholarly Edition • Verified with Full Tashkeel, Takhrij & Dual-Language Lessons',
                  style: pw.TextStyle(font: englishItalicFont, fontSize: 9, color: PdfColors.grey500),
                ),
              ],
            ),
          );
        },
      ),
    );

    // ==========================================
    // 2. PREFACE & METHODOLOGY
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Author\'s Preface & Scholarly Methodology', 'مُقَدِّمَةُ الْمُؤَلِّفِ وَمَنْهَجُ التَّحْقِيقِ', arabicBoldFont, englishBoldFont, primaryColor),
              pw.SizedBox(height: 14),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: lightBgColor, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'خُطْبَةُ الْحَاجَةِ:',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: arabicBoldFont, fontSize: 13, color: primaryColor),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'إِنَّ الْحَمْدَ لِلَّهِ، نَحْمَدُهُ وَنَسْتَعِينُهُ وَنَسْتَغْفِرُهُ، وَنَعُوذُ بِاللَّهِ مِنْ شُرُورِ أَنْفُسِنَا وَمِنْ سَيِّئَاتِ أَعْمَالِنَا، مَنْ يَهْدِهِ اللَّهُ فَلَا مُضِلَّ لَهُ، وَمَنْ يُضْلِلْ فَلَا هَادِيَ لَهُ. وَأَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ ﷺ.',
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(font: arabicFont, fontSize: 11, lineSpacing: 4),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                'Methodological Principles of this Compendium:',
                style: pw.TextStyle(font: englishBoldFont, fontSize: 12, color: secondaryColor),
              ),
              pw.SizedBox(height: 8),
              _buildBulletPoint('1. Strict Authenticity:', 'Exclusively restricted to Sahih (sound) and established Hasan (good) narrations from authoritative canonical hadith collections.', englishFont, englishBoldFont),
              _buildBulletPoint('2. Thematic Arrangement:', '20 thematic chapters of exactly 50 hadiths each, inaugurated by the Intention Prologue, completing precisely 1001 Hadiths.', englishFont, englishBoldFont),
              _buildBulletPoint('3. Complete Vocalization (Tashkeel):', 'Full diacritics on all Arabic texts to facilitate exact reading and memorization.', englishFont, englishBoldFont),
              _buildBulletPoint('4. Canonical Referencing (Takhrij):', 'Standard numbering and referencing to classical works via Maktaba Shamela.', englishFont, englishBoldFont),
              _buildBulletPoint('5. Fawaidul Hadith (الفوائد والعبر):', 'Comprehensive spiritual, theological, and practical lessons extracted from classical Ahlus Sunnah commentaries.', englishFont, englishBoldFont),
            ],
          );
        },
      ),
    );

    // ==========================================
    // 3. TABLE OF CONTENTS
    // ==========================================
    onProgress?.call(0.15, 'Generating Table of Contents...');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (context) {
          final chapters = service.allChapters;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Table of Contents', 'فِهْرِسُ أَبْوَابِ الْكِتَابِ', arabicBoldFont, englishBoldFont, primaryColor),
              pw.SizedBox(height: 12),
              pw.Expanded(
                child: pw.ListView.builder(
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final ch = chapters[index];
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      margin: const pw.EdgeInsets.only(bottom: 4),
                      decoration: pw.BoxDecoration(
                        color: index % 2 == 0 ? lightBgColor : PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 28,
                            height: 20,
                            alignment: pw.Alignment.center,
                            decoration: pw.BoxDecoration(color: primaryColor, borderRadius: pw.BorderRadius.circular(4)),
                            child: pw.Text('${ch.id}', style: pw.TextStyle(font: englishBoldFont, fontSize: 9, color: PdfColors.white)),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Text(
                              ch.englishTitle,
                              style: pw.TextStyle(font: englishBoldFont, fontSize: 9.5, color: secondaryColor),
                            ),
                          ),
                          pw.Text(
                            ch.arabicTitle,
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(font: arabicFont, fontSize: 9.5, color: primaryColor),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Text(
                            '#${ch.startId.toString().padLeft(4, '0')}–#${ch.endId.toString().padLeft(4, '0')}',
                            style: pw.TextStyle(font: englishFont, fontSize: 8.5, color: goldColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    // ==========================================
    // 4. THEMATIC CHAPTERS & ALL 1,001 HADITHS
    // ==========================================
    final allChapters = service.allChapters;
    final totalChapters = allChapters.length;

    for (int chIndex = 0; chIndex < totalChapters; chIndex++) {
      final ch = allChapters[chIndex];
      final chapterHadiths = service.getHadithsByChapter(ch.id);

      final progressVal = 0.2 + (0.75 * (chIndex / totalChapters));
      onProgress?.call(progressVal, 'Compiling Chapter ${ch.id}: ${ch.englishTitle} (${chapterHadiths.length} Hadiths)...');

      // Use MultiPage for continuous flow of Hadiths inside the chapter
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          header: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 6),
              margin: const pw.EdgeInsets.only(bottom: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '1001 Authentic Hadith • Chapter ${ch.id}',
                    style: pw.TextStyle(font: englishFont, fontSize: 8, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    ch.arabicTitle,
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(font: arabicFont, fontSize: 8.5, color: primaryColor),
                  ),
                ],
              ),
            );
          },
          footer: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(top: 6),
              margin: const pw.EdgeInsets.only(top: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Alfu Hadithin Wa Hadith • Ibrahim Sharif Abubakar',
                    style: pw.TextStyle(font: englishFont, fontSize: 7.5, color: PdfColors.grey500),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(font: englishBoldFont, fontSize: 7.5, color: primaryColor),
                  ),
                ],
              ),
            );
          },
          build: (context) {
            final widgets = <pw.Widget>[];

            // Chapter Header Banner
            widgets.add(
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                margin: const pw.EdgeInsets.only(bottom: 16),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      ch.arabicTitle,
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: arabicBoldFont, fontSize: 16, color: PdfColors.white),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      ch.englishTitle.toUpperCase(),
                      style: pw.TextStyle(font: englishBoldFont, fontSize: 11, color: goldColor, letterSpacing: 1.0),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Hadiths #${ch.startId.toString().padLeft(4, '0')} to #${ch.endId.toString().padLeft(4, '0')} (${chapterHadiths.length} Authentic Narrations)',
                      style: pw.TextStyle(font: englishFont, fontSize: 8.5, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
            );

            // Render each Hadith in the chapter
            for (var h in chapterHadiths) {
              widgets.add(_buildHadithPdfCard(h, arabicFont, arabicBoldFont, englishFont, englishBoldFont, englishItalicFont, primaryColor, secondaryColor, goldColor, lightBgColor));
              widgets.add(pw.SizedBox(height: 14));
            }

            return widgets;
          },
        ),
      );
    }

    onProgress?.call(0.98, 'Finalizing and Rendering PDF Document...');
    final pdfBytes = await pdf.save();
    onProgress?.call(1.0, 'Complete!');
    return pdfBytes;
  }

  /// Generate a Single Chapter as a PDF document.
  static Future<Uint8List> buildChapterPdf({
    required Chapter chapter,
    required List<Hadith> hadiths,
  }) async {
    final pdf = pw.Document(
      title: 'Chapter ${chapter.id}: ${chapter.englishTitle}',
      author: 'Ibrahim Sharif Abubakar',
    );

    final arabicFont = await PdfGoogleFonts.amiriRegular();
    final arabicBoldFont = await PdfGoogleFonts.amiriBold();
    final englishFont = await PdfGoogleFonts.plusJakartaSansRegular();
    final englishBoldFont = await PdfGoogleFonts.plusJakartaSansBold();
    final englishItalicFont = await PdfGoogleFonts.plusJakartaSansItalic();

    final theme = pw.ThemeData.withFont(
      base: englishFont,
      bold: englishBoldFont,
      italic: englishItalicFont,
    );

    const primaryColor = PdfColor.fromInt(0xFF0D9488);
    const secondaryColor = PdfColor.fromInt(0xFF0F172A);
    const goldColor = PdfColor.fromInt(0xFFD97706);
    const lightBgColor = PdfColor.fromInt(0xFFF8FAFC);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 6),
          margin: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Chapter ${chapter.id}: ${chapter.englishTitle}', style: pw.TextStyle(font: englishFont, fontSize: 8, color: PdfColors.grey600)),
              pw.Text(chapter.arabicTitle, textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicFont, fontSize: 8.5, color: primaryColor)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 6),
          margin: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('1001 Authentic Hadith • Ibrahim Sharif Abubakar', style: pw.TextStyle(font: englishFont, fontSize: 7.5, color: PdfColors.grey500)),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: englishBoldFont, fontSize: 7.5, color: primaryColor)),
            ],
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          widgets.add(
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              margin: const pw.EdgeInsets.only(bottom: 16),
              decoration: pw.BoxDecoration(color: primaryColor, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(chapter.arabicTitle, textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicBoldFont, fontSize: 16, color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text(chapter.englishTitle.toUpperCase(), style: pw.TextStyle(font: englishBoldFont, fontSize: 11, color: goldColor, letterSpacing: 1.0)),
                  pw.SizedBox(height: 2),
                  pw.Text('Hadiths #${chapter.startId.toString().padLeft(4, '0')} to #${chapter.endId.toString().padLeft(4, '0')} (${hadiths.length} Authentic Hadiths)', style: pw.TextStyle(font: englishFont, fontSize: 8.5, color: PdfColors.white)),
                ],
              ),
            ),
          );

          for (var h in hadiths) {
            widgets.add(_buildHadithPdfCard(h, arabicFont, arabicBoldFont, englishFont, englishBoldFont, englishItalicFont, primaryColor, secondaryColor, goldColor, lightBgColor));
            widgets.add(pw.SizedBox(height: 14));
          }

          return widgets;
        },
      ),
    );

    return await pdf.save();
  }

  /// Save PDF file to Downloads/App storage and prompt share/open
  static Future<File> savePdfToDevice(Uint8List bytes, String filename) async {
    Directory? outputDir;
    try {
      if (Platform.isAndroid) {
        outputDir = Directory('/storage/emulated/0/Download');
        if (!outputDir.existsSync()) {
          outputDir = await getExternalStorageDirectory();
        }
      } else {
        outputDir = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      outputDir = await getApplicationDocumentsDirectory();
    }

    final filePath = '${outputDir?.path ?? ''}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Share PDF file via Share Sheet
  static Future<void> sharePdf(Uint8List bytes, String filename, {String subject = '1001 Authentic Hadith Compendium'}) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  /// Helper: Build a formatted Hadith card in PDF
  static pw.Widget _buildHadithPdfCard(
    Hadith h,
    pw.Font arabicFont,
    pw.Font arabicBoldFont,
    pw.Font englishFont,
    pw.Font englishBoldFont,
    pw.Font englishItalicFont,
    PdfColor primaryColor,
    PdfColor secondaryColor,
    PdfColor goldColor,
    PdfColor lightBgColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header Bar: Hadith Number + Topic
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'Hadith #${h.id.toString().padLeft(4, '0')}',
                  style: pw.TextStyle(font: englishBoldFont, fontSize: 8.5, color: PdfColors.white),
                ),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                  child: pw.Text(
                    h.topicEn.isNotEmpty ? h.topicEn.toUpperCase() : '',
                    maxLines: 1,
                    style: pw.TextStyle(font: englishBoldFont, fontSize: 8.5, color: primaryColor),
                  ),
                ),
              ),
              pw.Text(
                'الحديث رقم: ${h.id}',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: goldColor),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Arabic Matn (with Tashkeel)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: lightBgColor,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  h.arabicMatn,
                  textDirection: pw.TextDirection.rtl,
                  textAlign: pw.TextAlign.justify,
                  style: pw.TextStyle(
                    font: arabicBoldFont,
                    fontSize: 12.5,
                    lineSpacing: 5.5,
                    color: secondaryColor,
                  ),
                ),
                if (h.narratorAr.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'الراوي: ${h.narratorAr}',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(font: arabicFont, fontSize: 8.5, color: PdfColors.grey700),
                  ),
                ],
                if (h.benefitsAr.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                  pw.Text(
                    'الفوائد والعبر:\n${h.benefitsAr}',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(font: arabicFont, fontSize: 9.5, lineSpacing: 3, color: primaryColor),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 8),

          // English Translation
          pw.Text(
            '"${h.englishTranslation}"',
            style: pw.TextStyle(
              font: englishItalicFont,
              fontSize: 9.5,
              lineSpacing: 2.5,
              color: secondaryColor,
            ),
          ),
          pw.SizedBox(height: 6),

          // Metadata Row: Reference, Grading, Narrator & Lessons
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: pw.BoxDecoration(
              color: lightBgColor,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text('Reference: ', style: pw.TextStyle(font: englishBoldFont, fontSize: 7.5, color: PdfColors.grey700)),
                    pw.Expanded(
                      child: pw.Text(h.takhrij, style: pw.TextStyle(font: englishFont, fontSize: 7.5, color: secondaryColor)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: pw.BoxDecoration(color: goldColor, borderRadius: pw.BorderRadius.circular(3)),
                      child: pw.Text(h.grading, style: pw.TextStyle(font: englishBoldFont, fontSize: 7, color: PdfColors.white)),
                    ),
                  ],
                ),
                if (h.benefitsEn.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Lessons: ', style: pw.TextStyle(font: englishBoldFont, fontSize: 7.5, color: primaryColor)),
                      pw.Expanded(
                        child: pw.Text(h.benefitsEn, style: pw.TextStyle(font: englishFont, fontSize: 7.5, color: secondaryColor)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String titleEn, String titleAr, pw.Font arBold, pw.Font enBold, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(titleEn, style: pw.TextStyle(font: enBold, fontSize: 15, color: color)),
            pw.Text(titleAr, textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arBold, fontSize: 14, color: color)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: color, thickness: 1.2),
      ],
    );
  }

  static pw.Widget _buildBulletPoint(String title, String description, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColor.fromInt(0xFF0D9488))),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: '$title ', style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: PdfColor.fromInt(0xFF0F172A))),
                  pw.TextSpan(text: description, style: pw.TextStyle(font: font, fontSize: 9.5, color: PdfColor.fromInt(0xFF475569))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
