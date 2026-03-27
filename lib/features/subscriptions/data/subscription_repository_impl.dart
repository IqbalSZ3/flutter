import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import 'models/subscription_model.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  SubscriptionRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference get _collection =>
      _firestore.collection(FirestorePaths.subscriptions(_uid));

  Stream<List<SubscriptionModel>> watchSubscriptions() {
    return _collection
        .orderBy('nextRenewalDate')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SubscriptionModel.fromFirestore(doc))
            .toList());
  }

  Future<SubscriptionModel> addSubscription(SubscriptionModel model) async {
    final ref = await _collection.add(model.toFirestore());
    return model.copyWith(id: ref.id);
  }

  Future<void> updateSubscription(SubscriptionModel model) async {
    await _collection.doc(model.id).update(model.toFirestore());
  }

  Future<void> deleteSubscription(String id) async {
    await _collection.doc(id).delete();
  }
}
