import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

class TransactionModel extends Equatable {
  final String id;
  final TransactionType type;
  final int amount;
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      type: TransactionType.values.byName(data['type'] as String),
      amount: data['amount'] as int,
      categoryId: data['categoryId'] as String,
      categoryName: data['categoryName'] as String,
      categoryIcon: data['categoryIcon'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type.name,
        'amount': amount,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, type, amount, categoryId, categoryName,
        categoryIcon, date, notes, createdAt, updatedAt,
      ];
}
