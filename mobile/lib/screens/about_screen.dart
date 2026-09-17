import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Settings'),
      ),
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
                      fontSize: 24,
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A101D) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                      ),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'AUTHOR & COMPILER',
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ibrahim Sharif Abubakar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                        ),
                        Text(
                          'إِبْرَاهِيم شَرِيف أَبُوبَكْر',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Typography & Appearance Settings
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162238) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appearance & Typography',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Arabic Font Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Arabic Font Size'),
                      Text(
                        '${provider.arabicFontSize.toInt()} px',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6)),
                      ),
                    ],
                  ),
                  Slider(
                    value: provider.arabicFontSize,
                    min: 18,
                    max: 34,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) => provider.setArabicFontSize(val),
                  ),

                  const SizedBox(height: 10),

                  // English Font Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('English Font Size'),
                      Text(
                        '${provider.englishFontSize.toInt()} px',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14B8A6)),
                      ),
                    ],
                  ),
                  Slider(
                    value: provider.englishFontSize,
                    min: 13,
                    max: 22,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) => provider.setEnglishFontSize(val),
                  ),
                ],
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
}
