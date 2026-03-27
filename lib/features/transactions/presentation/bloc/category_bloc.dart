import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/enums/enums.dart';
import '../../data/models/category_model.dart';

// Events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class CategoryStarted extends CategoryEvent {}

class CategoryAdded extends CategoryEvent {
  final String name;
  final TransactionType type;
  final String? icon;
  const CategoryAdded({required this.name, required this.type, this.icon});
  @override
  List<Object?> get props => [name, type, icon];
}

class CategoryDeleted extends CategoryEvent {
  final String id;
  const CategoryDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  const CategoryLoaded(this.categories);

  List<CategoryModel> get expenseCategories =>
      categories.where((c) => c.type == TransactionType.expense).toList();

  List<CategoryModel> get incomeCategories =>
      categories.where((c) => c.type == TransactionType.income).toList();

  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final FirebaseFirestore _firestore;
  final String _uid;

  CategoryBloc({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid,
        super(CategoryInitial()) {
    on<CategoryStarted>(_onStarted);
    on<CategoryAdded>(_onAdded);
    on<CategoryDeleted>(_onDeleted);
  }

  CollectionReference get _collection =>
      _firestore.collection(FirestorePaths.categories(_uid));

  void _onStarted(CategoryStarted event, Emitter<CategoryState> emit) async {
    // Merge default categories with custom ones from Firestore
    final defaultCategories = DefaultCategories.all.map((dc) {
      return CategoryModel(
        id: dc.id,
        name: dc.nameEn,
        icon: dc.icon.codePoint.toString(),
        type: dc.isExpense ? TransactionType.expense : TransactionType.income,
        isDefault: true,
        sortOrder: DefaultCategories.all.indexOf(dc),
      );
    }).toList();

    try {
      final snapshot = await _collection.get();
      final customCategories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      emit(CategoryLoaded([...defaultCategories, ...customCategories]));
    } catch (e) {
      // Even on error, show default categories
      emit(CategoryLoaded(defaultCategories));
    }
  }

  Future<void> _onAdded(
      CategoryAdded event, Emitter<CategoryState> emit) async {
    try {
      final model = CategoryModel(
        id: '',
        name: event.name,
        icon: event.icon,
        type: event.type,
        sortOrder: 100,
      );
      await _collection.add(model.toFirestore());
      add(CategoryStarted()); // Reload
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleted(
      CategoryDeleted event, Emitter<CategoryState> emit) async {
    try {
      await _collection.doc(event.id).delete();
      add(CategoryStarted()); // Reload
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
