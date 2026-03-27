import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../domain/transaction_repository.dart';
import 'models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  TransactionRepositoryImpl({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference get _collection =>
      _firestore.collection(FirestorePaths.transactions(_uid));

  @override
  Stream<List<TransactionModel>> watchTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) {
    Query query = _collection.orderBy('date', descending: true);
    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    query = query.limit(limit);
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList());
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final docRef = await _collection.add(transaction.toFirestore());
    return transaction.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _collection.doc(transaction.id).update(transaction.toFirestore());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    try {
      final snapshot = await _collection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Fallback: query without orderBy (avoids composite index issues)
      final snapshot = await _collection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      final list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
  }
}
