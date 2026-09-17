import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith.dart';
import '../services/hadith_service.dart';

enum AppThemeMode { dark, sepia, light }

class AppProvider with ChangeNotifier {
  final HadithService _service = HadithService();
  bool _isLoading = true;
  Set<int> _bookmarks = {};
  AppThemeMode _themeMode = AppThemeMode.dark;
  double _arabicFontSize = 22.0;
  double _englishFontSize = 15.0;

  HadithService get service => _service;
  bool get isLoading => _isLoading;
  Set<int> get bookmarks => _bookmarks;
  AppThemeMode get themeMode => _themeMode;
  double get arabicFontSize => _arabicFontSize;
  double get englishFontSize => _englishFontSize;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    await _service.loadData();
    final prefs = await SharedPreferences.getInstance();

    final savedBookmarks = prefs.getStringList('saved_bookmarks') ?? [];
    _bookmarks = savedBookmarks.map((s) => int.tryParse(s) ?? 0).where((id) => id > 0).toSet();

    final themeStr = prefs.getString('theme_mode') ?? 'dark';
    if (themeStr == 'sepia') _themeMode = AppThemeMode.sepia;
    else if (themeStr == 'light') _themeMode = AppThemeMode.light;
    else _themeMode = AppThemeMode.dark;

    _arabicFontSize = prefs.getDouble('arabic_font_size') ?? 22.0;
    _englishFontSize = prefs.getDouble('english_font_size') ?? 15.0;

    _isLoading = false;
    notifyListeners();
  }

  void toggleBookmark(int hadithId) async {
    if (_bookmarks.contains(hadithId)) {
      _bookmarks.remove(hadithId);
    } else {
      _bookmarks.add(hadithId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('saved_bookmarks', _bookmarks.map((id) => id.toString()).toList());
  }

  bool isBookmarked(int hadithId) => _bookmarks.contains(hadithId);

  List<Hadith> get bookmarkedHadiths {
    return _service.allHadiths.where((h) => _bookmarks.contains(h.id)).toList();
  }

  void setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_mode', mode.name);
  }

  void setArabicFontSize(double size) async {
    _arabicFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('arabic_font_size', size);
  }

  void setEnglishFontSize(double size) async {
    _englishFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('english_font_size', size);
  }
}
