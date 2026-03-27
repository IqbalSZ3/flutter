import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/subscription_model.dart';
import '../../data/subscription_repository_impl.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class SubscriptionStarted extends SubscriptionEvent {}

class SubscriptionAdded extends SubscriptionEvent {
  final SubscriptionModel subscription;
  const SubscriptionAdded(this.subscription);
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionUpdated extends SubscriptionEvent {
  final SubscriptionModel subscription;
  const SubscriptionUpdated(this.subscription);
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionDeleted extends SubscriptionEvent {
  final String id;
  const SubscriptionDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class _SubscriptionDataReceived extends SubscriptionEvent {
  final List<SubscriptionModel> subscriptions;
  const _SubscriptionDataReceived(this.subscriptions);
  @override
  List<Object?> get props => [subscriptions];
}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionModel> subscriptions;
  const SubscriptionLoaded(this.subscriptions);

  List<SubscriptionModel> get active =>
      subscriptions.where((s) => s.isActive).toList();
  int get totalMonthlyCost =>
      active.fold(0, (s, sub) => s + sub.monthlyCost);

  @override
  List<Object?> get props => [subscriptions];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  StreamSubscription<List<SubscriptionModel>>? _subscription;

  SubscriptionBloc({required SubscriptionRepository repository})
      : _repository = repository,
        super(SubscriptionInitial()) {
    on<SubscriptionStarted>(_onStarted);
    on<SubscriptionAdded>(_onAdded);
    on<SubscriptionUpdated>(_onUpdated);
    on<SubscriptionDeleted>(_onDeleted);
    on<_SubscriptionDataReceived>(_onDataReceived);
  }

  void _onStarted(SubscriptionStarted event, Emitter<SubscriptionState> emit) {
    emit(SubscriptionLoading());
    _subscription?.cancel();
    _subscription = _repository.watchSubscriptions().listen(
      (data) => add(_SubscriptionDataReceived(data)),
    );
  }

  Future<void> _onAdded(
      SubscriptionAdded event, Emitter<SubscriptionState> emit) async {
    try {
      await _repository.addSubscription(event.subscription);
    } catch (e) {
      emit(SubscriptionError(ErrorMapper.toUserMessage(e)));
    }
  }

  Future<void> _onUpdated(
      SubscriptionUpdated event, Emitter<SubscriptionState> emit) async {
    try {
      await _repository.updateSubscription(event.subscription);
    } catch (e) {
      emit(SubscriptionError(ErrorMapper.toUserMessage(e)));
    }
  }

  Future<void> _onDeleted(
      SubscriptionDeleted event, Emitter<SubscriptionState> emit) async {
    try {
      await _repository.deleteSubscription(event.id);
    } catch (e) {
      emit(SubscriptionError(ErrorMapper.toUserMessage(e)));
    }
  }

  void _onDataReceived(
      _SubscriptionDataReceived event, Emitter<SubscriptionState> emit) {
    NotificationService().scheduleSubscriptions(event.subscriptions);
    emit(SubscriptionLoaded(event.subscriptions));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
