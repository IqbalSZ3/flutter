import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/enums.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/transaction_repository.dart';

// Events
abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();
  @override
  List<Object?> get props => [];
}

class AnalysisDateChanged extends AnalysisEvent {
  final DateTime date;
  const AnalysisDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class AnalysisMonthChanged extends AnalysisEvent {
  final DateTime month;
  const AnalysisMonthChanged(this.month);
  @override
  List<Object?> get props => [month];
}

// States
class AnalysisState extends Equatable {
  final DateTime selectedDate;
  final DateTime selectedMonth;
  final List<TransactionModel> dailyTransactions;
  final List<TransactionModel> monthlyTransactions;
  final bool isLoading;

  const AnalysisState({
    required this.selectedDate,
    required this.selectedMonth,
    this.dailyTransactions = const [],
    this.monthlyTransactions = const [],
    this.isLoading = false,
  });

  factory AnalysisState.initial() {
    final now = DateTime.now();
    return AnalysisState(
      selectedDate: now,
      selectedMonth: DateTime(now.year, now.month),
    );
  }

  // Daily computations
  int get dailyIncome => dailyTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (s, t) => s + t.amount);
  int get dailyExpense => dailyTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (s, t) => s + t.amount);

  Map<String, int> get dailyExpenseByCategory {
    final map = <String, int>{};
    for (final t in dailyTransactions.where((t) => t.type == TransactionType.expense)) {
      map[t.categoryName] = (map[t.categoryName] ?? 0) + t.amount;
    }
    return map;
  }

  // Monthly computations
  int get monthlyIncome => monthlyTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (s, t) => s + t.amount);
  int get monthlyExpense => monthlyTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (s, t) => s + t.amount);

  Map<String, int> get monthlyExpenseByCategory {
    final map = <String, int>{};
    for (final t in monthlyTransactions.where((t) => t.type == TransactionType.expense)) {
      map[t.categoryName] = (map[t.categoryName] ?? 0) + t.amount;
    }
    return map;
  }

  Map<String, int> get monthlyIncomeByCategory {
    final map = <String, int>{};
    for (final t in monthlyTransactions.where((t) => t.type == TransactionType.income)) {
      map[t.categoryName] = (map[t.categoryName] ?? 0) + t.amount;
    }
    return map;
  }

  /// Daily expense totals per day of month (for line chart)
  Map<int, int> get dailyExpenseTrend {
    final map = <int, int>{};
    for (final t in monthlyTransactions.where((t) => t.type == TransactionType.expense)) {
      map[t.date.day] = (map[t.date.day] ?? 0) + t.amount;
    }
    return map;
  }

  AnalysisState copyWith({
    DateTime? selectedDate,
    DateTime? selectedMonth,
    List<TransactionModel>? dailyTransactions,
    List<TransactionModel>? monthlyTransactions,
    bool? isLoading,
  }) {
    return AnalysisState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      dailyTransactions: dailyTransactions ?? this.dailyTransactions,
      monthlyTransactions: monthlyTransactions ?? this.monthlyTransactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props =>
      [selectedDate, selectedMonth, dailyTransactions, monthlyTransactions, isLoading];
}

// BLoC
class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final TransactionRepository _repository;

  AnalysisBloc({required TransactionRepository repository})
      : _repository = repository,
        super(AnalysisState.initial()) {
    on<AnalysisDateChanged>(_onDateChanged);
    on<AnalysisMonthChanged>(_onMonthChanged);

    // Load initial data
    add(AnalysisDateChanged(DateTime.now()));
    add(AnalysisMonthChanged(DateTime(DateTime.now().year, DateTime.now().month)));
  }

  Future<void> _onDateChanged(
      AnalysisDateChanged event, Emitter<AnalysisState> emit) async {
    emit(state.copyWith(isLoading: true, selectedDate: event.date));
    try {
      final start = DateTime(event.date.year, event.date.month, event.date.day);
      final end = start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      final transactions =
          await _repository.getTransactionsByDateRange(start, end);
      emit(state.copyWith(dailyTransactions: transactions, isLoading: false));
    } catch (e) {
      // ignore: avoid_print
      print('Daily analysis error: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onMonthChanged(
      AnalysisMonthChanged event, Emitter<AnalysisState> emit) async {
    emit(state.copyWith(isLoading: true, selectedMonth: event.month));
    try {
      final start = DateTime(event.month.year, event.month.month, 1);
      final end = DateTime(event.month.year, event.month.month + 1, 0, 23, 59, 59);
      final transactions =
          await _repository.getTransactionsByDateRange(start, end);
      emit(state.copyWith(monthlyTransactions: transactions, isLoading: false));
    } catch (e) {
      // ignore: avoid_print
      print('Monthly analysis error: $e');
      emit(state.copyWith(isLoading: false));
    }
  }
}
