import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

class InstallmentModel extends Equatable {
  final String id;
  final String name;
  final InstallmentProvider provider;
  final int totalAmount;
  final int tenure; // months
  final double interestRate; // annual %
  final int monthlyPayment; // auto-calculated
  final int totalInterest;
  final int totalPayable;
  final int remainingBalance;
  final int paidInstallments;
  final int dueDayOfMonth;
  final DateTime startDate;
  final DateTime? nextDueDate;
  final bool isCompleted;
  final DateTime createdAt;

  const InstallmentModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.totalAmount,
    required this.tenure,
    required this.interestRate,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalPayable,
    required this.remainingBalance,
    required this.paidInstallments,
    required this.dueDayOfMonth,
    required this.startDate,
    this.nextDueDate,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Auto-calculate installment details from total, tenure, and interest rate.
  factory InstallmentModel.calculate({
    required String name,
    required InstallmentProvider provider,
    required int totalAmount,
    required int tenure,
    required double interestRate,
    required int dueDayOfMonth,
    required DateTime startDate,
  }) {
    int monthlyPayment;
    int totalInterest;

    if (interestRate == 0) {
      // No interest — simple division
      monthlyPayment = (totalAmount / tenure).ceil();
      totalInterest = 0;
    } else {
      // Flat interest (common for BNPL in Indonesia)
      final monthlyInterest = (totalAmount * interestRate / 100 / 12).round();
      monthlyPayment = (totalAmount / tenure).ceil() + monthlyInterest;
      totalInterest = monthlyInterest * tenure;
    }

    final totalPayable = monthlyPayment * tenure;
    final nextDue = DateTime(startDate.year, startDate.month, dueDayOfMonth);
    final actualNextDue =
        nextDue.isBefore(startDate) || nextDue.isAtSameMomentAs(startDate)
            ? DateTime(startDate.year, startDate.month + 1, dueDayOfMonth)
            : nextDue;

    return InstallmentModel(
      id: '',
      name: name,
      provider: provider,
      totalAmount: totalAmount,
      tenure: tenure,
      interestRate: interestRate,
      monthlyPayment: monthlyPayment,
      totalInterest: totalInterest,
      totalPayable: totalPayable,
      remainingBalance: totalPayable,
      paidInstallments: 0,
      dueDayOfMonth: dueDayOfMonth,
      startDate: startDate,
      nextDueDate: actualNextDue,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  factory InstallmentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return InstallmentModel(
      id: doc.id,
      name: d['name'] as String,
      provider: InstallmentProvider.values.byName(d['provider'] as String),
      totalAmount: d['totalAmount'] as int,
      tenure: d['tenure'] as int,
      interestRate: (d['interestRate'] as num).toDouble(),
      monthlyPayment: d['monthlyPayment'] as int,
      totalInterest: d['totalInterest'] as int,
      totalPayable: d['totalPayable'] as int,
      remainingBalance: d['remainingBalance'] as int,
      paidInstallments: d['paidInstallments'] as int,
      dueDayOfMonth: d['dueDayOfMonth'] as int,
      startDate: (d['startDate'] as Timestamp).toDate(),
      nextDueDate: d['nextDueDate'] != null
          ? (d['nextDueDate'] as Timestamp).toDate()
          : null,
      isCompleted: d['isCompleted'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'provider': provider.name,
        'totalAmount': totalAmount,
        'tenure': tenure,
        'interestRate': interestRate,
        'monthlyPayment': monthlyPayment,
        'totalInterest': totalInterest,
        'totalPayable': totalPayable,
        'remainingBalance': remainingBalance,
        'paidInstallments': paidInstallments,
        'dueDayOfMonth': dueDayOfMonth,
        'startDate': Timestamp.fromDate(startDate),
        'nextDueDate':
            nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
        'isCompleted': isCompleted,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  InstallmentModel copyWith({
    String? id,
    int? remainingBalance,
    int? paidInstallments,
    DateTime? nextDueDate,
    bool? isCompleted,
  }) {
    return InstallmentModel(
      id: id ?? this.id,
      name: name,
      provider: provider,
      totalAmount: totalAmount,
      tenure: tenure,
      interestRate: interestRate,
      monthlyPayment: monthlyPayment,
      totalInterest: totalInterest,
      totalPayable: totalPayable,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      dueDayOfMonth: dueDayOfMonth,
      startDate: startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  /// Generate payment schedule
  List<PaymentScheduleItem> get paymentSchedule {
    final items = <PaymentScheduleItem>[];
    for (var i = 1; i <= tenure; i++) {
      final dueDate =
          DateTime(startDate.year, startDate.month + i, dueDayOfMonth);
      items.add(PaymentScheduleItem(
        number: i,
        amount: monthlyPayment,
        dueDate: dueDate,
        isPaid: i <= paidInstallments,
        isOverdue: !isCompleted &&
            i > paidInstallments &&
            dueDate.isBefore(DateTime.now()),
      ));
    }
    return items;
  }

  @override
  List<Object?> get props => [
        id, name, provider, totalAmount, tenure, interestRate,
        monthlyPayment, remainingBalance, paidInstallments, isCompleted,
      ];
}

class PaymentScheduleItem {
  final int number;
  final int amount;
  final DateTime dueDate;
  final bool isPaid;
  final bool isOverdue;

  const PaymentScheduleItem({
    required this.number,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.isOverdue = false,
  });
}
