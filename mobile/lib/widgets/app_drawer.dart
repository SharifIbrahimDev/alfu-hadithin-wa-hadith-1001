import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../screens/hadith_reader_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentTabIndex;
  final Function(int index)? onSelectTab;

  const AppDrawer({
    Key? key,
    this.currentTabIndex = 0,
    this.onSelectTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalHadiths = provider.service.allHadiths.length;
    final totalChapters = provider.service.allChapters.length;
    final bookmarkCount = provider.bookmarks.length;

    final bgColor = isDark ? const Color(0xFF0D1524) : Colors.white;
    final itemHoverBg =
        isDark ? const Color(0xFF162238) : const Color(0xFFF1F5F9);

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── DRAWER HEADER ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0F2B2B),
                          const Color(0xFF0A1828),
                        ]
                      : [
                          const Color(0xFF0D9488),
                          const Color(0xFF0F766E),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF14B8A6).withOpacity(0.2)
                              : Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFFF59E0B),
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'أَلْفُ حَدِيثٍ وَحَدِيثٌ',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '1001 Authentic Hadith',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Compiled by Ibrahim Sharif Abubakar',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata Badges
                  Row(
                    children: [
                      _Badge(
                        label: '$totalChapters Chapters',
                        color: const Color(0xFF14B8A6),
                      ),
                      const SizedBox(width: 8),
                      _Badge(
                        label: '$totalHadiths Hadiths',
                        color: const Color(0xFFF59E0B),
                      ),
                      if (bookmarkCount > 0) ...[
                        const SizedBox(width: 8),
                        _Badge(
                          label: '$bookmarkCount Saved',
                          color: Colors.pinkAccent,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── DRAWER CONTENT ─────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                children: [
                  _SectionTitle(label: 'Navigation'),
                  _DrawerItem(
                    icon: Icons.menu_book_rounded,
                    title: 'Thematic Chapters',
                    subtitle: 'Browse all 20 Hadith chapters',
                    selected: currentTabIndex == 0,
                    selectedColor: const Color(0xFF14B8A6),
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab?.call(0);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.search_rounded,
                    title: 'Search Hadiths',
                    subtitle: 'Search in Arabic & English',
                    selected: currentTabIndex == 1,
                    selectedColor: const Color(0xFF14B8A6),
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab?.call(1);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bookmark_rounded,
                    title: 'Bookmarks & Favorites',
                    subtitle: '$bookmarkCount saved hadiths',
                    selected: currentTabIndex == 2,
                    selectedColor: const Color(0xFFF59E0B),
                    badgeCount: bookmarkCount,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab?.call(2);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About the Compendium',
                    subtitle: 'Author, methodology & Shamela',
                    selected: currentTabIndex == 3,
                    selectedColor: const Color(0xFF14B8A6),
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab?.call(3);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.tune_rounded,
                    title: 'Settings & Preferences',
                    subtitle: 'Theme, fonts, voice & audio',
                    selected: currentTabIndex == 4,
                    selectedColor: const Color(0xFF14B8A6),
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab?.call(4);
                    },
                  ),

                  const Divider(height: 20),

                  _SectionTitle(label: 'Quick Actions'),
                  _DrawerItem(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Hadith of the Day',
                    subtitle: 'Read today’s selected Hadith',
                    onTap: () {
                      Navigator.pop(context);
                      final daily = provider.service.getDailyHadith();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              HadithReaderScreen(initialHadithId: daily.id),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.casino_rounded,
                    iconColor: const Color(0xFF14B8A6),
                    title: 'Random Hadith',
                    subtitle: 'Discover a random Hadith',
                    onTap: () {
                      Navigator.pop(context);
                      final all = provider.service.allHadiths;
                      if (all.isNotEmpty) {
                        final randomIdx = Random().nextInt(all.length);
                        final randomHadith = all[randomIdx];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HadithReaderScreen(
                                initialHadithId: randomHadith.id),
                          ),
                        );
                      }
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_active_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: 'Daily Reminders',
                    subtitle: provider.dailyReminderEnabled
                        ? 'Active at ${provider.dailyReminderTime.format(context)}'
                        : 'Disabled',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab?.call(4);
                    },
                  ),

                  const Divider(height: 20),

                  _SectionTitle(label: 'Theme'),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        _ThemeButton(
                          label: 'Dark',
                          icon: Icons.dark_mode_rounded,
                          selected: provider.themeMode == AppThemeMode.dark,
                          onTap: () => provider.setThemeMode(AppThemeMode.dark),
                        ),
                        const SizedBox(width: 8),
                        _ThemeButton(
                          label: 'Sepia',
                          icon: Icons.auto_stories_rounded,
                          selected: provider.themeMode == AppThemeMode.sepia,
                          onTap: () =>
                              provider.setThemeMode(AppThemeMode.sepia),
                        ),
                        const SizedBox(width: 8),
                        _ThemeButton(
                          label: 'Light',
                          icon: Icons.light_mode_rounded,
                          selected: provider.themeMode == AppThemeMode.light,
                          onTap: () =>
                              provider.setThemeMode(AppThemeMode.light),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 20),

                  _SectionTitle(label: 'Share'),
                  _DrawerItem(
                    icon: Icons.share_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Share Compendium App',
                    subtitle: 'Share 1001 Authentic Hadith with others',
                    onTap: () {
                      Navigator.pop(context);
                      Share.share(
                        '📚 1001 Authentic Hadith Compendium (أَلْفُ حَدِيثٍ وَحَدِيثٌ)\n\n'
                        'Compiled by Ibrahim Sharif Abubakar.\n'
                        'Explore 1001 authenticated Hadiths across 20 thematic chapters with Arabic audio recitation, English translation, and daily notifications.\n\n'
                        'Verified via Maktaba Shamela.',
                        subject: '1001 Authentic Hadith Compendium',
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── FOOTER ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.06),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edition 1.0.0 (2026)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  const Text(
                    'أَلْفُ حَدِيثٍ',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14B8A6),
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
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF14B8A6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool selected;
  final Color selectedColor;
  final int? badgeCount;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.selected = false,
    this.selectedColor = const Color(0xFF0D9488),
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: selected
            ? selectedColor.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: selectedColor.withOpacity(0.3), width: 1)
            : null,
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withOpacity(0.2)
                : (iconColor?.withOpacity(0.12) ??
                    (isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.04))),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: selected
                ? selectedColor
                : (iconColor ??
                    (isDark ? Colors.grey[300] : const Color(0xFF0F172A))),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            color: selected
                ? selectedColor
                : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        trailing: (badgeCount != null && badgeCount! > 0)
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF14B8A6).withOpacity(0.18)
                : (isDark
                    ? const Color(0xFF162238)
                    : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF14B8A6)
                  : (isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.06)),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? const Color(0xFF14B8A6)
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? const Color(0xFF14B8A6)
                      : (isDark ? Colors.grey[300] : Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
