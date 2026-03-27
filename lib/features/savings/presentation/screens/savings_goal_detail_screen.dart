import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/savings_goal_model.dart';
import '../bloc/savings_bloc.dart';

class SavingsGoalDetailScreen extends StatelessWidget {
  final SavingsGoalModel goal;

  const SavingsGoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    // Listen for updates from BLoC so progress refreshes after top-up
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        // Use updated goal from BLoC if available
        SavingsGoalModel current = goal;
        if (state is SavingsLoaded) {
          final updated =
              state.goals.where((g) => g.id == goal.id).toList();
          if (updated.isNotEmpty) current = updated.first;
        }
        return _buildScaffold(context, current);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, SavingsGoalModel goal) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          goal.name,
          style: AppTypography.textTheme.headlineSmall
              ?.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.expense),
            onPressed: () => _confirmDelete(context, goal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero progress card
            _buildProgressCard(context, goal, daysLeft),
            const SizedBox(height: AppSpacing.lg),

            // Stats row
            _buildStatsRow(context, goal, daysLeft),
            const SizedBox(height: AppSpacing.lg),

            // Add money button (only if not completed)
            if (!goal.isCompleted) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _showTopUpSheet(context, goal),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.tr('add_savings')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: AppColors.background,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Status chip
            if (goal.isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.income.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                      color: AppColors.income.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.income, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('goal_completed_congrats'),
                      style: AppTypography.textTheme.titleSmall
                          ?.copyWith(color: AppColors.income),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
      BuildContext context, SavingsGoalModel goal, int daysLeft) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: goal.isCompleted
              ? AppColors.income.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Amount saved
          Text(
            context.tr('amount_saved'),
            style: AppTypography.textTheme.bodySmall
                ?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(goal.currentAmount),
            style: AppTypography.amountLarge.copyWith(
              color: goal.isCompleted
                  ? AppColors.income
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${context.tr('of')} ${CurrencyFormatter.format(goal.targetAmount)}',
            style: AppTypography.textTheme.bodySmall
                ?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress bar with animation
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: goal.progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
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
                '${(goal.progress * 100).toStringAsFixed(1)}%',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: goal.isCompleted
                      ? AppColors.income
                      : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                goal.isCompleted
                    ? context.tr('completed')
                    : '${context.tr('remaining')}: ${CurrencyFormatter.formatCompact(goal.remaining)}',
                style: AppTypography.textTheme.labelSmall
                    ?.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      BuildContext context, SavingsGoalModel goal, int daysLeft) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _infoRow(
            context.tr('target_date'),
            '${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
          ),
          _divider(),
          _infoRow(
            context.tr('days_left'),
            daysLeft > 0
                ? '$daysLeft ${context.tr('days')}'
                : context.tr('deadline_passed'),
            valueColor:
                daysLeft > 30 ? null : AppColors.expense,
          ),
          _divider(),
          _infoRow(
            context.tr('save_per_period'),
            CurrencyFormatter.format(goal.suggestedPeriodicAmount),
            valueColor: AppColors.warning,
          ),
          _divider(),
          _infoRow(
            context.tr('saving_period'),
            _periodLabel(context, goal.period),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.bodySmall
                ?.copyWith(color: AppColors.textTertiary),
          ),
          Text(
            value,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
        color: AppColors.divider,
        height: 1,
        thickness: 1,
      );

  void _showTopUpSheet(BuildContext context, SavingsGoalModel goal) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom:
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.tr('add_savings'),
              style: AppTypography.textTheme.titleLarge
                  ?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '${context.tr('suggested')}: ${CurrencyFormatter.format(goal.suggestedPeriodicAmount)}',
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: AppColors.warning),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.textTheme.bodyLarge
                  ?.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '${goal.suggestedPeriodicAmount}',
                prefixText: 'Rp ',
                prefixStyle: AppTypography.textTheme.bodyLarge
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final amount = int.tryParse(controller.text);
                  if (amount == null || amount <= 0) return;
                  context
                      .read<SavingsBloc>()
                      .add(SavingsAmountAdded(goal, amount));
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.background,
                ),
                child: Text(
                  context.tr('confirm_top_up'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SavingsGoalModel goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          context.tr('delete_goal'),
          style: AppTypography.textTheme.titleLarge
              ?.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          context.tr('delete_goal_confirm'),
          style: AppTypography.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel'),
                style:
                    const TextStyle(color: AppColors.textTertiary)),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () {
              context
                  .read<SavingsBloc>()
                  .add(SavingsGoalDeleted(goal.id));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(context.tr('delete')),
          ),
        ],
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
