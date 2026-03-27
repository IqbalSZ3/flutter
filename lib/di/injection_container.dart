import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/analysis/presentation/bloc/analysis_bloc.dart';
import '../features/installments/data/installment_repository_impl.dart';
import '../features/installments/presentation/bloc/installment_bloc.dart';
import '../features/savings/data/savings_repository_impl.dart';
import '../features/savings/presentation/bloc/savings_bloc.dart';
import '../features/subscriptions/data/subscription_repository_impl.dart';
import '../features/subscriptions/presentation/bloc/subscription_bloc.dart';
import '../features/transactions/data/transaction_repository_impl.dart';
import '../features/transactions/domain/transaction_repository.dart';
import '../features/transactions/presentation/bloc/category_bloc.dart';
import '../features/transactions/presentation/bloc/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
}

void registerUserDependencies(String uid) {
  // Unregister previous user-scoped deps if they exist
  _tryUnregister<TransactionRepository>();
  _tryUnregister<TransactionBloc>();
  _tryUnregister<CategoryBloc>();
  _tryUnregister<AnalysisBloc>();
  _tryUnregister<InstallmentRepository>();
  _tryUnregister<InstallmentBloc>();
  _tryUnregister<SubscriptionRepository>();
  _tryUnregister<SubscriptionBloc>();
  _tryUnregister<SavingsRepository>();
  _tryUnregister<SavingsBloc>();

  // Transactions
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(firestore: sl(), uid: uid),
  );
  sl.registerFactory(() => TransactionBloc(repository: sl()));
  sl.registerFactory(() => CategoryBloc(firestore: sl(), uid: uid));
  sl.registerFactory(() => AnalysisBloc(repository: sl()));

  // Installments
  sl.registerLazySingleton(
    () => InstallmentRepository(firestore: sl(), uid: uid),
  );
  sl.registerFactory(() => InstallmentBloc(repository: sl()));

  // Subscriptions
  sl.registerLazySingleton(
    () => SubscriptionRepository(firestore: sl(), uid: uid),
  );
  sl.registerFactory(() => SubscriptionBloc(repository: sl()));

  // Savings
  sl.registerLazySingleton(
    () => SavingsRepository(firestore: sl(), uid: uid),
  );
  sl.registerFactory(() => SavingsBloc(repository: sl()));
}

void _tryUnregister<T extends Object>() {
  if (sl.isRegistered<T>()) sl.unregister<T>();
}
