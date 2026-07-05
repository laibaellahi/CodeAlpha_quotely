// lib/providers/providers.dart
//
// All Riverpod providers in one place, using the recommended
// "provider-per-file" or grouped pattern for smaller projects.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local/local_storage_service.dart';
import '../data/repositories/code_repository_impl.dart';
import '../domain/entities/quote.dart';
import '../domain/entities/quote_category.dart';
import '../domain/repositories/quote_repository.dart';
// ═══════════════════════════════════════════════════════════════════════════════
// INFRASTRUCTURE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════
/// Provides the initialised [LocalStorageService] singleton.
/// Must be overridden in ProviderScope after init().
final localStorageProvider = Provider<LocalStorageService>((_) {
  throw UnimplementedError('LocalStorageService not yet initialised');
});
/// Provides the [QuoteRepository] concrete implementation.
final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  final storage = ref.watch(localStorageProvider);
  return QuoteRepositoryImpl(storage);
});
// ═══════════════════════════════════════════════════════════════════════════════
// SETTINGS PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════
/// Theme mode: 0=system, 1=light, 2=dark
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, int>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ThemeModeNotifier(storage);
});
class ThemeModeNotifier extends StateNotifier<int> {
  final LocalStorageService _storage;
  ThemeModeNotifier(this._storage) : super(_storage.themeMode);
  void setMode(int mode) {
    state = mode;
    _storage.setThemeMode(mode);
  }
  ThemeMode get themeMode {
    switch (state) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
/// Font size index: 0=small, 1=medium, 2=large, 3=extra large
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, int>((ref) {
  final storage = ref.watch(localStorageProvider);
  return FontSizeNotifier(storage);
});
class FontSizeNotifier extends StateNotifier<int> {
  final LocalStorageService _storage;
  FontSizeNotifier(this._storage) : super(_storage.fontSize);
  void setSize(int idx) {
    state = idx;
    _storage.setFontSize(idx);
  }
  /// Returns the quote text font size for the current setting.
  double get quoteTextSize {
    switch (state) {
      case 0:
        return 20.0;
      case 1:
        return 24.0;
      case 2:
        return 28.0;
      case 3:
        return 32.0;
      default:
        return 24.0;
    }
  }
  double get textScaleFactor {
    switch (state) {
      case 0:
        return 0.9;
      case 1:
        return 1.0;
      case 2:
        return 1.15;
      case 3:
        return 1.3;
      default:
        return 1.0;
    }
  }
}
/// Preferred category filter for the home screen.
final preferredCategoryProvider =
    StateNotifierProvider<PreferredCategoryNotifier, QuoteCategory>((ref) {
  final storage = ref.watch(localStorageProvider);
  return PreferredCategoryNotifier(storage);
});
class PreferredCategoryNotifier extends StateNotifier<QuoteCategory> {
  final LocalStorageService _storage;
  PreferredCategoryNotifier(this._storage)
      : super(QuoteCategory.fromKey(_storage.preferredCategory));
  void setCategory(QuoteCategory cat) {
    state = cat;
    _storage.setPreferredCategory(cat.key);
  }
}
// ═══════════════════════════════════════════════════════════════════════════════
// QUOTE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════
/// Notifier managing the currently displayed quote on the Home screen.
final currentQuoteProvider =
    StateNotifierProvider<CurrentQuoteNotifier, Quote?>((ref) {
  final repo = ref.watch(quoteRepositoryProvider);
  final category = ref.watch(preferredCategoryProvider);
  return CurrentQuoteNotifier(repo, category);
});
class CurrentQuoteNotifier extends StateNotifier<Quote?> {
  final QuoteRepository _repo;
  final QuoteCategory _category;
  String? _lastId;
  CurrentQuoteNotifier(this._repo, this._category) : super(null) {
    _loadInitial();
  }
  void _loadInitial() {
    final quote = _repo.getRandomQuote(category: _category);
    _lastId = quote.id;
    state = quote;
    _repo.addToHistory(quote);
  }
  /// Loads the next random quote, records it in history.
  Future<void> nextQuote({QuoteCategory? category}) async {
    final cat = category ?? _category;
    final quote = _repo.getRandomQuote(excludeId: _lastId, category: cat);
    _lastId = quote.id;
    state = quote;
    await _repo.addToHistory(quote);
  }
  /// Toggles the favorite status of the current quote.
  Future<void> toggleFavorite() async {
    final current = state;
    if (current == null) return;
    if (current.isFavorite) {
      await _repo.removeFavorite(current.id);
    } else {
      await _repo.addFavorite(current);
    }
    state = current.copyWith(isFavorite: !current.isFavorite);
  }
}
// ── Active Category (home filter) ──────────────────────────────────────────────
final activeCategoryProvider =
    StateNotifierProvider<ActiveCategoryNotifier, QuoteCategory>((ref) {
  return ActiveCategoryNotifier();
});
class ActiveCategoryNotifier extends StateNotifier<QuoteCategory> {
  ActiveCategoryNotifier() : super(QuoteCategory.all);
  void set(QuoteCategory cat) => state = cat;
}
// ── All Quotes by Category ──────────────────────────────────────────────────────
final categoryQuotesProvider = Provider.family<List<Quote>, QuoteCategory>(
  (ref, category) {
    final repo = ref.watch(quoteRepositoryProvider);
    return repo.getAllQuotes(category: category);
  },
);
// ── Quote Counts per Category ───────────────────────────────────────────────────
final categoryQuoteCountProvider = Provider<Map<QuoteCategory, int>>((ref) {
  final repo = ref.watch(quoteRepositoryProvider);
  return {
    for (final cat in QuoteCategory.values.where((c) => c != QuoteCategory.all))
      cat: repo.getAllQuotes(category: cat).length,
  };
});
// ═══════════════════════════════════════════════════════════════════════════════
// FAVORITES PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Quote>>((ref) {
  final repo = ref.watch(quoteRepositoryProvider);
  return FavoritesNotifier(repo);
});
class FavoritesNotifier extends StateNotifier<List<Quote>> {
  final QuoteRepository _repo;
  FavoritesNotifier(this._repo) : super(_repo.getFavorites());
  Future<void> toggle(Quote quote) async {
    if (_repo.isFavorite(quote.id)) {
      await _repo.removeFavorite(quote.id);
    } else {
      await _repo.addFavorite(quote);
    }
    state = _repo.getFavorites();
  }
  Future<void> remove(String id) async {
    await _repo.removeFavorite(id);
    state = _repo.getFavorites();
  }
  bool isFavorite(String id) => _repo.isFavorite(id);
}
// ═══════════════════════════════════════════════════════════════════════════════
// HISTORY PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) {
  final repo = ref.watch(quoteRepositoryProvider);
  return HistoryNotifier(repo);
});
class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  final QuoteRepository _repo;
  HistoryNotifier(this._repo) : super(_repo.getHistory());
  void refresh() => state = _repo.getHistory();
  Future<void> clear() async {
    await _repo.clearHistory();
    state = [];
  }
}
// ═══════════════════════════════════════════════════════════════════════════════
// SEARCH PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchResultsProvider = Provider<List<Quote>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(quoteRepositoryProvider);
  return repo.searchQuotes(query);
});
// ═══════════════════════════════════════════════════════════════════════════════
// DAILY QUOTE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════
final dailyQuoteProvider = Provider<Quote>((ref) {
  final repo = ref.watch(quoteRepositoryProvider);
  return repo.getDailyQuote();
});
final streakProvider = StateNotifierProvider<StreakNotifier, int>((ref) {
  final storage = ref.watch(localStorageProvider);
  return StreakNotifier(storage);
});
class StreakNotifier extends StateNotifier<int> {
  final LocalStorageService _storage;
  StreakNotifier(this._storage) : super(_storage.streakCount) {
    _checkAndUpdateStreak();
  }
  void _checkAndUpdateStreak() {
    final today = _todayKey();
    final lastDate = _storage.lastStreakDate;
    final yesterday = _yesterdayKey();
    if (lastDate == today) return; // already updated today
    if (lastDate == yesterday) {
      // Consecutive day — increment
      final newStreak = _storage.streakCount + 1;
      state = newStreak;
      _storage.updateStreak(newStreak, today);
    } else if (lastDate == null) {
      // First time ever
      state = 1;
      _storage.updateStreak(1, today);
    } else {
      // Streak broken — reset
      state = 1;
      _storage.updateStreak(1, today);
    }
  }
  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
  String _yesterdayKey() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
  }
}
// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════
final notifEnabledProvider = StateNotifierProvider<NotifEnabledNotifier, bool>(
  (ref) {
    final storage = ref.watch(localStorageProvider);
    return NotifEnabledNotifier(storage);
  },
);
class NotifEnabledNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;
  NotifEnabledNotifier(this._storage) : super(_storage.dailyNotifEnabled);
  Future<void> toggle() async {
    final newVal = !state;
    await _storage.setNotifEnabled(newVal);
    state = newVal;
  }
}