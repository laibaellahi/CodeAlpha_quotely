// lib/data/datasources/local/local_storage_service.dart
//
// Wraps SharedPreferences and Hive for all persistent data needs.
// This single service is the gateway to all local storage.
import 'dart:convert';
//import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// Keys used in SharedPreferences.
abstract class PrefKeys {
  static const String themeMode = 'theme_mode';
  static const String fontSize = 'font_size';
  static const String preferredCategory = 'preferred_category';
  static const String dailyQuoteDate = 'daily_quote_date';
  static const String dailyQuoteId = 'daily_quote_id';
  static const String streakCount = 'streak_count';
  static const String lastStreakDate = 'last_streak_date';
  static const String dailyNotificationEnabled = 'daily_notif_enabled';
  static const String notificationHour = 'notif_hour';
  static const String notificationMinute = 'notif_minute';
}
/// Hive box names.
abstract class HiveBoxes {
  static const String favorites = 'favorites';
  static const String history = 'history';
}
/// Singleton local storage service.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();
  late SharedPreferences _prefs;
  late Box<String> _favoritesBox;
  late Box<String> _historyBox;
  /// Must be called once at app startup before using any other method.
  Future<void> init() async {
    await Hive.initFlutter();
    _prefs = await SharedPreferences.getInstance();
    _favoritesBox = await Hive.openBox<String>(HiveBoxes.favorites);
    _historyBox = await Hive.openBox<String>(HiveBoxes.history);
  }
  // ── Theme ──────────────────────────────────────────────────────────────────
  int get themeMode => _prefs.getInt(PrefKeys.themeMode) ?? 0; // 0=system
  Future<void> setThemeMode(int mode) => _prefs.setInt(PrefKeys.themeMode, mode);
  // ── Font Size ──────────────────────────────────────────────────────────────
  int get fontSize => _prefs.getInt(PrefKeys.fontSize) ?? 1; // 0=sm,1=md,2=lg,3=xl
  Future<void> setFontSize(int size) => _prefs.setInt(PrefKeys.fontSize, size);
  // ── Preferred Category ─────────────────────────────────────────────────────
  String get preferredCategory => _prefs.getString(PrefKeys.preferredCategory) ?? 'all';
  Future<void> setPreferredCategory(String cat) =>
      _prefs.setString(PrefKeys.preferredCategory, cat);
  // ── Daily Quote ────────────────────────────────────────────────────────────
  String? get dailyQuoteDate => _prefs.getString(PrefKeys.dailyQuoteDate);
  String? get dailyQuoteId => _prefs.getString(PrefKeys.dailyQuoteId);
  Future<void> setDailyQuote(String date, String id) async {
    await _prefs.setString(PrefKeys.dailyQuoteDate, date);
    await _prefs.setString(PrefKeys.dailyQuoteId, id);
  }
  // ── Streak ─────────────────────────────────────────────────────────────────
  int get streakCount => _prefs.getInt(PrefKeys.streakCount) ?? 0;
  String? get lastStreakDate => _prefs.getString(PrefKeys.lastStreakDate);
  Future<void> updateStreak(int count, String date) async {
    await _prefs.setInt(PrefKeys.streakCount, count);
    await _prefs.setString(PrefKeys.lastStreakDate, date);
  }
  // ── Notifications ──────────────────────────────────────────────────────────
  bool get dailyNotifEnabled => _prefs.getBool(PrefKeys.dailyNotificationEnabled) ?? false;
  int get notifHour => _prefs.getInt(PrefKeys.notificationHour) ?? 8;
  int get notifMinute => _prefs.getInt(PrefKeys.notificationMinute) ?? 0;
  Future<void> setNotifEnabled(bool val) =>
      _prefs.setBool(PrefKeys.dailyNotificationEnabled, val);
  Future<void> setNotifTime(int hour, int minute) async {
    await _prefs.setInt(PrefKeys.notificationHour, hour);
    await _prefs.setInt(PrefKeys.notificationMinute, minute);
  }
  // ── Favorites (Hive) ───────────────────────────────────────────────────────
  /// Returns all favorited quote IDs.
  List<String> getFavoriteIds() => _favoritesBox.values.toList();
  /// Stores the JSON of a favorited quote.
  Future<void> addFavorite(String quoteId, Map<String, dynamic> json) async {
    await _favoritesBox.put(quoteId, jsonEncode(json));
  }
  /// Removes a favorite by quote ID.
  Future<void> removeFavorite(String quoteId) async {
    await _favoritesBox.delete(quoteId);
  }
  /// Returns true if the quote is in the favorites box.
  bool isFavorite(String quoteId) => _favoritesBox.containsKey(quoteId);
  /// Returns all favorite JSON strings.
  List<String> getAllFavoriteJsons() => _favoritesBox.values.toList();
  // ── History (Hive) ────────────────────────────────────────────────────────
  /// Maximum number of history items to keep.
  static const int maxHistory = 20;
  /// Returns all history entries as raw JSON strings (newest first).
  List<String> getAllHistoryJsons() => _historyBox.values.toList().reversed.toList();
  /// Adds a history entry; evicts the oldest if over [maxHistory].
  Future<void> addHistory(String key, Map<String, dynamic> json) async {
    if (_historyBox.length >= maxHistory) {
      final oldestKey = _historyBox.keys.first;
      await _historyBox.delete(oldestKey);
    }
    await _historyBox.put(key, jsonEncode(json));
  }
  /// Clears all history.
  Future<void> clearHistory() => _historyBox.clear();
}
