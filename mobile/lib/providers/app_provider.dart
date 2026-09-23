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
  Set<int> _readHadiths = {};
  int? _lastReadHadithId;
  List<String> _recentSearches = [];
  AppThemeMode _themeMode = AppThemeMode.dark;
  double _arabicFontSize = 22.0;
  double _englishFontSize = 15.0;
  TtsPlaybackMode _ttsMode = TtsPlaybackMode.both;
  double _arabicSpeechRate = 0.45;
  double _englishSpeechRate = 0.50;

  // Notification Preferences
  bool _dailyReminderEnabled = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _notificationPermissionGranted = false;

  HadithService get service => _service;
  NotificationService get notificationService => _notificationService;
  bool get isLoading => _isLoading;
  Set<int> get bookmarks => _bookmarks;
  Set<int> get readHadiths => _readHadiths;
  int? get lastReadHadithId => _lastReadHadithId;
  List<String> get recentSearches => _recentSearches;
  AppThemeMode get themeMode => _themeMode;
  double get arabicFontSize => _arabicFontSize;
  double get englishFontSize => _englishFontSize;
  TtsPlaybackMode get ttsMode => _ttsMode;
  double get arabicSpeechRate => _arabicSpeechRate;
  double get englishSpeechRate => _englishSpeechRate;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;
  bool get notificationPermissionGranted => _notificationPermissionGranted;

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

      final savedRead = prefs.getStringList('read_hadiths') ?? [];
      _readHadiths = savedRead.map((s) => int.tryParse(s) ?? 0).where((id) => id > 0).toSet();

      _lastReadHadithId = prefs.getInt('last_read_hadith_id');

      _recentSearches = prefs.getStringList('recent_searches') ?? [];

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

      _notificationPermissionGranted = await _notificationService.areNotificationsEnabled();

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

  // ── READING PROGRESS & LAST READ ──────────────────────────────────────────

  Hadith? get lastReadHadith {
    if (_lastReadHadithId == null) return null;
    return _service.getHadithById(_lastReadHadithId!);
  }

  int get totalReadCount => _readHadiths.length;

  double get overallProgress {
    if (_service.allHadiths.isEmpty) return 0.0;
    return (_readHadiths.length / _service.allHadiths.length).clamp(0.0, 1.0);
  }

  bool isRead(int hadithId) => _readHadiths.contains(hadithId);

  int getChapterReadCount(int chapterId) {
    final chapterHadiths = _service.getHadithsForChapter(chapterId);
    if (chapterHadiths.isEmpty) return 0;
    return chapterHadiths.where((h) => _readHadiths.contains(h.id)).length;
  }

  double getChapterProgress(int chapterId) {
    final chapterHadiths = _service.getHadithsForChapter(chapterId);
    if (chapterHadiths.isEmpty) return 0.0;
    final readCount = chapterHadiths.where((h) => _readHadiths.contains(h.id)).length;
    return (readCount / chapterHadiths.length).clamp(0.0, 1.0);
  }

  void recordReadingPosition(int hadithId) async {
    _lastReadHadithId = hadithId;
    _readHadiths.add(hadithId);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_hadith_id', hadithId);
    await prefs.setStringList('read_hadiths', _readHadiths.map((id) => id.toString()).toList());
  }

  void resetReadingProgress() async {
    _readHadiths.clear();
    _lastReadHadithId = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_read_hadith_id');
    await prefs.remove('read_hadiths');
  }

  // ── RECENT SEARCHES ────────────────────────────────────────────────────────

  void addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    _recentSearches.remove(clean);
    _recentSearches.insert(0, clean);
    if (_recentSearches.length > 8) {
      _recentSearches = _recentSearches.sublist(0, 8);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void clearRecentSearches() async {
    _recentSearches.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }

  // ── NOTIFICATIONS & PERMISSIONS ───────────────────────────────────────────

  Future<bool> checkAndRequestNotificationPermissions() async {
    final granted = await _notificationService.requestPermissions();
    _notificationPermissionGranted = granted;
    notifyListeners();

    if (granted && _dailyReminderEnabled && _service.allHadiths.isNotEmpty) {
      await _notificationService.scheduleDailyHadithReminder(
        hour: _dailyReminderTime.hour,
        minute: _dailyReminderTime.minute,
        hadith: _service.getDailyHadith(),
      );
    }
    return granted;
  }

  Future<void> refreshNotificationPermissionStatus() async {
    _notificationPermissionGranted = await _notificationService.areNotificationsEnabled();
    notifyListeners();
  }

  // ── BOOKMARKS ─────────────────────────────────────────────────────────────

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

  // ── THEME & TYPOGRAPHY ────────────────────────────────────────────────────

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
      final granted = await _notificationService.requestPermissions();
      _notificationPermissionGranted = granted;
      notifyListeners();

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
    final granted = await _notificationService.requestPermissions();
    _notificationPermissionGranted = granted;
    notifyListeners();

    if (_service.allHadiths.isNotEmpty) {
      await _notificationService.showInstantTestNotification(
        hadith: _service.getDailyHadith(),
      );
    }
  }

  Future<void> scheduleTestNotification({int seconds = 10}) async {
    final granted = await _notificationService.requestPermissions();
    _notificationPermissionGranted = granted;
    notifyListeners();

    if (_service.allHadiths.isNotEmpty) {
      await _notificationService.scheduleTestNotification(
        seconds: seconds,
        hadith: _service.getDailyHadith(),
      );
    }
  }
}
