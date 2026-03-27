import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/transaction_repository.dart';

// Events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionStarted extends TransactionEvent {}

class TransactionAdded extends TransactionEvent {
  final TransactionModel transaction;
  const TransactionAdded(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends TransactionEvent {
  final TransactionModel transaction;
  const TransactionUpdated(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionEvent {
  final String id;
  const TransactionDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class TransactionFilterChanged extends TransactionEvent {
  final TransactionType? typeFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  const TransactionFilterChanged({this.typeFilter, this.startDate, this.endDate});
  @override
  List<Object?> get props => [typeFilter, startDate, endDate];
}

class _TransactionDataReceived extends TransactionEvent {
  final List<TransactionModel> transactions;
  const _TransactionDataReceived(this.transactions);
  @override
  List<Object?> get props => [transactions];
}

// States
abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final TransactionType? typeFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionLoaded({
    required this.transactions,
    this.typeFilter,
    this.startDate,
    this.endDate,
  });

  List<TransactionModel> get filtered {
    if (typeFilter == null) return transactions;
    return transactions.where((t) => t.type == typeFilter).toList();
  }

  int get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  int get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  int get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [transactions, typeFilter, startDate, endDate];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;
  StreamSubscription<List<TransactionModel>>? _subscription;

  TransactionBloc({required TransactionRepository repository})
      : _repository = repository,
        super(TransactionInitial()) {
    on<TransactionStarted>(_onStarted);
    on<TransactionAdded>(_onAdded);
    on<TransactionUpdated>(_onUpdated);
    on<TransactionDeleted>(_onDeleted);
    on<TransactionFilterChanged>(_onFilterChanged);
    on<_TransactionDataReceived>(_onDataReceived);
  }

  void _onStarted(TransactionStarted event, Emitter<TransactionState> emit) {
    emit(TransactionLoading());
    _subscription?.cancel();
    _subscription = _repository.watchTransactions().listen(
      (transactions) => add(_TransactionDataReceived(transactions)),
    );
  }

  Future<void> _onAdded(
      TransactionAdded event, Emitter<TransactionState> emit) async {
    try {
      await _repository.addTransaction(event.transaction);
    } catch (e) {
      emit(TransactionError(ErrorMapper.toUserMessage(e)));
    }
  }

  Future<void> _onUpdated(
      TransactionUpdated event, Emitter<TransactionState> emit) async {
    try {
      await _repository.updateTransaction(event.transaction);
    } catch (e) {
      emit(TransactionError(ErrorMapper.toUserMessage(e)));
    }
  }

  Future<void> _onDeleted(
      TransactionDeleted event, Emitter<TransactionState> emit) async {
    try {
      await _repository.deleteTransaction(event.id);
    } catch (e) {
      emit(TransactionError(ErrorMapper.toUserMessage(e)));
    }
  }

  void _onFilterChanged(
      TransactionFilterChanged event, Emitter<TransactionState> emit) {
    final currentState = state;
    if (currentState is TransactionLoaded) {
      emit(TransactionLoaded(
        transactions: currentState.transactions,
        typeFilter: event.typeFilter,
        startDate: event.startDate ?? currentState.startDate,
        endDate: event.endDate ?? currentState.endDate,
      ));
    }
  }

  void _onDataReceived(
      _TransactionDataReceived event, Emitter<TransactionState> emit) {
    final currentState = state;
    emit(TransactionLoaded(
      transactions: event.transactions,
      typeFilter: currentState is TransactionLoaded
          ? currentState.typeFilter
          : null,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
