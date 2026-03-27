import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/installment_model.dart';
import '../bloc/installment_bloc.dart';

class AddInstallmentScreen extends StatefulWidget {
  final InstallmentModel? existing;
  const AddInstallmentScreen({super.key, this.existing});

  @override
  State<AddInstallmentScreen> createState() => _AddInstallmentScreenState();
}

class _AddInstallmentScreenState extends State<AddInstallmentScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _tenureController = TextEditingController();
  final _interestController = TextEditingController(text: '0');
  final _dueDayController = TextEditingController(text: '1');
  InstallmentProvider _provider = InstallmentProvider.shopeePay;
  DateTime _startDate = DateTime.now();

  // Preview
  InstallmentModel? _preview;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _amountController.text = widget.existing!.totalAmount.toString();
      _tenureController.text = widget.existing!.tenure.toString();
      _interestController.text = widget.existing!.interestRate.toString();
      _dueDayController.text = widget.existing!.dueDayOfMonth.toString();
      _provider = widget.existing!.provider;
      _startDate = widget.existing!.startDate;
      _updatePreview();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _tenureController.dispose();
    _interestController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final amount = int.tryParse(_amountController.text);
    final tenure = int.tryParse(_tenureController.text);
    final interest = double.tryParse(_interestController.text) ?? 0;
    final dueDay = int.tryParse(_dueDayController.text) ?? 1;

    if (amount != null && amount > 0 && tenure != null && tenure > 0) {
      setState(() {
        _preview = InstallmentModel.calculate(
          name: _nameController.text,
          provider: _provider,
          totalAmount: amount,
          tenure: tenure,
          interestRate: interest,
          dueDayOfMonth: dueDay.clamp(1, 28),
          startDate: _startDate,
        );
      });
    } else {
      setState(() => _preview = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? context.tr('edit_installment') : context.tr('add_installment'),
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
            // Provider selector
            _buildLabel(context.tr('provider')),
            const SizedBox(height: AppSpacing.sm),
            _buildProviderSelector(),
            const SizedBox(height: AppSpacing.lg),

            // Name
            _buildLabel(context.tr('item_name')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              style: _inputStyle,
              decoration: InputDecoration(hintText: context.tr('item_name_hint')),
              onChanged: (_) => _updatePreview(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Amount
            _buildLabel(context.tr('total_amount_idr')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              style: _inputStyle,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: '5000000'),
              onChanged: (_) => _updatePreview(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tenure & Interest
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(context.tr('tenure_months')),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _tenureController,
                        style: _inputStyle,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(hintText: '12'),
                        onChanged: (_) => _updatePreview(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(context.tr('interest_per_year')),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _interestController,
                        style: _inputStyle,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: '0'),
                        onChanged: (_) => _updatePreview(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Due day
            _buildLabel(context.tr('due_day_of_month')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _dueDayController,
              style: _inputStyle,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: '1'),
              onChanged: (_) => _updatePreview(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Preview card
            if (_preview != null) _buildPreviewCard(_preview!),
            const SizedBox(height: AppSpacing.lg),

            // Save
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(context.tr('save_installment')),
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

  Widget _buildLabel(String text) => Text(
        text,
        style: AppTypography.textTheme.titleSmall
            ?.copyWith(color: AppColors.textSecondary),
      );

  Widget _buildProviderSelector() {
    const providers = InstallmentProvider.values;
    const labels = {
      InstallmentProvider.shopeePay: 'ShopeePay',
      InstallmentProvider.goPayLater: 'GoPay Later',
      InstallmentProvider.tiktokPayLater: 'TikTok Pay Later',
      InstallmentProvider.other: 'Other',
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: providers.map((p) {
        final isSelected = _provider == p;
        return GestureDetector(
          onTap: () => setState(() => _provider = p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Text(
              labels[p]!,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewCard(InstallmentModel preview) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('payment_preview'),
              style: AppTypography.textTheme.titleSmall
                  ?.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.md),
          _previewRow(context.tr('monthly_payment'),
              CurrencyFormatter.format(preview.monthlyPayment)),
          _previewRow(
              context.tr('total_interest'), CurrencyFormatter.format(preview.totalInterest)),
          _previewRow(
              context.tr('total_payable'), CurrencyFormatter.format(preview.totalPayable)),
          _previewRow(context.tr('duration'), '${preview.tenure} ${context.tr('months')}'),
        ],
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textTertiary)),
          Text(value,
              style: AppTypography.amountSmall.copyWith(
                  color: AppColors.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      _showError(context.tr('error_enter_name'));
      return;
    }
    if (_preview == null) {
      _showError(context.tr('error_fill_amount_tenure'));
      return;
    }

    final isEdit = widget.existing != null;
    final InstallmentModel saveModel = isEdit 
        ? _preview!.copyWith(
            id: widget.existing!.id,
            paidInstallments: widget.existing!.paidInstallments,
            remainingBalance: _preview!.totalPayable - (widget.existing!.paidInstallments * _preview!.monthlyPayment),
            isCompleted: widget.existing!.paidInstallments >= _preview!.tenure,
            createdAt: widget.existing!.createdAt,
          )
        : _preview!;

    if (isEdit) {
      context.read<InstallmentBloc>().add(InstallmentUpdated(saveModel));
    } else {
      context.read<InstallmentBloc>().add(InstallmentAdded(saveModel));
    }
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
