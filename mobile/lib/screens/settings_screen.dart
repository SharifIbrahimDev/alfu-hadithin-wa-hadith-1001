import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'book_reader_screen.dart';
import 'pdf_viewer_screen.dart';
import 'bibliography_screen.dart';

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
                        onChanged: (val) async {
                          await provider.setDailyReminderEnabled(val);
                          if (val && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🔔 Daily reminder active for ${provider.dailyReminderTime.format(context)}'),
                                backgroundColor: const Color(0xFF0D9488),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  if (provider.dailyReminderEnabled) ...[
                    const Divider(height: 24),

                    // Permission Status Badge / Action
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: provider.notificationPermissionGranted
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: provider.notificationPermissionGranted
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : const Color(0xFFF59E0B).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            provider.notificationPermissionGranted
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 20,
                            color: provider.notificationPermissionGranted
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              provider.notificationPermissionGranted
                                  ? 'Notifications are enabled and working'
                                  : 'Notification permission is required to receive daily alerts',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: provider.notificationPermissionGranted
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                          if (!provider.notificationPermissionGranted)
                            TextButton(
                              onPressed: () async {
                                final granted = await provider.checkAndRequestNotificationPermissions();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(granted
                                          ? '✅ Notification permissions granted!'
                                          : '⚠️ Please enable notifications in your device app settings.'),
                                      backgroundColor: granted ? const Color(0xFF0D9488) : Colors.orange[800],
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Grant',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (!provider.exactAlarmPermissionGranted) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.alarm_on_rounded,
                              size: 20,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alarms & Reminders Permission',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Required on Android 12+ so reminders wake your phone when asleep.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await provider.requestExactAlarmPermission();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Allow',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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

                    // Test Notifications & Multi-Duration Wake Tests
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await provider.sendTestNotification();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🔔 Instant test notification dispatched! Check your status bar.'),
                                    backgroundColor: Color(0xFF0D9488),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.notifications_active_outlined, size: 16),
                            label: const Text('Instant Test', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF14B8A6),
                              side: const BorderSide(color: Color(0xFF14B8A6)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showTestScheduleModal(context, provider, isDark),
                            icon: const Icon(Icons.alarm, size: 16),
                            label: const Text('Test Sleep Alarm…', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF59E0B),
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Reliability & Battery Optimization Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0A101D) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF14B8A6)),
                              const SizedBox(width: 6),
                              const Text(
                                'Overnight Delivery & Deep Sleep',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () => _showSleepOptimizationDialog(context, isDark),
                                child: const Text(
                                  'Help & Tips',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF14B8A6),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Daily reminders now use Android Alarm Clock mode to wake your device from deep Doze sleep. On Samsung, Xiaomi, and Infinix phones, set Battery to "Unrestricted" in device settings for 100% reliability.',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.3),
                          ),
                        ],
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

          // ── DOCUMENT & PDF EXPORT ───────────────────────────────────
          _SectionHeader(label: 'Book & PDF Documents'),

          SliverToBoxAdapter(
            child: _SettingsCard(
              isDark: isDark,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFF59E0B), size: 22),
                    ),
                    title: const Text(
                      'Download Complete Compendium PDF',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: const Text(
                      '1001 Hadiths with Arabic diacritics, English translation, and Fawa\'id',
                      style: TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      _showPdfLanguageEditionSelector(context);
                    },
                  ),
                  const Divider(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_stories_rounded, color: Color(0xFF14B8A6), size: 22),
                    ),
                    title: const Text(
                      'Continuous E-Book Reader',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Read full book continuously with chapter jumps & recitations',
                      style: TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookReaderScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.library_books_rounded, color: Color(0xFF14B8A6), size: 22),
                    ),
                    title: const Text(
                      'Source Bibliography (أهم المراجع)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: const Text(
                      '39 Canonical Hadith authorities & classical commentaries',
                      style: TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BibliographyScreen(),
                        ),
                      );
                    },
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
                    value: '«أَلْفُ حَدِيثٍ وَحَدِيثٌ فِي صَحِيحِ سُنَنِ خَيْرِ الْبَرِيَّةِ ﷺ»',
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

void _showSleepOptimizationDialog(BuildContext context, bool isDark) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF162238) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.battery_charging_full_rounded, color: Color(0xFF14B8A6), size: 22),
          SizedBox(width: 8),
          Flexible(
            child: Text('Reliable Reminders Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Modern Android versions and OEM brands (Samsung, Xiaomi, Infinix, Tecno) put apps into deep sleep overnight, which can delay or silence reminders.\n\nTo ensure your daily reminder arrives exactly on time:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            _buildDialogStep(
              '1. Set Battery to Unrestricted',
              'Go to phone Settings > Apps > Alfu Hadithin > Battery, and choose "Unrestricted" (or turn off "Battery Optimization").',
            ),
            const SizedBox(height: 8),
            _buildDialogStep(
              '2. Allow Exact Alarms',
              'In phone Settings > Apps > Alfu Hadithin > Alarms & Reminders, ensure "Allow setting alarms" is toggled ON.',
            ),
            const SizedBox(height: 8),
            _buildDialogStep(
              '3. Enable Auto-Start (Xiaomi / Infinix / Tecno)',
              'In your phone\'s Security / Phone Master app, allow Alfu Hadithin to auto-start in the background.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            final provider = Provider.of<AppProvider>(context, listen: false);
            await provider.requestExactAlarmPermission();
          },
          child: const Text('Open Alarm Settings', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Got it', style: TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

void _showTestScheduleModal(BuildContext context, AppProvider provider, bool isDark) {
  final options = [
    {'label': '1 Minute (60s)', 'seconds': 60, 'sub': 'Quick lock-screen wake test'},
    {'label': '3 Minutes (180s)', 'seconds': 180, 'sub': 'Screen off sleep test'},
    {'label': '5 Minutes (300s)', 'seconds': 300, 'sub': 'Initial Android Doze mode test'},
    {'label': '10 Minutes (600s)', 'seconds': 600, 'sub': 'Standard deep sleep test'},
    {'label': '20 Minutes (1200s)', 'seconds': 1200, 'sub': 'Deep Doze idle test'},
    {'label': '30 Minutes (1800s)', 'seconds': 1800, 'sub': 'Extended overnight test'},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF162238) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm_add_rounded, color: Color(0xFF14B8A6), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Schedule Wake-Up Alarm Test',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Select a duration, then lock your phone and leave it undisturbed. The alarm will wake your device from deep Doze:',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            ...options.map((opt) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                dense: true,
                leading: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.timer_outlined, color: Color(0xFF14B8A6), size: 18),
                ),
                title: Text(opt['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(opt['sub'] as String, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () async {
                  Navigator.pop(ctx);
                  final seconds = opt['seconds'] as int;
                  final label = opt['label'] as String;
                  await provider.scheduleTestNotification(seconds: seconds);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⏰ Test alarm set for $label! Please lock your phone now to test deep sleep delivery.'),
                        backgroundColor: const Color(0xFF0D9488),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                },
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDialogStep(String title, String desc) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.04),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF14B8A6))),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, height: 1.3)),
      ],
    ),
  );
}

void _showPdfLanguageEditionSelector(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF111B2D) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF14B8A6), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select PDF Edition',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Choose which language version to download',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. Both (Bilingual)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: const Color(0xFF0D9488).withOpacity(0.4)),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0D9488),
                  child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                ),
                title: const Text('1. Bilingual Edition (Both)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Arabic Matn with Tashkeel + English Translation & Dual Fawā\'id', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PdfViewerScreen(initialLanguageMode: HadithPdfLanguageMode.both),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // 2. Arabic Only
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF59E0B),
                  child: Icon(Icons.format_align_right, color: Colors.white, size: 20),
                ),
                title: const Text('2. Arabic Edition (النسخة العربية الكاملة)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('نص الأحاديث النبوية بالشكل التام + التخريج + الفوائد والعبر', style: TextStyle(fontSize: 11, fontFamily: 'Amiri')),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PdfViewerScreen(initialLanguageMode: HadithPdfLanguageMode.arabicOnly),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // 3. English Only
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: const Color(0xFF3B82F6).withOpacity(0.4)),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF3B82F6),
                  child: Icon(Icons.translate_rounded, color: Colors.white, size: 20),
                ),
                title: const Text('3. English Edition (Complete English)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('English Translation + Canonical Reference + Scholarly Lessons', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PdfViewerScreen(initialLanguageMode: HadithPdfLanguageMode.englishOnly),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
