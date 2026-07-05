// lib/features/home/home_screen.dart
//
// The main hub of Quotely. Shows a random quote with swipe gestures,
// category filter chips, and the "Inspire Me" action button.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/quote_card.dart';
import '../../core/widgets/action_bar.dart';
import '../../domain/entities/quote_category.dart';
import '../../providers/provider.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _gradientIndex = 0;
  final _rng = Random();
  Key _cardKey = UniqueKey();
  void _loadNextQuote() async {
    final cat = ref.read(activeCategoryProvider);
    await ref.read(currentQuoteProvider.notifier).nextQuote(category: cat);
    setState(() {
      _gradientIndex = _rng.nextInt(AppColors.cardGradients.length);
      _cardKey = UniqueKey();
    });
    // Refresh history after showing new quote
    ref.read(historyProvider.notifier).refresh();
  }
  @override
  Widget build(BuildContext context) {
    final quote = ref.watch(currentQuoteProvider);
    final isFav =
      ref.watch(favoritesProvider.notifier).isFavorite(quote?.id ?? '');

  final fontSize =
      ref.watch(fontSizeProvider.notifier).quoteTextSize;

  final activeCategory = ref.watch(activeCategoryProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            _buildHeader(context),
            // ── Category Chips ──────────────────────────────────────────────
            _buildCategoryChips(activeCategory),
            const SizedBox(height: 8),
            // ── Quote Card ──────────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: quote == null
                    ? const _LoadingCard()
                    : Column(
                        key: _cardKey,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: QuoteCard(
                                quote: quote,
                                quoteFontSize: fontSize,
                                gradientIndex: _gradientIndex,
                                onSwipeLeft: _loadNextQuote,
                                onSwipeRight: _loadNextQuote,
                              ),
                            ),
                          ),
                          // ── Action Bar ────────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: ActionBar(
                              quote: quote,
                              isFavorite: isFav,
                              onFavoriteToggle: () {
                                ref
                                    .read(currentQuoteProvider.notifier)
                                    .toggleFavorite();
                                ref.invalidate(favoritesProvider);
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // ── Swipe hint ────────────────────────────────────────────────
            _buildSwipeHint(context),
            const SizedBox(height: 8),
            // ── Inspire Me Button ─────────────────────────────────────────
            _buildInspireMeButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                AppStrings.tagline,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          // Streak badge
          _StreakBadge(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0, duration: 500.ms);
  }
  Widget _buildCategoryChips(QuoteCategory activeCategory) {
    final categories = QuoteCategory.values;
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isActive = cat == activeCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                selected: isActive,
                label: Text('${cat.emoji} ${cat.displayName}'),
                onSelected: (_) {
                  ref.read(activeCategoryProvider.notifier).set(cat);
                  _loadNextQuote();
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: AppColors.primary.withOpacity(0.15),
                checkmarkColor: AppColors.primary,
                side: BorderSide(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primary : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildSwipeHint(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swipe_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(width: 6),
          Text(
            AppStrings.swipeHint,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }
  Widget _buildInspireMeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _loadNextQuote,
          icon: const Icon(Icons.auto_awesome_rounded, size: 20),
          label: const Text(AppStrings.inspireMe),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}
// ── Loading placeholder ──────────────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
// ── Streak Badge ─────────────────────────────────────────────────────────────
class _StreakBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    if (streak == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}