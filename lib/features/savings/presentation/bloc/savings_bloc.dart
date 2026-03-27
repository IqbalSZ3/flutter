import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/savings_repository_impl.dart';

// Events
abstract class SavingsEvent extends Equatable {
  const SavingsEvent();
  @override
  List<Object?> get props => [];
}

class SavingsStarted extends SavingsEvent {}

class SavingsGoalAdded extends SavingsEvent {
  final SavingsGoalModel goal;
  const SavingsGoalAdded(this.goal);
  @override
  List<Object?> get props => [goal];
}

class SavingsAmountAdded extends SavingsEvent {
  final SavingsGoalModel goal;
  final int amount;
  const SavingsAmountAdded(this.goal, this.amount);
  @override
  List<Object?> get props => [goal, amount];
}

class SavingsGoalDeleted extends SavingsEvent {
  final String id;
  const SavingsGoalDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class _SavingsDataReceived extends SavingsEvent {
  final List<SavingsGoalModel> goals;
  const _SavingsDataReceived(this.goals);
  @override
  List<Object?> get props => [goals];
}

// States
abstract class SavingsState extends Equatable {
  const SavingsState();
  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {}

class SavingsLoading extends SavingsState {}

class SavingsLoaded extends SavingsState {
  final List<SavingsGoalModel> goals;
  const SavingsLoaded(this.goals);

  List<SavingsGoalModel> get active =>
      goals.where((g) => !g.isCompleted).toList();
  List<SavingsGoalModel> get completed =>
      goals.where((g) => g.isCompleted).toList();

  @override
  List<Object?> get props => [goals];
}

class SavingsError extends SavingsState {
  final String message;
  const SavingsError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final SavingsRepository _repository;
  StreamSubscription<List<SavingsGoalModel>>? _subscription;

  SavingsBloc({required SavingsRepository repository})
      : _repository = repository,
        super(SavingsInitial()) {
    on<SavingsStarted>(_onStarted);
    on<SavingsGoalAdded>(_onGoalAdded);
    on<SavingsAmountAdded>(_onAmountAdded);
    on<SavingsGoalDeleted>(_onDeleted);
    on<_SavingsDataReceived>(_onDataReceived);
  }

  void _onStarted(SavingsStarted event, Emitter<SavingsState> emit) {
    emit(SavingsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchGoals().listen(
      (data) => add(_SavingsDataReceived(data)),
    );
  }

  Future<void> _onGoalAdded(
      SavingsGoalAdded event, Emitter<SavingsState> emit) async {
    try {
      await _repository.addGoal(event.goal);
    } catch (e) {
      emit(SavingsError(ErrorMapper.toUserMessage(e)));
    }
  }

  Future<void> _onAmountAdded(
      SavingsAmountAdded event, Emitter<SavingsState> emit) async {
    try {
      await _repository.addSavings(event.goal, event.amount);
    } catch (e) {
      emit(SavingsError(ErrorMapper.toUserMessage(e)));
    }
  }

  Future<void> _onDeleted(
      SavingsGoalDeleted event, Emitter<SavingsState> emit) async {
    try {
      await _repository.deleteGoal(event.id);
    } catch (e) {
      emit(SavingsError(ErrorMapper.toUserMessage(e)));
    }
  }

  void _onDataReceived(
      _SavingsDataReceived event, Emitter<SavingsState> emit) {
    emit(SavingsLoaded(event.goals));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
