import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

class SubscriptionModel extends Equatable {
  final String id;
  final String name;
  final int amount;
  final BillingCycle cycle;
  final DateTime nextRenewalDate;
  final int? reminderDaysBefore;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.nextRenewalDate,
    this.reminderDaysBefore,
    this.isActive = true,
    this.notes,
    required this.createdAt,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      name: d['name'] as String,
      amount: d['amount'] as int,
      cycle: BillingCycle.values.byName(d['cycle'] as String),
      nextRenewalDate: (d['nextRenewalDate'] as Timestamp).toDate(),
      reminderDaysBefore: d['reminderDaysBefore'] as int?,
      isActive: d['isActive'] as bool? ?? true,
      notes: d['notes'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'amount': amount,
        'cycle': cycle.name,
        'nextRenewalDate': Timestamp.fromDate(nextRenewalDate),
        'reminderDaysBefore': reminderDaysBefore,
        'isActive': isActive,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  SubscriptionModel copyWith({
    String? id,
    bool? isActive,
    DateTime? nextRenewalDate,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name,
      amount: amount,
      cycle: cycle,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      reminderDaysBefore: reminderDaysBefore,
      isActive: isActive ?? this.isActive,
      notes: notes,
      createdAt: createdAt,
    );
  }

  int get monthlyCost =>
      cycle == BillingCycle.yearly ? (amount / 12).round() : amount;

  @override
  List<Object?> get props =>
      [id, name, amount, cycle, nextRenewalDate, isActive];
}
