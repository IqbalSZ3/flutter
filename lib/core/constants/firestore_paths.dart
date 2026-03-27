class FirestorePaths {
  FirestorePaths._();

  static String userDoc(String uid) => 'users/$uid';
  static String transactions(String uid) => 'users/$uid/transactions';
  static String categories(String uid) => 'users/$uid/categories';
  static String savingsGoals(String uid) => 'users/$uid/savings_goals';
  static String installments(String uid) => 'users/$uid/installments';
  static String installmentPayments(String uid, String installmentId) =>
      'users/$uid/installments/$installmentId/payments';
  static String subscriptions(String uid) => 'users/$uid/subscriptions';
}
