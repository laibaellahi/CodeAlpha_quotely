// lib/core/widgets/action_bar.dart
//
// Bottom action bar: Copy, Share, Favorite.
// Extracted as a reusable widget used on Home and detail views.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/quote.dart';
class ActionBar extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  const ActionBar({
    super.key,
    required this.quote,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.copy_rounded,
          label: AppStrings.copy,
          onTap: () => _onCopy(context),
        ),
        _ActionButton(
          icon: Icons.share_rounded,
          label: AppStrings.share,
          onTap: _onShare,
        ),
        _ActionButton(
          icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: isFavorite ? 'Saved' : AppStrings.favorite,
          color: isFavorite ? AppColors.error : null,
          onTap: onFavoriteToggle,
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 400.ms);
  }
  Future<void> _onCopy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: quote.clipboardText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(AppStrings.copied),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  Future<void> _onShare() async {
    await Share.share(quote.shareText, subject: 'Inspiring Quote from Quotely');
  }
}
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: effectiveColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
