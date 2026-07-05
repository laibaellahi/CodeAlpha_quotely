// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/quote_category.dart';
import '../../providers/provider.dart';
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIdx = ref.watch(themeModeProvider);
    final fontIdx = ref.watch(fontSizeProvider);
    final prefCat = ref.watch(preferredCategoryProvider);
    final notifEnabled = ref.watch(notifEnabledProvider);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(AppStrings.settings,
                  style: theme.textTheme.headlineMedium),
            ).animate().fadeIn(duration: 400.ms),
            // ── Appearance ──────────────────────────────────────────────────
            _SectionHeader(title: AppStrings.appearance),
            // Theme
            _SettingsTile(
              icon: Icons.palette_rounded,
              iconColor: AppColors.primary,
              title: AppStrings.themeMode,
              subtitle: _themeLabels[themeIdx],
              trailing: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Auto')),
                  ButtonSegment(value: 1, icon: Icon(Icons.light_mode_rounded)),
                  ButtonSegment(value: 2, icon: Icon(Icons.dark_mode_rounded)),
                ],
                selected: {themeIdx},
                onSelectionChanged: (vals) {
                  ref.read(themeModeProvider.notifier).setMode(vals.first);
                },
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all(
                      const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                ),
              ),
            ),
            // Font Size
            _SettingsTile(
              icon: Icons.text_fields_rounded,
              iconColor: AppColors.secondary,
              title: AppStrings.fontSize,
              subtitle: _fontLabels[fontIdx],
              trailing: null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Slider(
                    value: fontIdx.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    activeColor: AppColors.primary,
                    label: _fontLabels[fontIdx],
                    onChanged: (val) {
                      ref
                          .read(fontSizeProvider.notifier)
                          .setSize(val.round());
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _fontLabels.map((l) {
                        return Text(l,
                            style: theme.textTheme.labelSmall);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Preferences ─────────────────────────────────────────────────
            _SectionHeader(title: 'Preferences'),
            // Preferred Category
            _SettingsTile(
              icon: Icons.category_rounded,
              iconColor: AppColors.accent,
              title: AppStrings.preferredCategory,
              subtitle: prefCat.displayName,
              onTap: () => _showCategoryPicker(context, ref, prefCat),
            ),
            // ── Notifications ────────────────────────────────────────────────
            _SectionHeader(title: AppStrings.notifications),
            _SettingsTile(
              icon: Icons.notifications_rounded,
              iconColor: AppColors.success,
              title: AppStrings.dailyNotification,
              subtitle: AppStrings.dailyNotificationDesc,
              trailing: Switch(
                value: notifEnabled,
                onChanged: (_) =>
                    ref.read(notifEnabledProvider.notifier).toggle(),
                activeColor: AppColors.primary,
              ),
            ),
            // ── About ────────────────────────────────────────────────────────
            _SectionHeader(title: 'About'),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.primary,
              title: 'Quotely',
              subtitle: 'Version 1.0.0 • Made with ❤️ in Flutter',
            ),
            _SettingsTile(
              icon: Icons.format_quote_rounded,
              iconColor: AppColors.secondary,
              title: 'Total Quotes',
              subtitle: '${_totalQuotes(ref)} inspiring quotes',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  int _totalQuotes(WidgetRef ref) {
    return ref.read(quoteRepositoryProvider).getAllQuotes().length;
  }
  static const _themeLabels = ['System Default', 'Light', 'Dark'];
  static const _fontLabels = ['Small', 'Medium', 'Large', 'XL'];
  Future<void> _showCategoryPicker(
    BuildContext context,
    WidgetRef ref,
    QuoteCategory current,
  ) async {
    final categories = QuoteCategory.values.toList();
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text('Select Category',
                  style: Theme.of(ctx).textTheme.titleLarge),
            ),
            ...categories.map((cat) => RadioListTile<QuoteCategory>(
                  value: cat,
                  groupValue: current,
                  title: Text(
                    '${cat.emoji}  ${cat.displayName}',
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(preferredCategoryProvider.notifier)
                          .setCategory(val);
                      Navigator.pop(ctx);
                    }
                  },
                  activeColor: AppColors.primary,
                )),
          ],
        ),
      ),
    );
  }
}
// ── Settings Widgets ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall,
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color:
                      theme.colorScheme.onSurface.withOpacity(0.4))
              : null),
      onTap: onTap,
    );
  }
}