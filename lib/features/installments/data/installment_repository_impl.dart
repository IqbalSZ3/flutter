import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import 'models/installment_model.dart';

class InstallmentRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  InstallmentRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference get _collection =>
      _firestore.collection(FirestorePaths.installments(_uid));

  Stream<List<InstallmentModel>> watchInstallments() {
    // Server-side: order by isCompleted (false/active first, true/completed last)
    // Client-side: secondary sort by nextDueDate within each group (null handling)
    return _collection.orderBy('isCompleted').snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => InstallmentModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        final aDate = a.nextDueDate ?? DateTime(2099);
        final bDate = b.nextDueDate ?? DateTime(2099);
        return aDate.compareTo(bDate);
      });
      return list;
    });
  }

  Future<InstallmentModel> addInstallment(InstallmentModel model) async {
    final ref = await _collection.add(model.toFirestore());
    return model.copyWith(id: ref.id);
  }

  Future<void> updateInstallment(InstallmentModel model) async {
    await _collection.doc(model.id).update(model.toFirestore());
  }

  Future<void> deleteInstallment(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> markPayment(InstallmentModel installment) async {
    final newPaid = installment.paidInstallments + 1;
    final newRemaining =
        installment.remainingBalance - installment.monthlyPayment;
    final isComplete = newPaid >= installment.tenure;

    DateTime? nextDue;
    if (!isComplete && installment.nextDueDate != null) {
      nextDue = DateTime(
        installment.nextDueDate!.year,
        installment.nextDueDate!.month + 1,
        installment.dueDayOfMonth,
      );
    }

    final updated = installment.copyWith(
      paidInstallments: newPaid,
      remainingBalance: newRemaining < 0 ? 0 : newRemaining,
      isCompleted: isComplete,
      nextDueDate: nextDue,
    );
    await _collection.doc(installment.id).update(updated.toFirestore());
  }
}
