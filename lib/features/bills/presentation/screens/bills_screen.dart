import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../installments/data/models/installment_model.dart';
import '../../../installments/presentation/bloc/installment_bloc.dart';
import '../../../subscriptions/data/models/subscription_model.dart';
import '../../../subscriptions/presentation/bloc/subscription_bloc.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('bills'),
              style: AppTypography.textTheme.headlineMedium
                  ?.copyWith(color: AppColors.textPrimary)),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            tabs: [
              Tab(text: context.tr('installments')),
              Tab(text: context.tr('subscriptions')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InstallmentsTab(),
            _SubscriptionsTab(),
          ],
        ),
      ),
    );
  }
}

class _InstallmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstallmentBloc, InstallmentState>(
      builder: (context, state) {
        if (state is InstallmentLoaded) {
          if (state.installments.isEmpty) return _emptyState(context, true);

          return Column(
            children: [
              // Summary
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.tr('monthly_total'),
                        style: AppTypography.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textTertiary)),
                    Text(
                      CurrencyFormatter.format(state.totalMonthlyPayment),
                      style: AppTypography.amountSmall
                          .copyWith(color: AppColors.expense),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: state.installments.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _InstallmentTile(installment: state.installments[i]),
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _emptyState(BuildContext context, bool isInstallment) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isInstallment
                ? Icons.credit_card_rounded
                : Icons.subscriptions_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isInstallment ? context.tr('no_installments') : context.tr('no_subscriptions'),
            style: AppTypography.textTheme.bodyLarge
                ?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => context.push(
                isInstallment ? '/add-installment' : '/add-subscription'),
            child: Text(isInstallment ? context.tr('add_installment') : context.tr('add_subscription')),
          ),
        ],
      ),
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  final InstallmentModel installment;
  const _InstallmentTile({required this.installment});

  static const _providerLabels = {
    'shopeePay': 'ShopeePay',
    'goPayLater': 'GoPay Later',
    'tiktokPayLater': 'TikTok Pay Later',
    'other': 'Other',
  };

  @override
  Widget build(BuildContext context) {
    final progress = installment.paidInstallments / installment.tenure;

    return GestureDetector(
      onTap: () => context.push('/installment-detail',
          extra: installment),
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(installment.name,
                          style: AppTypography.textTheme.titleSmall
                              ?.copyWith(color: AppColors.textPrimary)),
                      Text(
                        _providerLabels[installment.provider.name] ?? 'Other',
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
                      CurrencyFormatter.format(installment.monthlyPayment),
                      style: AppTypography.amountSmall.copyWith(
                          color: AppColors.textPrimary, fontSize: 14),
                    ),
                    Text(context.tr('per_month'),
                        style: AppTypography.textTheme.labelSmall
                            ?.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor:
                    AlwaysStoppedAnimation(installment.isCompleted
                        ? AppColors.income
                        : AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${installment.paidInstallments}/${installment.tenure} ${context.tr('payments')}',
              style: AppTypography.textTheme.labelSmall
                  ?.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoaded) {
          if (state.subscriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.subscriptions_rounded,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: AppSpacing.md),
                  Text(context.tr('no_subscriptions'),
                      style: AppTypography.textTheme.bodyLarge
                          ?.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => context.push('/add-subscription'),
                    child: Text(context.tr('add_subscription')),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.tr('monthly_cost'),
                        style: AppTypography.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textTertiary)),
                    Text(
                      CurrencyFormatter.format(state.totalMonthlyCost),
                      style: AppTypography.amountSmall
                          .copyWith(color: AppColors.info),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: state.subscriptions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final sub = state.subscriptions[i];
                    return _SubscriptionTile(subscription: sub);
                  },
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  final SubscriptionModel subscription;
  const _SubscriptionTile({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final daysUntil =
        subscription.nextRenewalDate.difference(DateTime.now()).inDays;
    final urgencyColor = daysUntil <= 3
        ? AppColors.expense
        : daysUntil <= 7
            ? AppColors.warning
            : AppColors.textTertiary;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.subscriptions_rounded,
                color: AppColors.info, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscription.name,
                    style: AppTypography.textTheme.titleSmall
                        ?.copyWith(color: AppColors.textPrimary)),
                Text(
                  daysUntil <= 0
                      ? context.tr('due_today')
                      : AppStrings.get('renews_in_days', context.lang).replaceAll('{days}', daysUntil.toString()),
                  style: AppTypography.textTheme.labelSmall
                      ?.copyWith(color: urgencyColor),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(subscription.amount),
            style: AppTypography.amountSmall
                .copyWith(color: AppColors.textPrimary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
