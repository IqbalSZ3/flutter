import '../data/models/transaction_model.dart';

abstract class TransactionRepository {
  Stream<List<TransactionModel>> watchTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  });
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end);
}
