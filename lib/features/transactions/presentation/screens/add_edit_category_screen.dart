import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/category_model.dart';
import '../bloc/category_bloc.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final TransactionType? initialType;
  final CategoryModel? existingCategory;

  const AddEditCategoryScreen({
    super.key,
    this.initialType,
    this.existingCategory,
  });

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _nameController = TextEditingController();
  late TransactionType _type;
  IconData _selectedIcon = Icons.category_rounded;

  final List<IconData> _availableIcons = [
    Icons.category_rounded,
    Icons.fastfood_rounded,
    Icons.shopping_cart_rounded,
    Icons.directions_car_rounded,
    Icons.local_hospital_rounded,
    Icons.home_rounded,
    Icons.flight_rounded,
    Icons.school_rounded,
    Icons.phonelink_rounded,
    Icons.movie_rounded,
    Icons.fitness_center_rounded,
    Icons.restaurant_rounded,
    Icons.work_rounded,
    Icons.payments_rounded,
    Icons.account_balance_rounded,
    Icons.monetization_on_rounded,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingCategory != null) {
      _nameController.text = widget.existingCategory!.name;
      _type = widget.existingCategory!.type;
      try {
        _selectedIcon = IconData(int.parse(widget.existingCategory!.icon ?? '0'), fontFamily: 'MaterialIcons');
      } catch (_) {
        _selectedIcon = Icons.category_rounded;
      }
    } else {
      _type = widget.initialType ?? TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingCategory != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? context.tr('edit_category') : context.tr('add_category'),
          style: AppTypography.textTheme.headlineSmall
              ?.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('category_type'),
              style: AppTypography.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isEdit ? null : () => setState(() => _type = TransactionType.expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == TransactionType.expense 
                          ? AppColors.expense.withValues(alpha: 0.1) 
                          : AppColors.surface,
                        border: Border.all(
                          color: _type == TransactionType.expense ? AppColors.expense : AppColors.divider,
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Center(
                        child: Text(
                          context.tr('expense'),
                          style: TextStyle(
                            color: _type == TransactionType.expense ? AppColors.expense : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: InkWell(
                    onTap: isEdit ? null : () => setState(() => _type = TransactionType.income),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == TransactionType.income 
                          ? AppColors.income.withValues(alpha: 0.1) 
                          : AppColors.surface,
                        border: Border.all(
                          color: _type == TransactionType.income ? AppColors.income : AppColors.divider,
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Center(
                        child: Text(
                          context.tr('income'),
                          style: TextStyle(
                            color: _type == TransactionType.income ? AppColors.income : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.tr('category_name'),
              style: AppTypography.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: context.tr('category_name_hint'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.tr('select_icon'),
              style: AppTypography.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                final isSelected = _selectedIcon == icon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(context.tr('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('error_enter_name'))),
      );
      return;
    }

    if (widget.existingCategory != null) {
      final updated = CategoryModel(
        id: widget.existingCategory!.id,
        name: _nameController.text.trim(),
        icon: _selectedIcon.codePoint.toString(),
        type: _type,
        isDefault: widget.existingCategory!.isDefault,
        sortOrder: widget.existingCategory!.sortOrder,
      );
      context.read<CategoryBloc>().add(CategoryUpdated(updated));
    } else {
      context.read<CategoryBloc>().add(CategoryAdded(
        name: _nameController.text.trim(),
        type: _type,
        icon: _selectedIcon.codePoint.toString(),
      ));
    }

    Navigator.pop(context);
  }
}
