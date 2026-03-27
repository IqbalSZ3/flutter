import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/animated_scale_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildBalanceCard(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuickStats(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context.tr('upcoming_payments'), onSeeAll: () {}, seeAllLabel: context.tr('see_all')),
                    const SizedBox(height: AppSpacing.sm),
                    _buildEmptyState(
                      icon: Icons.credit_card_rounded,
                      text: context.tr('no_upcoming_payments'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context.tr('recent_transactions'),
                        onSeeAll: () => context.push('/transactions'), seeAllLabel: context.tr('see_all')),
                    const SizedBox(height: AppSpacing.sm),
                    _buildRecentTransactions(context),
                  ].animate(interval: 50.ms).fade(duration: 400.ms, curve: Curves.easeOutCubic).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: user?.photoURL != null
                  ? CachedNetworkImageProvider(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(context),
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    user?.displayName ?? 'User',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('greeting_morning');
    if (hour < 17) return context.tr('greeting_afternoon');
    return context.tr('greeting_evening');
  }

  Widget _buildBalanceCard(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final balance =
            state is TransactionLoaded ? state.balance : 0;
        final income =
            state is TransactionLoaded ? state.totalIncome : 0;
        final expense =
            state is TransactionLoaded ? state.totalExpense : 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.divider, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('total_balance'),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                CurrencyFormatter.format(balance),
                style: AppTypography.amountLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Thin divider between balance and stats
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _buildBalanceStat(
                      context.tr('income'), income, Icons.arrow_downward_rounded),
                  const SizedBox(width: AppSpacing.lg),
                  _buildBalanceStat(
                      context.tr('expense'), expense, Icons.arrow_upward_rounded),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceStat(String label, int amount, IconData icon) {
    final isIncome = icon == Icons.arrow_downward_rounded;
    final accentColor = isIncome ? AppColors.income : AppColors.expense;
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: AppTypography.amountSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
            context.tr('savings'), '0%', Icons.savings_rounded, AppColors.income),
        const SizedBox(width: AppSpacing.md),
        _buildStatCard(
            context.tr('bills_due'), '0', Icons.calendar_today_rounded, AppColors.warning),
        const SizedBox(width: AppSpacing.md),
        _buildStatCard(
            context.tr('subs'), '0', Icons.subscriptions_rounded, AppColors.info),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.amountSmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required VoidCallback onSeeAll, required String seeAllLabel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            seeAllLabel,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return Column(
            children: List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Shimmer.fromColors(
                baseColor: AppColors.surfaceMuted,
                highlightColor: AppColors.surface,
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            )),
          );
        }
        if (state is TransactionLoaded && state.transactions.isNotEmpty) {
          final recent = state.transactions.take(5).toList();
          return Column(
            children: recent
                .map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _RecentTransactionTile(transaction: t),
                    ))
                .toList(),
          );
        }
        return _buildEmptyState(
          icon: Icons.receipt_long_rounded,
          text: context.tr('no_transactions_yet'),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const _RecentTransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;

    return AnimatedScaleButton(
      onTap: () {}, // Add touch feedback
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              transaction.categoryName,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.formatSigned(
                transaction.amount, isExpense: isExpense),
            style: AppTypography.amountSmall.copyWith(
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
