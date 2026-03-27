import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final TransactionType type;
  final bool isDefault;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.type,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      icon: data['icon'] as String?,
      type: TransactionType.values.byName(data['type'] as String),
      isDefault: data['isDefault'] as bool? ?? false,
      sortOrder: data['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'icon': icon,
        'type': type.name,
        'isDefault': isDefault,
        'sortOrder': sortOrder,
      };

  @override
  List<Object?> get props => [id, name, icon, type, isDefault, sortOrder];
}
