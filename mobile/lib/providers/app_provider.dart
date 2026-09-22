import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith.dart';
import '../services/hadith_service.dart';
import '../services/notification_service.dart';

enum AppThemeMode { dark, sepia, light }

enum TtsPlaybackMode { both, arabicOnly, englishOnly }

class AppProvider with ChangeNotifier {
  final HadithService _service = HadithService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  Set<int> _bookmarks = {};
  AppThemeMode _themeMode = AppThemeMode.dark;
  double _arabicFontSize = 22.0;
  double _englishFontSize = 15.0;
  TtsPlaybackMode _ttsMode = TtsPlaybackMode.both;
  double _arabicSpeechRate = 0.45;
  double _englishSpeechRate = 0.50;

  // Notification Preferences
  bool _dailyReminderEnabled = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 8, minute: 0);

  HadithService get service => _service;
  NotificationService get notificationService => _notificationService;
  bool get isLoading => _isLoading;
  Set<int> get bookmarks => _bookmarks;
  AppThemeMode get themeMode => _themeMode;
  double get arabicFontSize => _arabicFontSize;
  double get englishFontSize => _englishFontSize;
  TtsPlaybackMode get ttsMode => _ttsMode;
  double get arabicSpeechRate => _arabicSpeechRate;
  double get englishSpeechRate => _englishSpeechRate;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;

  AppProvider() {
    _init();
  }

  Future<void> reload() async {
    _isLoading = true;
    notifyListeners();
    await _init();
  }

  Future<void> _init() async {
    try {
      await _service.loadData();
      final prefs = await SharedPreferences.getInstance();

      final savedBookmarks = prefs.getStringList('saved_bookmarks') ?? [];
      _bookmarks = savedBookmarks.map((s) => int.tryParse(s) ?? 0).where((id) => id > 0).toSet();

      final themeStr = prefs.getString('theme_mode') ?? 'dark';
      if (themeStr == 'sepia') {
        _themeMode = AppThemeMode.sepia;
      } else if (themeStr == 'light') {
        _themeMode = AppThemeMode.light;
      } else {
        _themeMode = AppThemeMode.dark;
      }

      _arabicFontSize = prefs.getDouble('arabic_font_size') ?? 22.0;
      _englishFontSize = prefs.getDouble('english_font_size') ?? 15.0;

      final ttsModeStr = prefs.getString('tts_mode') ?? 'both';
      if (ttsModeStr == 'arabicOnly') {
        _ttsMode = TtsPlaybackMode.arabicOnly;
      } else if (ttsModeStr == 'englishOnly') {
        _ttsMode = TtsPlaybackMode.englishOnly;
      } else {
        _ttsMode = TtsPlaybackMode.both;
      }

      _arabicSpeechRate = prefs.getDouble('arabic_speech_rate') ?? 0.45;
      _englishSpeechRate = prefs.getDouble('english_speech_rate') ?? 0.50;

      _dailyReminderEnabled = prefs.getBool('daily_reminder_enabled') ?? true;
      final hour = prefs.getInt('daily_reminder_hour') ?? 8;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);

      if (_dailyReminderEnabled && _service.allHadiths.isNotEmpty) {
        try {
          await _notificationService.scheduleDailyHadithReminder(
            hour: _dailyReminderTime.hour,
            minute: _dailyReminderTime.minute,
            hadith: _service.getDailyHadith(),
          );
        } catch (e) {
          debugPrint('Error scheduling daily reminder during init: $e');
        }
      }
    } catch (e, st) {
      debugPrint('Error in AppProvider._init: $e\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  void setTtsMode(TtsPlaybackMode mode) async {
    _ttsMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tts_mode', mode.name);
  }

  void setArabicSpeechRate(double rate) async {
    _arabicSpeechRate = rate;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('arabic_speech_rate', rate);
  }

  void setEnglishSpeechRate(double rate) async {
    _englishSpeechRate = rate;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('english_speech_rate', rate);
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _dailyReminderEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', enabled);

    if (enabled) {
      await _notificationService.requestPermissions();
      if (_service.allHadiths.isNotEmpty) {
        await _notificationService.scheduleDailyHadithReminder(
          hour: _dailyReminderTime.hour,
          minute: _dailyReminderTime.minute,
          hadith: _service.getDailyHadith(),
        );
      }
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    _dailyReminderTime = time;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_reminder_hour', time.hour);
    await prefs.setInt('daily_reminder_minute', time.minute);

    if (_dailyReminderEnabled && _service.allHadiths.isNotEmpty) {
      await _notificationService.scheduleDailyHadithReminder(
        hour: time.hour,
        minute: time.minute,
        hadith: _service.getDailyHadith(),
      );
    }
  }

  Future<void> sendTestNotification() async {
    await _notificationService.requestPermissions();
    if (_service.allHadiths.isNotEmpty) {
      await _notificationService.showInstantTestNotification(
        hadith: _service.getDailyHadith(),
      );
    }
  }
}

