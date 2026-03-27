import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/category_bloc.dart';
import '../bloc/transaction_bloc.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _type = TransactionType.expense;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('add_transaction'),
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            _buildTypeToggle(),
            const SizedBox(height: AppSpacing.lg),

            // Amount input
            _buildAmountInput(),
            const SizedBox(height: AppSpacing.lg),

            // Category selector
            _buildLabel(context.tr('category')),
            const SizedBox(height: AppSpacing.sm),
            _buildCategoryGrid(),
            const SizedBox(height: AppSpacing.lg),

            // Date picker
            _buildLabel(context.tr('date')),
            const SizedBox(height: AppSpacing.sm),
            _buildDatePicker(),
            const SizedBox(height: AppSpacing.lg),

            // Notes
            _buildLabel(context.tr('notes_optional')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: context.tr('add_a_note'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(context.tr('save_transaction')),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTypeButton(TransactionType.expense, context.tr('filter_expense'), AppColors.expense),
          _buildTypeButton(TransactionType.income, context.tr('filter_income'), AppColors.income),
        ],
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label, Color color) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = type;
          _selectedCategoryId = null;
          _selectedCategoryName = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: isSelected
                ? Border.all(color: color.withValues(alpha: 0.3))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: isSelected ? color : AppColors.textTertiary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    final color =
        _type == TransactionType.expense ? AppColors.expense : AppColors.income;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _type == TransactionType.expense ? context.tr('how_much_spend') : context.tr('how_much_earn'),
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Rp',
              style: AppTypography.amountMedium.copyWith(color: color),
            ),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: AppTypography.amountLarge.copyWith(color: color),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: AppTypography.amountLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.textTheme.titleSmall?.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = _type == TransactionType.expense
            ? state.expenseCategories
            : state.incomeCategories;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories.map((cat) {
            final isSelected = _selectedCategoryId == cat.id;
            final color = _type == TransactionType.expense
                ? AppColors.expense
                : AppColors.income;

            IconData iconData;
            try {
              iconData = IconData(
                int.parse(cat.icon ?? '0'),
                fontFamily: 'MaterialIcons',
              );
            } catch (_) {
              iconData = Icons.category_rounded;
            }

            return GestureDetector(
              onTap: () => setState(() {
                _selectedCategoryId = cat.id;
                _selectedCategoryName = cat.name;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.5)
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData,
                        size: 18,
                        color: isSelected ? color : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: isSelected ? color : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColors.primary,
                    ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
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
            const Icon(Icons.calendar_today_rounded,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              _formatDate(_selectedDate),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return context.tr('today');
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return context.tr('yesterday');
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _save() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError(context.tr('error_enter_amount'));
      return;
    }
    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError(context.tr('error_valid_amount'));
      return;
    }
    if (_selectedCategoryId == null) {
      _showError(context.tr('error_select_category'));
      return;
    }

    final now = DateTime.now();
    final transaction = TransactionModel(
      id: '',
      type: _type,
      amount: amount,
      categoryId: _selectedCategoryId!,
      categoryName: _selectedCategoryName!,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    context.read<TransactionBloc>().add(TransactionAdded(transaction));
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
