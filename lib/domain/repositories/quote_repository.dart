// lib/domain/repositories/quote_repository.dart
import '../entities/quote.dart';
import '../entities/quote_category.dart';
/// Abstract contract that the data layer must fulfil.
/// The domain layer depends only on this interface — never on concrete classes.
abstract class QuoteRepository {
  // ── Quote Retrieval ─────────────────────────────────────────────────────────
  /// Returns all quotes, optionally filtered by [category].
  List<Quote> getAllQuotes({QuoteCategory? category});
  /// Returns a single random quote, optionally excluding [excludeId].
  Quote getRandomQuote({String? excludeId, QuoteCategory? category});
  /// Returns the deterministic "Quote of the Day" based on the current date.
  Quote getDailyQuote();
  /// Searches quotes matching [query] across text, author, and category.
  List<Quote> searchQuotes(String query);
  // ── Favorites ───────────────────────────────────────────────────────────────
  /// Returns all favorited quotes.
  List<Quote> getFavorites();
  /// Adds a quote to favorites (persisted locally).
  Future<void> addFavorite(Quote quote);
  /// Removes a quote from favorites.
  Future<void> removeFavorite(String quoteId);
  /// Returns whether a quote is currently favorited.
  bool isFavorite(String quoteId);
  // ── History ─────────────────────────────────────────────────────────────────
  /// Returns the last 20 viewed quotes with timestamps.
  List<HistoryEntry> getHistory();
  /// Records that a quote was viewed.
  Future<void> addToHistory(Quote quote);
  /// Clears all history.
  Future<void> clearHistory();
}
/// A viewed-quote record with a timestamp.
class HistoryEntry {
  final Quote quote;
  final DateTime viewedAt;
  const HistoryEntry({required this.quote, required this.viewedAt});
}
