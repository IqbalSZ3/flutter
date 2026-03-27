import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/category_model.dart';
import '../bloc/category_bloc.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('manage_categories'),
          style: AppTypography.textTheme.headlineSmall
              ?.copyWith(color: AppColors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: context.tr('expense')),
            Tab(text: context.tr('income')),
          ],
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is! CategoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _CategoryList(categories: state.expenseCategories),
              _CategoryList(categories: state.incomeCategories),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type = _tabController.index == 0
              ? TransactionType.expense
              : TransactionType.income;
          context.push('/add-edit-category', extra: type);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  const _CategoryList({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          context.tr('no_categories'),
          style: AppTypography.textTheme.bodyLarge
              ?.copyWith(color: AppColors.textTertiary),
        ),
      );
    }
    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        IconData iconData;
        try {
          iconData = IconData(int.parse(cat.icon ?? '0'), fontFamily: 'MaterialIcons');
        } catch (_) {
          iconData = Icons.category_rounded;
        }

        final isDefault = cat.isDefault;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cat.type == TransactionType.expense
                  ? AppColors.expense.withValues(alpha: 0.1)
                  : AppColors.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: cat.type == TransactionType.expense
                  ? AppColors.expense
                  : AppColors.income,
            ),
          ),
          title: Text(
            cat.name,
            style: AppTypography.textTheme.titleMedium,
          ),
          subtitle: isDefault ? Text('Default', style: AppTypography.textTheme.labelSmall) : null,
          trailing: isDefault ? null : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                onPressed: () => context.push('/add-edit-category', extra: cat),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                onPressed: () => _confirmDelete(context, cat),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('delete_category')),
        content: Text(context.tr('delete_category_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('delete'), style: const TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CategoryBloc>().add(CategoryDeleted(cat.id));
    }
  }
}
