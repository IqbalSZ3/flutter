import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/subscription_model.dart';
import '../bloc/subscription_bloc.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  BillingCycle _cycle = BillingCycle.monthly;
  DateTime _nextRenewal = DateTime.now().add(const Duration(days: 30));
  int _reminderDays = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('add_subscription'),
            style: AppTypography.textTheme.headlineSmall
                ?.copyWith(color: AppColors.textPrimary)),
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
            _label(context.tr('service_name')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              style: _inputStyle,
              decoration: InputDecoration(
                  hintText: context.tr('service_name_hint')),
            ),
            const SizedBox(height: AppSpacing.lg),

            _label(context.tr('amount_idr')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              style: _inputStyle,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: '149000'),
            ),
            const SizedBox(height: AppSpacing.lg),

            _label(context.tr('billing_cycle')),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: BillingCycle.values.map((c) {
                final selected = _cycle == c;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: c == BillingCycle.monthly ? AppSpacing.sm : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _cycle = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color:
                                selected ? AppColors.primary : AppColors.divider,
                          ),
                        ),
                        child: Text(
                          c == BillingCycle.monthly ? context.tr('monthly') : context.tr('yearly'),
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            _label(context.tr('next_renewal_date')),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _nextRenewal,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (picked != null) setState(() => _nextRenewal = picked);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${_nextRenewal.day}/${_nextRenewal.month}/${_nextRenewal.year}',
                      style: AppTypography.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _label(context.tr('remind_me_days')),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [1, 3, 5, 7].map((d) {
                final selected = _reminderDays == d;
                return GestureDetector(
                  onTap: () => setState(() => _reminderDays = d),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Text('${d}d',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            _label(context.tr('notes_optional')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              style: _inputStyle,
              maxLines: 2,
              decoration: InputDecoration(hintText: context.tr('add_a_note')),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(context.tr('save_subscription')),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  TextStyle? get _inputStyle =>
      AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary);

  Widget _label(String text) => Text(text,
      style: AppTypography.textTheme.titleSmall
          ?.copyWith(color: AppColors.textSecondary));

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      _showError(context.tr('error_enter_name'));
      return;
    }
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(context.tr('error_enter_valid_amount'));
      return;
    }

    final sub = SubscriptionModel(
      id: '',
      name: _nameController.text.trim(),
      amount: amount,
      cycle: _cycle,
      nextRenewalDate: _nextRenewal,
      reminderDaysBefore: _reminderDays,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<SubscriptionBloc>().add(SubscriptionAdded(sub));
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
