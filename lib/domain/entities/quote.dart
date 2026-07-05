// lib/domain/entities/quote.dart
/// Pure domain entity — no framework or database annotations.
/// Represents a single quote in the application's core business logic.
class Quote {
  final String id;
  final String text;
  final String author;
  final String category;
  bool isFavorite;
  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    this.isFavorite = false,
  });
  /// Returns a copy of this quote with optionally overridden fields.
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? category,
    bool? isFavorite,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  /// Share-ready formatted string: "Quote Text" — Author
  String get shareText => '"$text"\n\n— $author\n\nShared via Quotely ✨';
  /// Clipboard-ready formatted string
  String get clipboardText => '"$text" — $author';
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Quote && other.id == id);
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'Quote(id: $id, author: $author, category: $category)';
}