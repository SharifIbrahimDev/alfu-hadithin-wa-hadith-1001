import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D9488).withOpacity(0.15),
                    const Color(0xFF0A101D).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Color(0xFF14B8A6), size: 26),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalise your reading experience',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),

          // ── APPEARANCE ──────────────────────────────────────────────
          _SectionHeader(label: 'Appearance'),

          SliverToBoxAdapter(
            child: _SettingsCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsTileLabel(
                    icon: Icons.dark_mode_outlined,
                    label: 'Theme',
                    subtitle: 'Choose your preferred colour scheme',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ThemeChip(
                        label: 'Dark',
                        icon: Icons.dark_mode,
                        selected: provider.themeMode == AppThemeMode.dark,
                        color: const Color(0xFF0F172A),
                        textColor: Colors.white,
                        onTap: () => provider.setThemeMode(AppThemeMode.dark),
                      ),
                      const SizedBox(width: 10),
                      _ThemeChip(
                        label: 'Sepia',
                        icon: Icons.auto_stories,
                        selected: provider.themeMode == AppThemeMode.sepia,
                        color: const Color(0xFFF5DEB3),
                        textColor: const Color(0xFF3B2F2F),
                        onTap: () => provider.setThemeMode(AppThemeMode.sepia),
                      ),
                      const SizedBox(width: 10),
                      _ThemeChip(
                        label: 'Light',
                        icon: Icons.light_mode,
                        selected: provider.themeMode == AppThemeMode.light,
                        color: const Color(0xFFF8FAFC),
                        textColor: const Color(0xFF0F172A),
                        onTap: () => provider.setThemeMode(AppThemeMode.light),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── TYPOGRAPHY ──────────────────────────────────────────────
          _SectionHeader(label: 'Typography'),

          SliverToBoxAdapter(
            child: _SettingsCard(
              isDark: isDark,
              child: Column(
                children: [
                  // Arabic Font Size
                  _SettingsTileLabel(
                    icon: Icons.translate,
                    label: 'Arabic Font Size',
                    subtitle: 'Adjust Arabic text for comfortable reading',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${provider.arabicFontSize.toInt()} px',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14B8A6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A101D) : const Color(0xFFF0FDF9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: provider.arabicFontSize,
                        height: 1.7,
                      ),
                    ),
                  ),
                  Slider(
                    value: provider.arabicFontSize,
                    min: 18,
                    max: 34,
                    divisions: 8,
                    activeColor: const Color(0xFF0D9488),
                    inactiveColor: const Color(0xFF0D9488).withOpacity(0.2),
                    onChanged: (val) => provider.setArabicFontSize(val),
                  ),

                  const Divider(height: 24),

                  // English Font Size
                  _SettingsTileLabel(
                    icon: Icons.text_fields_rounded,
                    label: 'English Font Size',
                    subtitle: 'Adjust English translation text',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${provider.englishFontSize.toInt()} px',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A101D) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '"Actions are judged only by intentions…"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: provider.englishFontSize,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Slider(
                    value: provider.englishFontSize,
                    min: 12,
                    max: 22,
                    divisions: 10,
                    activeColor: const Color(0xFFF59E0B),
                    inactiveColor: const Color(0xFFF59E0B).withOpacity(0.2),
                    onChanged: (val) => provider.setEnglishFontSize(val),
                  ),
                ],
              ),
            ),
          ),

          // ── AUDIO & VOICE (TTS) ─────────────────────────────────────
          _SectionHeader(label: 'Audio & Voice (TTS)'),

          SliverToBoxAdapter(
            child: _SettingsCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsTileLabel(
                    icon: Icons.record_voice_over_rounded,
                    label: 'Default Audio Mode',
                    subtitle: 'Choose what plays when tapping the Audio button',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _TtsModeChip(
                          label: 'Both (Ar + En)',
                          icon: Icons.sync_alt_rounded,
                          selected: provider.ttsMode == TtsPlaybackMode.both,
                          color: const Color(0xFF0D9488),
                          onTap: () => provider.setTtsMode(TtsPlaybackMode.both),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TtsModeChip(
                          label: 'Arabic 🇸🇦',
                          icon: Icons.translate_rounded,
                          selected: provider.ttsMode == TtsPlaybackMode.arabicOnly,
                          color: const Color(0xFF10B981),
                          onTap: () => provider.setTtsMode(TtsPlaybackMode.arabicOnly),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TtsModeChip(
                          label: 'English 🇬🇧',
                          icon: Icons.volume_up_rounded,
                          selected: provider.ttsMode == TtsPlaybackMode.englishOnly,
                          color: const Color(0xFFF59E0B),
                          onTap: () => provider.setTtsMode(TtsPlaybackMode.englishOnly),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Arabic Speech Rate
                  _SettingsTileLabel(
                    icon: Icons.speed_rounded,
                    label: 'Arabic Speech Speed',
                    subtitle: 'Adjust recitation pace for Arabic text',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${provider.arabicSpeechRate.toStringAsFixed(2)}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Slider(
                    value: provider.arabicSpeechRate,
                    min: 0.25,
                    max: 0.85,
                    divisions: 12,
                    activeColor: const Color(0xFF10B981),
                    inactiveColor: const Color(0xFF10B981).withOpacity(0.2),
                    onChanged: (val) => provider.setArabicSpeechRate(val),
                  ),

                  const Divider(height: 24),

                  // English Speech Rate
                  _SettingsTileLabel(
                    icon: Icons.speed_rounded,
                    label: 'English Speech Speed',
                    subtitle: 'Adjust narration pace for English translation',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${provider.englishSpeechRate.toStringAsFixed(2)}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Slider(
                    value: provider.englishSpeechRate,
                    min: 0.25,
                    max: 0.85,
                    divisions: 12,
                    activeColor: const Color(0xFFF59E0B),
                    inactiveColor: const Color(0xFFF59E0B).withOpacity(0.2),
                    onChanged: (val) => provider.setEnglishSpeechRate(val),
                  ),
                ],
              ),
            ),
          ),

          // ── DAILY HADITH REMINDER ──────────────────────────────────
          _SectionHeader(label: 'Daily Hadith Reminder'),

          SliverToBoxAdapter(
            child: _SettingsCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Switch Tile
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF14B8A6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Hadith Notification',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Receive a blessed Hadith every day',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: provider.dailyReminderEnabled,
                        activeColor: const Color(0xFF14B8A6),
                        onChanged: (val) => provider.setDailyReminderEnabled(val),
                      ),
                    ],
                  ),

                    if (provider.dailyReminderEnabled) ...[
                    const Divider(height: 24),

                    // Time Picker Row
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: provider.dailyReminderTime,
                          builder: (context, child) {
                            return Theme(
                              data: isDark
                                  ? ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF14B8A6),
                                        onPrimary: Colors.white,
                                        surface: Color(0xFF162238),
                                        onSurface: Colors.white,
                                      ),
                                    )
                                  : ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF0D9488),
                                        onPrimary: Colors.white,
                                      ),
                                    ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          await provider.setDailyReminderTime(picked);
                          if (context.mounted) {
                            final now = DateTime.now();
                            var target = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                            final isToday = target.isAfter(now);
                            if (!isToday) target = target.add(const Duration(days: 1));
                            final diff = target.difference(now);
                            final hours = diff.inHours;
                            final mins = diff.inMinutes % 60;
                            final timeText = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
                            final dayText = isToday ? 'today' : 'tomorrow';

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⏰ Reminder scheduled for $dayText at ${picked.format(context)} (in $timeText)'),
                                backgroundColor: const Color(0xFF0D9488),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                color: Color(0xFFF59E0B),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Reminder Time',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap to change daily notification time',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                provider.dailyReminderTime.format(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 24),

                    // Test Scheduled Notification in 10 Seconds Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await provider.scheduleTestNotification(seconds: 10);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⏱️ Alarm scheduled for 10 SECONDS from now!\n👉 Lock your screen or exit app to test real-time wake up.'),
                                backgroundColor: Color(0xFF0D9488),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.timer_outlined, size: 18),
                        label: const Text(
                          'Test Scheduled Alarm (in 10 Seconds)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Instant Test Notification Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await provider.sendTestNotification();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✨ Test Hadith notification sent instantly! Check your notification bar.'),
                                backgroundColor: Color(0xFF0D9488),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF14B8A6),
                          side: BorderSide(
                            color: const Color(0xFF14B8A6).withOpacity(0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.notifications_none_rounded, size: 18),
                        label: const Text(
                          'Send Instant Notification Now',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── READING PREFERENCES ─────────────────────────────────────
          _SectionHeader(label: 'Reading Preferences'),

          SliverToBoxAdapter(
            child: _SettingsCard(
              isDark: isDark,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.language,
                    iconColor: const Color(0xFF14B8A6),
                    label: 'Primary Language',
                    value: 'Arabic + English',
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.format_align_right,
                    iconColor: const Color(0xFF14B8A6),
                    label: 'Arabic Text Direction',
                    value: 'Right-to-Left (RTL)',
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.spellcheck,
                    iconColor: const Color(0xFF14B8A6),
                    label: 'Diacritics (Tashkeel)',
                    value: 'Always Enabled',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // ── APP INFO ────────────────────────────────────────────────
          _SectionHeader(label: 'App Information'),

          SliverToBoxAdapter(
            child: _SettingsCard(
              isDark: isDark,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Compendium',
                    value: 'أَلْفُ حَدِيثٍ وَحَدِيثٌ',
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.format_list_numbered,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Total Hadiths',
                    value: '1001 Authentic Hadiths',
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.category_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Chapters',
                    value: '20 Thematic Chapters',
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Author & Compiler',
                    value: 'Ibrahim Sharif Abubakar',
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.verified_rounded,
                    iconColor: const Color(0xFF14B8A6),
                    label: 'Edition',
                    value: '1st Complete Edition (2026)',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // ── RESET ───────────────────────────────────────────────────
          _SectionHeader(label: 'Reset'),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: OutlinedButton.icon(
                onPressed: () => _confirmReset(context, provider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset All Settings to Default', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Center(
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nVerified via Maktaba Shamela • 1st Edition 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will restore the default theme, font sizes, audio recitation modes, and all appearance settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.setThemeMode(AppThemeMode.dark);
              provider.setArabicFontSize(22.0);
              provider.setEnglishFontSize(15.0);
              provider.setTtsMode(TtsPlaybackMode.both);
              provider.setArabicSpeechRate(0.45);
              provider.setEnglishSpeechRate(0.50);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to default'),
                  backgroundColor: Color(0xFF0D9488),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _TtsModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TtsModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : (isDark ? const Color(0xFF0A101D) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: selected ? color : (isDark ? Colors.grey[400] : Colors.grey[700])),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: selected ? color : (isDark ? Colors.grey[300] : Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF14B8A6),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SettingsCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162238) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _SettingsTileLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget? trailing;
  const _SettingsTileLabel({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF14B8A6), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0D9488).withOpacity(0.2) : color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF0D9488) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? const Color(0xFF14B8A6) : textColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF14B8A6) : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
