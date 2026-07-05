// lib/core/widgets/quote_card.dart
//
// The centrepiece widget of Quotely — a premium animated quote card with
// gradient background, smooth AnimatedSwitcher transitions, and swipe support.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/quote.dart';
class QuoteCard extends StatelessWidget {
  final Quote quote;
  final double quoteFontSize;
  final int gradientIndex;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  const QuoteCard({
    super.key,
    required this.quote,
    required this.quoteFontSize,
    required this.gradientIndex,
    this.onSwipeLeft,
    this.onSwipeRight,
  });
  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.cardGradients[
        gradientIndex % AppColors.cardGradients.length];
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -300) {
            onSwipeLeft?.call(); // swipe left → next
          } else if (details.primaryVelocity! > 300) {
            onSwipeRight?.call(); // swipe right → previous
          }
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Decorative quotation mark ──────────────────────────────────
            Positioned(
              top: 16,
              left: 24,
              child: Text(
                '"',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 100,
                  height: 1,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            // ── Content ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote text
                  Text(
                    quote.text,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: quoteFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Container(
                    width: 40,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Author
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '— ${quote.author}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Category chip
                  _CategoryChip(category: quote.category),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        category[0].toUpperCase() + category.substring(1),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
