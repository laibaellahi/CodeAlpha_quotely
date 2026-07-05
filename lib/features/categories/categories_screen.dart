// lib/features/categories/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/quote_category.dart';
import '../../providers/provider.dart';
import '../../domain/entities/quote.dart';
//import '../../core/widgets/action_bar.dart';
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(categoryQuoteCountProvider);
    final categories =
        QuoteCategory.values.where((c) => c != QuoteCategory.all).toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(AppStrings.browseCategories,
                  style: Theme.of(context).textTheme.headlineMedium),
            ).animate().fadeIn(duration: 400.ms),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  return _CategoryCard(
                    category: cat,
                    count: counts[cat] ?? 0,
                    gradientIndex: i,
                  )
                      .animate(delay: Duration(milliseconds: i * 60))
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.85, 0.85));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _CategoryCard extends StatelessWidget {
  final QuoteCategory category;
  final int count;
  final int gradientIndex;
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.gradientIndex,
  });
  @override
  Widget build(BuildContext context) {
    final gradient =
        AppColors.cardGradients[gradientIndex % AppColors.cardGradients.length];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailScreen(category: category),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.emoji,
                  style: const TextStyle(fontSize: 32)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count quotes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ── Category Detail Screen ────────────────────────────────────────────────────
class CategoryDetailScreen extends ConsumerWidget {
  final QuoteCategory category;
  const CategoryDetailScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(categoryQuotesProvider(category));
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.emoji} ${category.displayName}'),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: quotes.length,
        itemBuilder: (ctx, i) {
          final quote = quotes[i];
          final isFav = ref.watch(favoritesProvider.notifier).isFavorite(quote.id);
          return _QuoteTile(quote: quote, isFav: isFav)
              .animate(delay: Duration(milliseconds: i * 40))
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }
}
class _QuoteTile extends ConsumerWidget {
  final Quote quote;
  final bool isFav;
  const _QuoteTile({required this.quote, required this.isFav});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${quote.text}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'PlayfairDisplay',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('— ${quote.author}',
                      style: theme.textTheme.bodySmall),
                ),
                IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.error : null,
                  ),
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(quote),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
