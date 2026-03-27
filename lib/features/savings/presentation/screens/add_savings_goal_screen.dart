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

class AddSavingsGoalScreen extends StatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  SavingsPeriod _period = SavingsPeriod.monthly;
  DateTime _targetDate =
      DateTime.now().add(const Duration(days: 180));

  // Live suggestion computed from input
  int? _suggestedAmount;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _updateSuggestion() {
    final amount = int.tryParse(_targetController.text);
    if (amount == null || amount <= 0) {
      setState(() => _suggestedAmount = null);
      return;
    }
    final now = DateTime.now();
    final daysLeft = _targetDate.difference(now).inDays;
    if (daysLeft <= 0) {
      setState(() => _suggestedAmount = amount);
      return;
    }

    int suggestion;
    switch (_period) {
      case SavingsPeriod.weekly:
        final weeks = (daysLeft / 7).ceil();
        suggestion = weeks > 0 ? (amount / weeks).ceil() : amount;
      case SavingsPeriod.monthly:
        final months =
            (((_targetDate.year - now.year) * 12 + _targetDate.month - now.month))
                .clamp(1, 9999);
        suggestion = (amount / months).ceil();
      case SavingsPeriod.yearly:
        final years = (_targetDate.year - now.year).clamp(1, 9999);
        suggestion = (amount / years).ceil();
      case SavingsPeriod.custom:
        final months =
            (((_targetDate.year - now.year) * 12 + _targetDate.month - now.month))
                .clamp(1, 9999);
        suggestion = (amount / months).ceil();
    }
    setState(() => _suggestedAmount = suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('add_savings_goal'),
          style: AppTypography.textTheme.headlineSmall
              ?.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal name
            _buildLabel(context.tr('goal_name')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              style: _inputStyle,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: context.tr('goal_name_hint'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Target amount
            _buildLabel(context.tr('target_amount_idr')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _targetController,
              style: _inputStyle,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration:
                  const InputDecoration(hintText: '5000000'),
              onChanged: (_) => _updateSuggestion(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Saving period
            _buildLabel(context.tr('saving_period')),
            const SizedBox(height: AppSpacing.sm),
            _buildPeriodSelector(),
            const SizedBox(height: AppSpacing.lg),

            // Target date
            _buildLabel(context.tr('target_date')),
            const SizedBox(height: AppSpacing.sm),
            _buildDatePicker(),
            const SizedBox(height: AppSpacing.lg),

            // Live suggestion card
            if (_suggestedAmount != null) _buildSuggestionCard(),
            if (_suggestedAmount != null) const SizedBox(height: AppSpacing.lg),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.background,
                ),
                child: Text(
                  context.tr('save_savings_goal'),
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = SavingsPeriod.values;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: periods.map((p) {
        final isSelected = _period == p;
        return GestureDetector(
          onTap: () {
            setState(() => _period = p);
            _updateSuggestion();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isSelected
                    ? AppColors.warning.withValues(alpha: 0.5)
                    : AppColors.divider,
              ),
            ),
            child: Text(
              _periodLabelFor(context, p),
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? AppColors.warning
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _targetDate,
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.warning,
                  ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _targetDate = picked);
          _updateSuggestion();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.flag_rounded,
                color: AppColors.warning, size: 20),
            const SizedBox(width: 12),
            Text(
              '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard() {
    final periodLabel = _periodLabelFor(context, _period).toLowerCase();
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('suggested_saving'),
                  style: AppTypography.textTheme.labelMedium
                      ?.copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${CurrencyFormatter.format(_suggestedAmount!)} / $periodLabel',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: AppTypography.textTheme.titleSmall
            ?.copyWith(color: AppColors.textSecondary),
      );

  TextStyle? get _inputStyle =>
      AppTypography.textTheme.bodyMedium
          ?.copyWith(color: AppColors.textPrimary);

  String _periodLabelFor(BuildContext context, SavingsPeriod period) {
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

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(context.tr('error_enter_name'));
      return;
    }
    final amount = int.tryParse(_targetController.text);
    if (amount == null || amount <= 0) {
      _showError(context.tr('error_enter_valid_amount'));
      return;
    }

    final now = DateTime.now();
    final goal = SavingsGoalModel(
      id: '',
      name: name,
      targetAmount: amount,
      currentAmount: 0,
      period: _period,
      startDate: now,
      targetDate: _targetDate,
      periodicSaveAmount: _suggestedAmount,
      createdAt: now,
    );

    context.read<SavingsBloc>().add(SavingsGoalAdded(goal));
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
