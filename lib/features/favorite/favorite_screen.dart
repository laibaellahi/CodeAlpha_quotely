// lib/features/favorites/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/action_bar.dart';
import '../../providers/provider.dart';
import '../../domain/entities/quote.dart';
import '../../core/constants/app_colors.dart';
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                AppStrings.favorites,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
            // Content
            Expanded(
              child: favorites.isEmpty
                  ? _EmptyFavorites()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: favorites.length,
                      itemBuilder: (ctx, i) {
                        return _FavoriteQuoteTile(quote: favorites[i])
                            .animate(delay: Duration(milliseconds: i * 60))
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.1, end: 0, duration: 400.ms);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
class _FavoriteQuoteTile extends ConsumerWidget {
  final Quote quote;
  const _FavoriteQuoteTile({required this.quote});
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
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                quote.category[0].toUpperCase() + quote.category.substring(1),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Quote text
            Text(
              '"${quote.text}"',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            // Author
            Text(
              '— ${quote.author}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 24),
            // Actions
            ActionBar(
              quote: quote,
              isFavorite: true,
              onFavoriteToggle: () {
                ref.read(favoritesProvider.notifier).remove(quote.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 72,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noFavorites,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noFavoritesHint,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}
