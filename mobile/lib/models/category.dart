import 'package:flutter/material.dart';

class ThematicCategory {
  final String id;
  final String titleEn;
  final String titleAr;
  final String icon;
  final Color color;
  final List<int> chapterIds;

  const ThematicCategory({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.color,
    required this.chapterIds,
  });

  static const List<ThematicCategory> categories = [
    ThematicCategory(
      id: 'all',
      titleEn: 'All Hadiths',
      titleAr: 'جميع الأحاديث',
      icon: '📚',
      color: Color(0xFF0D9488),
      chapterIds: [],
    ),
    ThematicCategory(
      id: 'iman',
      titleEn: 'Faith & Knowledge',
      titleAr: 'الإيمان والعلم',
      icon: '🌟',
      color: Color(0xFF14B8A6),
      chapterIds: [0, 1, 7, 8],
    ),
    ThematicCategory(
      id: 'worship',
      titleEn: 'Worship & Pillars',
      titleAr: 'العبادات والأركان',
      icon: '🕌',
      color: Color(0xFF10B981),
      chapterIds: [2, 3, 4, 5, 6],
    ),
    ThematicCategory(
      id: 'dhikr',
      titleEn: 'Dhikr, Dua & Istighfar',
      titleAr: 'الأذكار والدعاء',
      icon: '📿',
      color: Color(0xFFF59E0B),
      chapterIds: [9, 10, 11, 12],
    ),
    ThematicCategory(
      id: 'manners',
      titleEn: 'Manners & Kinship',
      titleAr: 'الأخلاق والبر والصلة',
      icon: '💎',
      color: Color(0xFF3B82F6),
      chapterIds: [13, 14, 15],
    ),
    ThematicCategory(
      id: 'social',
      titleEn: 'Family & Transactions',
      titleAr: 'الأسرة والمعاملات',
      icon: '🤝',
      color: Color(0xFF8B5CF6),
      chapterIds: [17, 18],
    ),
    ThematicCategory(
      id: 'hereafter',
      titleEn: 'Heart Softeners & Virtues',
      titleAr: 'الرقائق والفضائل',
      icon: '🛡️',
      color: Color(0xFFEC4899),
      chapterIds: [16, 19, 20],
    ),
  ];
}
