import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

class SavingsGoalModel extends Equatable {
  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final SavingsPeriod period;
  final DateTime startDate;
  final DateTime targetDate;
  final int? periodicSaveAmount;
  final bool isCompleted;
  final DateTime createdAt;

  const SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.period,
    required this.startDate,
    required this.targetDate,
    this.periodicSaveAmount,
    this.isCompleted = false,
    required this.createdAt,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  int get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);

  /// Auto-calculate how much to save per period
  int get suggestedPeriodicAmount {
    if (periodicSaveAmount != null) return periodicSaveAmount!;
    final remainingAmount = remaining;
    final now = DateTime.now();
    final daysLeft = targetDate.difference(now).inDays;
    if (daysLeft <= 0) return remainingAmount;

    switch (period) {
      case SavingsPeriod.weekly:
        final weeksLeft = (daysLeft / 7).ceil();
        return weeksLeft > 0 ? (remainingAmount / weeksLeft).ceil() : remainingAmount;
      case SavingsPeriod.monthly:
        final monthsLeft = ((targetDate.year - now.year) * 12 +
                targetDate.month - now.month)
            .clamp(1, 9999);
        return (remainingAmount / monthsLeft).ceil();
      case SavingsPeriod.yearly:
        final yearsLeft = (targetDate.year - now.year).clamp(1, 9999);
        return (remainingAmount / yearsLeft).ceil();
      case SavingsPeriod.custom:
        final monthsLeft = ((targetDate.year - now.year) * 12 +
                targetDate.month - now.month)
            .clamp(1, 9999);
        return (remainingAmount / monthsLeft).ceil();
    }
  }

  factory SavingsGoalModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return SavingsGoalModel(
      id: doc.id,
      name: d['name'] as String,
      targetAmount: d['targetAmount'] as int,
      currentAmount: d['currentAmount'] as int? ?? 0,
      period: SavingsPeriod.values.byName(d['period'] as String),
      startDate: (d['startDate'] as Timestamp).toDate(),
      targetDate: (d['targetDate'] as Timestamp).toDate(),
      periodicSaveAmount: d['periodicSaveAmount'] as int?,
      isCompleted: d['isCompleted'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'period': period.name,
        'startDate': Timestamp.fromDate(startDate),
        'targetDate': Timestamp.fromDate(targetDate),
        'periodicSaveAmount': periodicSaveAmount,
        'isCompleted': isCompleted,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  SavingsGoalModel copyWith({
    String? id,
    int? currentAmount,
    bool? isCompleted,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      period: period,
      startDate: startDate,
      targetDate: targetDate,
      periodicSaveAmount: periodicSaveAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, targetAmount, currentAmount, period, isCompleted];
}
