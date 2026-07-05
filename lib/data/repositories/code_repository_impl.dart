// lib/data/repositories/quote_repository_impl.dart
//
// Concrete implementation of [QuoteRepository].
// Combines the static quotes dataset with Hive/SharedPreferences storage.
import 'dart:convert';
import 'dart:math';
import '../../domain/entities/quote.dart';
import '../../domain/entities/quote_category.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/local/local_storage_service.dart';
import '../datasources/local/quote_data.dart';
class QuoteRepositoryImpl implements QuoteRepository {
  final LocalStorageService _storage;
  final Random _rng = Random();
  /// In-memory list populated once from the static dataset.
  late final List<Quote> _allQuotes;
  QuoteRepositoryImpl(this._storage) {
    _allQuotes = kQuotesRaw.map(_mapToQuote).toList();
  }
  // ── Mapping ────────────────────────────────────────────────────────────────
  Quote _mapToQuote(Map<String, String> raw) {
    return Quote(
      id: raw['id']!,
      text: raw['text']!,
      author: raw['author']!.isEmpty ? 'Unknown' : raw['author']!,
      category: raw['category']!,
      isFavorite: _storage.isFavorite(raw['id']!),
    );
  }
  // ── QuoteRepository ────────────────────────────────────────────────────────
  @override
  List<Quote> getAllQuotes({QuoteCategory? category}) {
    if (category == null || category == QuoteCategory.all) {
      return List.unmodifiable(_allQuotes);
    }
    return _allQuotes
        .where((q) => q.category == category.key)
        .toList(growable: false);
  }
  @override
  Quote getRandomQuote({String? excludeId, QuoteCategory? category}) {
    final pool = getAllQuotes(category: category);
    if (pool.isEmpty) return _allQuotes[_rng.nextInt(_allQuotes.length)];
    // Filter out the previously shown quote to avoid immediate repeats.
    final candidates = excludeId != null && pool.length > 1
        ? pool.where((q) => q.id != excludeId).toList()
        : pool;
    final quote = candidates[_rng.nextInt(candidates.length)];
    return quote.copyWith(isFavorite: _storage.isFavorite(quote.id));
  }
  @override
  Quote getDailyQuote() {
    final today = _todayKey();
    final storedDate = _storage.dailyQuoteDate;
    final storedId = _storage.dailyQuoteId;
    if (storedDate == today && storedId != null) {
      final found = _allQuotes.where((q) => q.id == storedId).toList();
      if (found.isNotEmpty) {
        return found.first.copyWith(isFavorite: _storage.isFavorite(storedId));
      }
    }
    // Pick a deterministic quote based on the day number.
    final dayNumber = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final quote = _allQuotes[dayNumber % _allQuotes.length];
    _storage.setDailyQuote(today, quote.id);
    return quote.copyWith(isFavorite: _storage.isFavorite(quote.id));
  }
  @override
  List<Quote> searchQuotes(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return _allQuotes.where((quote) {
      return quote.text.toLowerCase().contains(q) ||
          quote.author.toLowerCase().contains(q) ||
          quote.category.toLowerCase().contains(q);
    }).toList(growable: false);
  }
  // ── Favorites ──────────────────────────────────────────────────────────────
  @override
  List<Quote> getFavorites() {
    final jsons = _storage.getAllFavoriteJsons();
    return jsons.map((j) {
      final map = jsonDecode(j) as Map<String, dynamic>;
      return Quote(
        id: map['id'] as String,
        text: map['text'] as String,
        author: map['author'] as String,
        category: map['category'] as String,
        isFavorite: true,
      );
    }).toList();
  }
  @override
  Future<void> addFavorite(Quote quote) async {
    await _storage.addFavorite(quote.id, {
      'id': quote.id,
      'text': quote.text,
      'author': quote.author,
      'category': quote.category,
    });
    // Update in-memory flag
    final idx = _allQuotes.indexWhere((q) => q.id == quote.id);
    if (idx != -1) _allQuotes[idx].isFavorite = true;
  }
  @override
  Future<void> removeFavorite(String quoteId) async {
    await _storage.removeFavorite(quoteId);
    final idx = _allQuotes.indexWhere((q) => q.id == quoteId);
    if (idx != -1) _allQuotes[idx].isFavorite = false;
  }
  @override
  bool isFavorite(String quoteId) => _storage.isFavorite(quoteId);
  // ── History ────────────────────────────────────────────────────────────────
  @override
  List<HistoryEntry> getHistory() {
    final jsons = _storage.getAllHistoryJsons();
    return jsons.map((j) {
      final map = jsonDecode(j) as Map<String, dynamic>;
      return HistoryEntry(
        quote: Quote(
          id: map['id'] as String,
          text: map['text'] as String,
          author: map['author'] as String,
          category: map['category'] as String,
          isFavorite: _storage.isFavorite(map['id'] as String),
        ),
        viewedAt: DateTime.parse(map['viewedAt'] as String),
      );
    }).toList();
  }
  @override
  Future<void> addToHistory(Quote quote) async {
    final key = '${quote.id}_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.addHistory(key, {
      'id': quote.id,
      'text': quote.text,
      'author': quote.author,
      'category': quote.category,
      'viewedAt': DateTime.now().toIso8601String(),
    });
  }
  @override
  Future<void> clearHistory() => _storage.clearHistory();
  // ── Private helpers ────────────────────────────────────────────────────────
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}