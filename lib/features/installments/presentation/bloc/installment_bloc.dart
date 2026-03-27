import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/installment_repository_impl.dart';
import '../../data/models/installment_model.dart';

// Events
abstract class InstallmentEvent extends Equatable {
  const InstallmentEvent();
  @override
  List<Object?> get props => [];
}

class InstallmentStarted extends InstallmentEvent {}

class InstallmentAdded extends InstallmentEvent {
  final InstallmentModel installment;
  const InstallmentAdded(this.installment);
  @override
  List<Object?> get props => [installment];
}

class InstallmentPaymentMarked extends InstallmentEvent {
  final InstallmentModel installment;
  const InstallmentPaymentMarked(this.installment);
  @override
  List<Object?> get props => [installment];
}

class InstallmentDeleted extends InstallmentEvent {
  final String id;
  const InstallmentDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class _InstallmentDataReceived extends InstallmentEvent {
  final List<InstallmentModel> installments;
  const _InstallmentDataReceived(this.installments);
  @override
  List<Object?> get props => [installments];
}

// States
abstract class InstallmentState extends Equatable {
  const InstallmentState();
  @override
  List<Object?> get props => [];
}

class InstallmentInitial extends InstallmentState {}

class InstallmentLoading extends InstallmentState {}

class InstallmentLoaded extends InstallmentState {
  final List<InstallmentModel> installments;
  const InstallmentLoaded(this.installments);

  List<InstallmentModel> get active =>
      installments.where((i) => !i.isCompleted).toList();
  List<InstallmentModel> get completed =>
      installments.where((i) => i.isCompleted).toList();
  int get totalMonthlyPayment =>
      active.fold(0, (s, i) => s + i.monthlyPayment);

  @override
  List<Object?> get props => [installments];
}

class InstallmentError extends InstallmentState {
  final String message;
  const InstallmentError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class InstallmentBloc extends Bloc<InstallmentEvent, InstallmentState> {
  final InstallmentRepository _repository;
  StreamSubscription<List<InstallmentModel>>? _subscription;

  InstallmentBloc({required InstallmentRepository repository})
      : _repository = repository,
        super(InstallmentInitial()) {
    on<InstallmentStarted>(_onStarted);
    on<InstallmentAdded>(_onAdded);
    on<InstallmentPaymentMarked>(_onPaymentMarked);
    on<InstallmentDeleted>(_onDeleted);
    on<_InstallmentDataReceived>(_onDataReceived);
  }

  void _onStarted(InstallmentStarted event, Emitter<InstallmentState> emit) {
    emit(InstallmentLoading());
    _subscription?.cancel();
    _subscription = _repository.watchInstallments().listen(
      (data) => add(_InstallmentDataReceived(data)),
      onError: (error) {
        // ignore: avoid_print
        print('Installment stream error: $error');
        add(const _InstallmentDataReceived([]));
      },
    );
  }

  Future<void> _onAdded(
      InstallmentAdded event, Emitter<InstallmentState> emit) async {
    try {
      await _repository.addInstallment(event.installment);
    } catch (e) {
      emit(InstallmentError(e.toString()));
    }
  }

  Future<void> _onPaymentMarked(
      InstallmentPaymentMarked event, Emitter<InstallmentState> emit) async {
    try {
      await _repository.markPayment(event.installment);
    } catch (e) {
      emit(InstallmentError(e.toString()));
    }
  }

  Future<void> _onDeleted(
      InstallmentDeleted event, Emitter<InstallmentState> emit) async {
    try {
      await _repository.deleteInstallment(event.id);
    } catch (e) {
      emit(InstallmentError(e.toString()));
    }
  }

  void _onDataReceived(
      _InstallmentDataReceived event, Emitter<InstallmentState> emit) {
    emit(InstallmentLoaded(event.installments));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
