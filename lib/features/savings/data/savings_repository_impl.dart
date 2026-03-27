import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import 'models/savings_goal_model.dart';

class SavingsRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  SavingsRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference get _collection =>
      _firestore.collection(FirestorePaths.savingsGoals(_uid));

  Stream<List<SavingsGoalModel>> watchGoals() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
        (snap) =>
            snap.docs.map((d) => SavingsGoalModel.fromFirestore(d)).toList());
  }

  Future<SavingsGoalModel> addGoal(SavingsGoalModel goal) async {
    final ref = await _collection.add(goal.toFirestore());
    return goal.copyWith(id: ref.id);
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    await _collection.doc(goal.id).update(goal.toFirestore());
  }

  Future<void> deleteGoal(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> addSavings(SavingsGoalModel goal, int amount) async {
    final newAmount = goal.currentAmount + amount;
    final isComplete = newAmount >= goal.targetAmount;
    await _collection.doc(goal.id).update({
      'currentAmount': newAmount,
      'isCompleted': isComplete,
    });
  }
}
