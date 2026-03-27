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
import '../core/enums/enums.dart';
import '../features/subscriptions/data/models/subscription_model.dart';
import '../features/subscriptions/presentation/screens/add_subscription_screen.dart';
import '../features/transactions/data/models/category_model.dart';
import '../features/transactions/data/models/transaction_model.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../features/transactions/presentation/screens/manage_categories_screen.dart';
import '../features/transactions/presentation/screens/add_edit_category_screen.dart';
import '../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../features/savings/data/models/savings_goal_model.dart';
import '../features/savings/presentation/screens/savings_goals_screen.dart';
import '../features/savings/presentation/screens/add_savings_goal_screen.dart';
import '../features/savings/presentation/screens/savings_goal_detail_screen.dart';
import 'app_shell.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String analysis = '/analysis';
  static const String bills = '/bills';
  static const String settings = '/settings';
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction';
  static const String transactionList = '/transactions';
  static const String addInstallment = '/add-installment';
  static const String installmentDetail = '/installment-detail';
  static const String addSubscription = '/add-subscription';
  static const String manageCategories = '/manage-categories';
  static const String addEditCategory = '/add-edit-category';
  static const String savingsGoals = '/savings-goals';
  static const String addSavingsGoal = '/add-savings-goal';
  static const String savingsGoalDetail = '/savings-goal-detail';

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
          path: editTransaction,
          pageBuilder: (context, state) {
            final transaction = state.extra;
            if (transaction != null && transaction is! TransactionModel) {
              return CustomTransitionPage(
                child: const Scaffold(
                  body: Center(child: Text('Invalid navigation data.')),
                ),
                transitionsBuilder: (_, animation, _, child) => child,
              );
            }
            return CustomTransitionPage(
              key: state.pageKey,
              child: AddTransactionScreen(existing: transaction as TransactionModel?),
              transitionsBuilder: (_, animation, _, child) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(0, 1), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutCubic)),
                  ),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: addInstallment,
          pageBuilder: (context, state) {
            final existing = state.extra as InstallmentModel?;
            return CustomTransitionPage(
              key: state.pageKey,
              child: AddInstallmentScreen(existing: existing),
              transitionsBuilder: (_, animation, _, child) {
                return SlideTransition(
                  position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
                  child: child,
                );
              },
            );
          },
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
          pageBuilder: (context, state) {
            final existing = state.extra as SubscriptionModel?;
            return CustomTransitionPage(
              key: state.pageKey,
              child: AddSubscriptionScreen(existing: existing),
              transitionsBuilder: (_, animation, _, child) {
                return SlideTransition(
                  position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: manageCategories,
          builder: (context, state) => const ManageCategoriesScreen(),
        ),
        GoRoute(
          path: addEditCategory,
          pageBuilder: (context, state) {
            final extra = state.extra;
            TransactionType? initialType;
            CategoryModel? existingCategory;
            
            if (extra is TransactionType) {
              initialType = extra;
            } else if (extra is CategoryModel) {
              existingCategory = extra;
            }

            return CustomTransitionPage(
              key: state.pageKey,
              child: AddEditCategoryScreen(
                initialType: initialType,
                existingCategory: existingCategory,
              ),
              transitionsBuilder: (_, animation, _, child) {
                return SlideTransition(
                  position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: savingsGoals,
          builder: (context, state) => const SavingsGoalsScreen(),
        ),
        GoRoute(
          path: addSavingsGoal,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AddSavingsGoalScreen(),
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
          path: savingsGoalDetail,
          builder: (context, state) {
            final goal = state.extra;
            if (goal is! SavingsGoalModel) {
              return const Scaffold(
                body: Center(child: Text('Invalid navigation data.')),
              );
            }
            return SavingsGoalDetailScreen(goal: goal);
          },
        ),
      ],
    );
  }
}
