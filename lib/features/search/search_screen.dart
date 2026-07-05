// lib/features/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
//import '../../core/widgets/action_bar.dart';
import '../../providers/provider.dart';
import '../../domain/entities/quote.dart';
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Text(
                AppStrings.search,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ).animate().fadeIn(duration: 400.ms),
            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                autofocus: false,
                onChanged: (val) =>
                    ref.read(searchQueryProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _controller.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 8),
            // Results
            Expanded(
              child: query.isEmpty
                  ? _EmptySearch()
                  : results.isEmpty
                      ? _NoResults(query: query)
                      : _ResultsList(results: results),
            ),
          ],
        ),
      ),
    );
  }
}
class _ResultsList extends ConsumerWidget {
  final List<Quote> results;
  const _ResultsList({required this.results});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        final quote = results[i];
        final isFav = ref.watch(favoritesProvider.notifier).isFavorite(quote.id);
        return _SearchResultTile(quote: quote, isFav: isFav)
            .animate(delay: Duration(milliseconds: i * 50))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.08, end: 0);
      },
    );
  }
}
class _SearchResultTile extends ConsumerWidget {
  final Quote quote;
  final bool isFav;
  const _SearchResultTile({required this.quote, required this.isFav});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quote.category[0].toUpperCase() + quote.category.substring(1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => ref.read(favoritesProvider.notifier).toggle(quote),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.error : theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '"${quote.text}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'PlayfairDisplay',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '— ${quote.author}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded,
              size: 72, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(AppStrings.searchPlaceholder,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}
class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied_rounded,
              size: 72, color: AppColors.accent.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(AppStrings.noResults,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('No quotes found for "$query"',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}
