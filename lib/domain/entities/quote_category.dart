// lib/domain/entities/quote_category.dart
/// Enum representing all supported quote categories.
enum QuoteCategory {
  all,
  motivation,
  success,
  happiness,
  life,
  love,
  friendship,
  leadership,
  education,
  programming,
  business,
  health,
  stoicism,
  islamic;
  /// Display name shown in the UI.
  String get displayName {
    switch (this) {
      case QuoteCategory.all:
        return 'All';
      case QuoteCategory.motivation:
        return 'Motivation';
      case QuoteCategory.success:
        return 'Success';
      case QuoteCategory.happiness:
        return 'Happiness';
      case QuoteCategory.life:
        return 'Life';
      case QuoteCategory.love:
        return 'Love';
      case QuoteCategory.friendship:
        return 'Friendship';
      case QuoteCategory.leadership:
        return 'Leadership';
      case QuoteCategory.education:
        return 'Education';
      case QuoteCategory.programming:
        return 'Programming';
      case QuoteCategory.business:
        return 'Business';
      case QuoteCategory.health:
        return 'Health';
      case QuoteCategory.stoicism:
        return 'Stoicism';
      case QuoteCategory.islamic:
        return 'Islamic Quotes';
    }
  }
  /// Emoji icon for the category.
  String get emoji {
    switch (this) {
      case QuoteCategory.all:
        return '✨';
      case QuoteCategory.motivation:
        return '🔥';
      case QuoteCategory.success:
        return '🏆';
      case QuoteCategory.happiness:
        return '😊';
      case QuoteCategory.life:
        return '🌿';
      case QuoteCategory.love:
        return '❤️';
      case QuoteCategory.friendship:
        return '🤝';
      case QuoteCategory.leadership:
        return '👑';
      case QuoteCategory.education:
        return '📚';
      case QuoteCategory.programming:
        return '💻';
      case QuoteCategory.business:
        return '💼';
      case QuoteCategory.health:
        return '💪';
      case QuoteCategory.stoicism:
        return '🏛️';
      case QuoteCategory.islamic:
        return '🌙';
    }
  }
  /// Key used for storage matching with quote data.
  String get key => name;
  /// Parse from stored string key.
  static QuoteCategory fromKey(String key) {
    return QuoteCategory.values.firstWhere(
      (c) => c.key == key,
      orElse: () => QuoteCategory.all,
    );
  }
}