import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/analysis_bloc.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Refresh data when screen is opened
    _refreshCurrentTab();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _refreshCurrentTab();
  }

  void _refreshCurrentTab() {
    final bloc = context.read<AnalysisBloc>();
    if (_tabController.index == 0) {
      bloc.add(AnalysisDateChanged(bloc.state.selectedDate));
    } else {
      bloc.add(AnalysisMonthChanged(bloc.state.selectedMonth));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('analysis'),
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: [
            Tab(text: context.tr('daily')),
            Tab(text: context.tr('monthly')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DailyAnalysisView(),
          _MonthlyAnalysisView(),
        ],
      ),
    );
  }
}

class _DailyAnalysisView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisBloc, AnalysisState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date navigator
              _DateNavigator(
                label: '${state.selectedDate.day}/${state.selectedDate.month}/${state.selectedDate.year}',
                onPrevious: () {
                  final prev =
                      state.selectedDate.subtract(const Duration(days: 1));
                  context.read<AnalysisBloc>().add(AnalysisDateChanged(prev));
                },
                onNext: () {
                  final next =
                      state.selectedDate.add(const Duration(days: 1));
                  if (next.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                    context.read<AnalysisBloc>().add(AnalysisDateChanged(next));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Summary cards
              Row(
                children: [
                  _SummaryCard(
                    label: context.tr('income'),
                    amount: state.dailyIncome,
                    color: AppColors.income,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _SummaryCard(
                    label: context.tr('expense'),
                    amount: state.dailyExpense,
                    color: AppColors.expense,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Pie chart
              if (state.dailyExpenseByCategory.isNotEmpty) ...[
                Text(
                  context.tr('expense_breakdown'),
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: _ExpensePieChart(data: state.dailyExpenseByCategory),
                ),
              ] else
                _EmptyChart(text: context.tr('no_expenses_today')),
            ],
          ),
        );
      },
    );
  }
}

class _MonthlyAnalysisView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisBloc, AnalysisState>(
      builder: (context, state) {
        final monthLabel =
            '${AppStrings.monthName(state.selectedMonth.month, context.lang)} ${state.selectedMonth.year}';

        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateNavigator(
                label: monthLabel,
                onPrevious: () {
                  final prev = DateTime(
                      state.selectedMonth.year, state.selectedMonth.month - 1);
                  context.read<AnalysisBloc>().add(AnalysisMonthChanged(prev));
                },
                onNext: () {
                  final next = DateTime(
                      state.selectedMonth.year, state.selectedMonth.month + 1);
                  if (next.isBefore(
                      DateTime(DateTime.now().year, DateTime.now().month + 1))) {
                    context.read<AnalysisBloc>().add(AnalysisMonthChanged(next));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  _SummaryCard(
                    label: context.tr('income'),
                    amount: state.monthlyIncome,
                    color: AppColors.income,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _SummaryCard(
                    label: context.tr('expense'),
                    amount: state.monthlyExpense,
                    color: AppColors.expense,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Line chart — daily spending trend
              if (state.dailyExpenseTrend.isNotEmpty) ...[
                Text(
                  context.tr('spending_trend'),
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: _SpendingTrendChart(data: state.dailyExpenseTrend),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Income breakdown
              if (state.monthlyIncomeByCategory.isNotEmpty) ...[
                Text(
                  context.tr('income_breakdown'),
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: _ExpensePieChart(
                      data: state.monthlyIncomeByCategory,
                      isIncome: true),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Expense pie chart
              if (state.monthlyExpenseByCategory.isNotEmpty) ...[
                Text(
                  context.tr('expense_breakdown'),
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child:
                      _ExpensePieChart(data: state.monthlyExpenseByCategory),
                ),
              ] else if (state.monthlyIncomeByCategory.isEmpty)
                _EmptyChart(text: context.tr('no_transactions_this_month')),
            ],
          ),
        );
      },
    );
  }
}

// Shared widgets

class _DateNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _DateNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.textSecondary),
        ),
        Text(
          label,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            Text(label,
                style: AppTypography.textTheme.labelMedium
                    ?.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(amount),
              style: AppTypography.amountSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpensePieChart extends StatefulWidget {
  final Map<String, int> data;
  final bool isIncome;
  const _ExpensePieChart({required this.data, this.isIncome = false});

  @override
  State<_ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<_ExpensePieChart> {
  static const _colors = [
    AppColors.expense,
    AppColors.income,
    AppColors.warning,
    AppColors.info,
    AppColors.primary,
    Color(0xFFB87A5A), // terracotta
    Color(0xFF8A7E6B), // warm taupe
    Color(0xFF7A8A9B), // slate blue
  ];

  late List<MapEntry<String, int>> _entries;
  late int _total;

  @override
  void initState() {
    super.initState();
    _computeData();
  }

  @override
  void didUpdateWidget(_ExpensePieChart old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _computeData();
  }

  void _computeData() {
    _entries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _total = _entries.fold(0, (s, e) => s + e.value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: _entries.asMap().entries.map((e) {
                final pct = (e.value.value / _total * 100);
                return PieChartSectionData(
                  color: _colors[e.key % _colors.length],
                  value: e.value.value.toDouble(),
                  title: '${pct.toStringAsFixed(0)}%',
                  titleStyle: AppTypography.textTheme.labelSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  radius: 40,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _entries.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colors[e.key % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.value.key,
                        style: AppTypography.textTheme.labelSmall
                            ?.copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SpendingTrendChart extends StatefulWidget {
  final Map<int, int> data;
  const _SpendingTrendChart({required this.data});

  @override
  State<_SpendingTrendChart> createState() => _SpendingTrendChartState();
}

class _SpendingTrendChartState extends State<_SpendingTrendChart> {
  late double _maxY;
  late List<FlSpot> _spots;

  @override
  void initState() {
    super.initState();
    _computeData();
  }

  @override
  void didUpdateWidget(_SpendingTrendChart old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _computeData();
  }

  void _computeData() {
    _maxY = widget.data.values.isEmpty
        ? 100.0
        : widget.data.values.reduce(max).toDouble() * 1.2;
    _spots = widget.data.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY;
    final spots = _spots;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                CurrencyFormatter.formatCompact(value.toInt()),
                style: AppTypography.textTheme.labelSmall
                    ?.copyWith(color: AppColors.textTertiary, fontSize: 9),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: AppTypography.textTheme.labelSmall
                    ?.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: 31,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.expense,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.expense.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String text;
  const _EmptyChart({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart_rounded,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.sm),
          Text(text,
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
