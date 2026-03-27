import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/analysis/presentation/screens/analysis_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/bills/presentation/screens/bills_screen.dart';
import '../features/home/presentation/screens/dashboard_screen.dart';
import '../features/installments/data/models/installment_model.dart';
import '../features/installments/presentation/screens/add_installment_screen.dart';
import '../features/installments/presentation/screens/installment_detail_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/subscriptions/presentation/screens/add_subscription_screen.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../features/transactions/presentation/screens/transaction_list_screen.dart';
import 'app_shell.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String analysis = '/analysis';
  static const String bills = '/bills';
  static const String settings = '/settings';
  static const String addTransaction = '/add-transaction';
  static const String transactionList = '/transactions';
  static const String addInstallment = '/add-installment';
  static const String installmentDetail = '/installment-detail';
  static const String addSubscription = '/add-subscription';

  static GoRouter router({required bool isAuthenticated}) {
    return GoRouter(
      initialLocation: home,
      redirect: (context, state) {
        final loggingIn = state.matchedLocation == login;
        if (!isAuthenticated) return loggingIn ? null : login;
        if (loggingIn) return home;
        return null;
      },
      routes: [
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  path: home,
                  builder: (context, state) => const DashboardScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: analysis,
                  builder: (context, state) => const AnalysisScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: bills,
                  builder: (context, state) => const BillsScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: settings,
                  builder: (context, state) => const SettingsScreen()),
            ]),
          ],
        ),
        GoRoute(
          path: transactionList,
          builder: (context, state) => const TransactionListScreen(),
        ),
        GoRoute(
          path: addTransaction,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AddTransactionScreen(),
            transitionsBuilder: (_, animation, _, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 1), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: addInstallment,
          builder: (context, state) => const AddInstallmentScreen(),
        ),
        GoRoute(
          path: installmentDetail,
          builder: (context, state) {
            final installment = state.extra;
            if (installment is! InstallmentModel) {
              return const Scaffold(
                body: Center(child: Text('Invalid navigation data.')),
              );
            }
            return InstallmentDetailScreen(installment: installment);
          },
        ),
        GoRoute(
          path: addSubscription,
          builder: (context, state) => const AddSubscriptionScreen(),
        ),
      ],
    );
  }
}
