import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/savings_goal_model.dart';
import '../bloc/savings_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/animated_scale_button.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('savings_goals'),
          style: AppTypography.textTheme.headlineSmall
              ?.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-savings-goal'),
        backgroundColor: AppColors.warning,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          context.tr('add_savings_goal'),
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<SavingsBloc, SavingsState>(
        builder: (context, state) {
          if (state is SavingsLoading) {
            return _buildShimmerList();
          }
          if (state is SavingsLoaded) {
            if (state.goals.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildList(context, state);
          }
          return _buildEmpty(context);
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border:
                    Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.savings_outlined,
                  size: 40, color: AppColors.warning),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.tr('no_savings_goals'),
              style: AppTypography.textTheme.titleMedium
                  ?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.tr('no_savings_goals_subtitle'),
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, SavingsLoaded state) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        // Summary card
        _buildSummaryCard(context, state)
            .animate().fade(duration: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: AppSpacing.lg),

        // Active goals
        if (state.active.isNotEmpty) ...[
          _buildSectionHeader(context, context.tr('active_goals'),
              state.active.length)
              .animate().fade().slideX(begin: 0.05),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(state.active.length, (i) {
            return _GoalCard(goal: state.active[i])
                .animate(delay: (i * 50).ms).fade().slideY(begin: 0.1);
          }),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Completed goals
        if (state.completed.isNotEmpty) ...[
          _buildSectionHeader(context, context.tr('completed_goals'),
              state.completed.length)
              .animate().fade().slideX(begin: 0.05),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(state.completed.length, (i) {
            return _GoalCard(goal: state.completed[i])
                .animate(delay: (i * 50).ms).fade().slideY(begin: 0.1);
          }),
        ],
        // FAB clearance
        const SizedBox(height: 88),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, SavingsLoaded state) {
    final totalTarget = state.goals
        .fold<int>(0, (sum, g) => sum + g.targetAmount);
    final totalSaved = state.goals
        .fold<int>(0, (sum, g) => sum + g.currentAmount);
    final overallProgress =
        totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr('savings_overview'),
                style: AppTypography.textTheme.labelLarge
                    ?.copyWith(color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  context.tr('total_saved'),
                  CurrencyFormatter.formatCompact(totalSaved),
                  AppColors.income,
                ),
              ),
              Container(
                  width: 1, height: 40, color: AppColors.divider),
              Expanded(
                child: _summaryItem(
                  context.tr('total_target'),
                  CurrencyFormatter.formatCompact(totalTarget),
                  AppColors.textSecondary,
                ),
              ),
              Container(
                  width: 1, height: 40, color: AppColors.divider),
              Expanded(
                child: _summaryItem(
                  context.tr('goals_count'),
                  '${state.active.length} ${context.tr('active')}',
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: overallProgress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppColors.surfaceElevated,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.warning),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(overallProgress * 100).toStringAsFixed(0)}% ${context.tr('of_target')}',
            style: AppTypography.textTheme.labelSmall
                ?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.textTheme.labelSmall
              ?.copyWith(color: AppColors.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTypography.textTheme.labelLarge
              ?.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius:
                BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            '$count',
            style: AppTypography.textTheme.labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoalModel goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final percent = (goal.progress * 100).toStringAsFixed(0);

    return AnimatedScaleButton(
      onTap: () => context.push('/savings-goal-detail', extra: goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: goal.isCompleted
                ? AppColors.income.withValues(alpha: 0.3)
                : AppColors.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Goal icon badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: goal.isCompleted
                        ? AppColors.income.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    goal.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.savings_rounded,
                    size: 20,
                    color: goal.isCompleted
                        ? AppColors.income
                        : AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: AppTypography.textTheme.titleSmall
                            ?.copyWith(color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _periodLabel(context, goal.period),
                        style: AppTypography.textTheme.labelSmall
                            ?.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percent%',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: goal.isCompleted
                            ? AppColors.income
                            : AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatCompact(goal.currentAmount),
                      style: AppTypography.textTheme.labelSmall
                          ?.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: goal.progress),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation(
                    goal.isCompleted ? AppColors.income : AppColors.warning,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CurrencyFormatter.formatCompact(goal.currentAmount)} / ${CurrencyFormatter.formatCompact(goal.targetAmount)}',
                  style: AppTypography.textTheme.labelSmall
                      ?.copyWith(color: AppColors.textTertiary),
                ),
                Text(
                  goal.isCompleted
                      ? context.tr('completed')
                      : '${context.tr('remaining')}: ${CurrencyFormatter.formatCompact(goal.remaining)}',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: goal.isCompleted
                        ? AppColors.income
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(BuildContext context, SavingsPeriod period) {
    switch (period) {
      case SavingsPeriod.weekly:
        return context.tr('period_weekly');
      case SavingsPeriod.monthly:
        return context.tr('period_monthly');
      case SavingsPeriod.yearly:
        return context.tr('period_yearly');
      case SavingsPeriod.custom:
        return context.tr('period_custom');
    }
  }
}

Widget _buildShimmerList() {
  return ListView.separated(
    padding: const EdgeInsets.all(AppSpacing.md),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
    itemBuilder: (_, _) => Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    ),
  );
}
