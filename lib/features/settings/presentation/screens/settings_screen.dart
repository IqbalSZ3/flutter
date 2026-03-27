import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/export_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('settings'),
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildProfileCard(context),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionTitle(context.tr('general')),
          BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) => _buildSettingsTile(
              icon: Icons.language_rounded,
              title: context.tr('language'),
              subtitle: locale.languageCode == 'id' ? 'Bahasa Indonesia' : 'English',
              onTap: () => _showLanguageDialog(context),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.category_rounded,
            title: context.tr('categories'),
            subtitle: context.tr('manage_categories'),
            onTap: () => context.push(AppRoutes.manageCategories),
          ),
          _buildSettingsTile(
            icon: Icons.savings_rounded,
            title: context.tr('savings_goals'),
            subtitle: context.tr('savings_goals_subtitle'),
            onTap: () => context.push(AppRoutes.savingsGoals),
          ),
          _buildSettingsTile(
            icon: Icons.download_rounded,
            title: context.tr('export_data'),
            subtitle: context.tr('export_data_subtitle'),
            onTap: () async {
              final state = context.read<TransactionBloc>().state;
              if (state is TransactionLoaded) {
                await ExportService.exportTransactionsToCSV(context, state.transactions);
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionTitle(context.tr('account')),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: context.tr('sign_out'),
            subtitle: context.tr('sign_out_subtitle'),
            iconColor: AppColors.expense,
            onTap: () => _showSignOutConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLocale = context.read<LocaleCubit>().state.languageCode;
    String selected = currentLocale;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(context.tr('language'),
              style: AppTypography.textTheme.titleLarge
                  ?.copyWith(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'en',
                // ignore: deprecated_member_use
                groupValue: selected,
                activeColor: AppColors.primary,
                title: Text('English',
                    style: AppTypography.textTheme.bodyLarge
                        ?.copyWith(color: AppColors.textPrimary)),
                // ignore: deprecated_member_use
                onChanged: (v) => setState(() => selected = v!),
              ),
              RadioListTile<String>(
                value: 'id',
                // ignore: deprecated_member_use
                groupValue: selected,
                activeColor: AppColors.primary,
                title: Text('Bahasa Indonesia',
                    style: AppTypography.textTheme.bodyLarge
                        ?.copyWith(color: AppColors.textPrimary)),
                // ignore: deprecated_member_use
                onChanged: (v) => setState(() => selected = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel'),
                  style: TextStyle(color: AppColors.textTertiary)),
            ),
            FilledButton(
              onPressed: () {
                context.read<LocaleCubit>().setLocale(selected);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(selected == 'en'
                        ? context.tr('language_set_en')
                        : context.tr('language_set_id')),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }


  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.tr('sign_out'),
            style: AppTypography.textTheme.titleLarge
                ?.copyWith(color: AppColors.textPrimary)),
        content: Text(
          context.tr('sign_out_confirm'),
          style: AppTypography.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel'),
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            child: Text(context.tr('sign_out')),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                backgroundImage: user?.photoURL != null
                    ? CachedNetworkImageProvider(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person,
                        color: AppColors.primary, size: 28)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? context.tr('user'),
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.textTheme.titleSmall?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
