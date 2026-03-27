import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/installment_model.dart';
import '../bloc/installment_bloc.dart';

class InstallmentDetailScreen extends StatelessWidget {
  final InstallmentModel installment;
  const InstallmentDetailScreen({super.key, required this.installment});

  @override
  Widget build(BuildContext context) {
    final progress = installment.paidInstallments / installment.tenure;

    return Scaffold(
      appBar: AppBar(
        title: Text(installment.name,
            style: AppTypography.textTheme.headlineSmall
                ?.copyWith(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: () => context.push('/add-installment', extra: installment),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.expense),
            onPressed: () {
              context
                  .read<InstallmentBloc>()
                  .add(InstallmentDeleted(installment.id));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.divider, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(context.tr('remaining_balance'),
                      style: AppTypography.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(installment.remainingBalance),
                    style:
                        AppTypography.amountLarge.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${installment.paidInstallments} / ${installment.tenure} ${context.tr('payments')}',
                    style: AppTypography.textTheme.labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Info rows
            _infoRow(context.tr('monthly_payment'),
                CurrencyFormatter.format(installment.monthlyPayment)),
            _infoRow(context.tr('total_amount'),
                CurrencyFormatter.format(installment.totalAmount)),
            _infoRow(context.tr('total_interest'),
                CurrencyFormatter.format(installment.totalInterest)),
            _infoRow(context.tr('interest_rate'),
                '${installment.interestRate}${context.tr('per_year')}'),
            _infoRow(context.tr('due_day'),
                context.tr('every_day').replaceAll('{day}', '${installment.dueDayOfMonth}')),
            const SizedBox(height: AppSpacing.lg),

            // Mark payment button
            if (!installment.isCompleted)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<InstallmentBloc>()
                        .add(InstallmentPaymentMarked(installment));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(context.tr('mark_payment_paid')
                      .replaceAll('{number}', '${installment.paidInstallments + 1}')),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Payment schedule
            Text(context.tr('payment_schedule'),
                style: AppTypography.textTheme.titleMedium
                    ?.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            ...installment.paymentSchedule.map((item) => _scheduleRow(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textTertiary)),
          Text(value,
              style: AppTypography.textTheme.titleSmall
                  ?.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _scheduleRow(BuildContext context, PaymentScheduleItem item) {
    Color statusColor;
    IconData statusIcon;
    if (item.isPaid) {
      statusColor = AppColors.income;
      statusIcon = Icons.check_circle_rounded;
    } else if (item.isOverdue) {
      statusColor = AppColors.expense;
      statusIcon = Icons.error_rounded;
    } else {
      statusColor = AppColors.textTertiary;
      statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr('payment_number').replaceAll('{number}', '${item.number}'),
              style: AppTypography.textTheme.titleSmall
                  ?.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(CurrencyFormatter.format(item.amount),
                  style: AppTypography.amountSmall
                      .copyWith(color: AppColors.textPrimary, fontSize: 13)),
              Text(
                '${item.dueDate.day}/${item.dueDate.month}/${item.dueDate.year}',
                style: AppTypography.textTheme.labelSmall
                    ?.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
