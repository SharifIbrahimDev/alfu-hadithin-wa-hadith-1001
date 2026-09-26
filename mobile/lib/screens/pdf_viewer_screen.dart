import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/chapter.dart';
import '../providers/app_provider.dart';
import '../services/pdf_export_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final Chapter? chapter;
  final String? customTitle;

  const PdfViewerScreen({
    Key? key,
    this.chapter,
    this.customTitle,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  double _progress = 0.0;
  String _statusMessage = 'Preparing PDF document...';
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generatePdf();
    });
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isLoading = true;
      _progress = 0.05;
      _statusMessage = 'Initializing fonts and scholarly formatting...';
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      Uint8List bytes;

      if (widget.chapter != null) {
        final hadiths = provider.service.getHadithsForChapter(widget.chapter!.id);
        setState(() {
          _statusMessage = 'Compiling Chapter ${widget.chapter!.id} (${hadiths.length} Hadiths)...';
          _progress = 0.5;
        });
        bytes = await PdfExportService.buildChapterPdf(
          chapter: widget.chapter!,
          hadiths: hadiths,
        );
      } else {
        bytes = await PdfExportService.buildCompleteBookPdf(
          service: provider.service,
          onProgress: (progress, status) {
            if (mounted) {
              setState(() {
                _progress = progress;
                _statusMessage = status;
              });
            }
          },
        );
      }

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('PDF Generation Error: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to generate PDF: ${e.toString()}';
        });
      }
    }
  }

  String get _defaultFilename {
    if (widget.chapter != null) {
      final cleanTitle = widget.chapter!.englishTitle.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      return '1001_Hadith_Chapter_${widget.chapter!.id}_$cleanTitle.pdf';
    }
    return '1001_Authentic_Hadith_Complete_Compendium.pdf';
  }

  Future<void> _downloadAndSavePdf() async {
    if (_pdfBytes == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final filename = _defaultFilename;
      final file = await PdfExportService.savePdfToDevice(_pdfBytes!, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PDF Downloaded Successfully!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        file.path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Share',
              textColor: const Color(0xFFF59E0B),
              onPressed: () => _sharePdf(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: $e'),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;
    try {
      final filename = _defaultFilename;
      await PdfExportService.sharePdf(
        _pdfBytes!,
        filename,
        subject: widget.chapter != null
            ? 'Chapter ${widget.chapter!.id}: ${widget.chapter!.englishTitle} (1001 Authentic Hadith)'
            : '1001 Authentic Hadith: The Definitive Thematic Compendium',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.customTitle ??
        (widget.chapter != null
            ? 'Chapter ${widget.chapter!.id} PDF'
            : 'Complete Compendium PDF (1,001 Hadith)');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.chapter != null
                  ? widget.chapter!.arabicTitle
                  : '«أَلْفُ حَدِيثٍ وَحَدِيثٌ» — النسخة الكاملة',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 12,
                color: Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        actions: [
          if (!_isLoading && _pdfBytes != null) ...[
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded),
              tooltip: 'Download & Save PDF to Storage',
              onPressed: _downloadAndSavePdf,
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share PDF File',
              onPressed: _sharePdf,
            ),
          ],
        ],
      ),
      body: _buildBody(isDark),
      bottomNavigationBar: !_isLoading && _pdfBytes != null
          ? _buildBottomActionToolbar(isDark)
          : null,
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, size: 36, color: Color(0xFF14B8A6)),
              ),
              const SizedBox(height: 24),
              Text(
                widget.chapter != null ? 'Generating Chapter PDF...' : 'Compiling 1001 Hadiths as PDF...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 8,
                  backgroundColor: isDark ? const Color(0xFF162238) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111B2D) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, size: 18, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Formatting with Arabic Amiri & English Typography, full Tashkeel, Takhrij & Fawa\'id.',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 56, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text('PDF Generation Failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // PDF Preview Widget
    return PdfPreview(
      build: (format) => _pdfBytes!,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      allowPrinting: true,
      allowSharing: true,
      pdfFileName: _defaultFilename,
      loadingWidget: const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D9488)),
      ),
      actions: [
        PdfPreviewAction(
          icon: const Icon(Icons.save_alt_rounded),
          onPressed: (context, build, pageFormat) => _downloadAndSavePdf(),
        ),
      ],
    );
  }

  Widget _buildBottomActionToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111B2D) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _downloadAndSavePdf,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  _isSaving ? 'Saving...' : 'Download PDF',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _sharePdf,
                icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF14B8A6)),
                label: const Text(
                  'Share PDF',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF14B8A6)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
