import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import '../core/locale/locale_cubit.dart';
import '../core/theme/app_theme.dart';
import '../di/injection_container.dart';
import '../features/analysis/presentation/bloc/analysis_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/installments/presentation/bloc/installment_bloc.dart';
import '../features/savings/presentation/bloc/savings_bloc.dart';
import '../features/subscriptions/presentation/bloc/subscription_bloc.dart';
import '../features/transactions/presentation/bloc/category_bloc.dart';
import '../features/transactions/presentation/bloc/transaction_bloc.dart';
import 'routes.dart';

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocaleCubit(),
      child: BlocProvider(
        create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isAuthenticated = state is AuthAuthenticated;
            final router = AppRoutes.router(isAuthenticated: isAuthenticated);

            if (isAuthenticated) {
              registerUserDependencies(state.user.uid);

              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                      create: (_) =>
                          sl<TransactionBloc>()..add(TransactionStarted())),
                  BlocProvider(
                      create: (_) =>
                          sl<CategoryBloc>()..add(CategoryStarted())),
                  BlocProvider(create: (_) => sl<AnalysisBloc>()),
                  BlocProvider(
                      create: (_) =>
                          sl<InstallmentBloc>()..add(InstallmentStarted())),
                  BlocProvider(
                      create: (_) =>
                          sl<SubscriptionBloc>()..add(SubscriptionStarted())),
                  BlocProvider(
                      create: (_) =>
                          sl<SavingsBloc>()..add(SavingsStarted())),
                ],
                child: _buildApp(router),
              );
            }

            return _buildApp(router);
          },
        ),
      ),
    );
  }

  Widget _buildApp(GoRouter router) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) => MaterialApp.router(
        title: 'FinTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('id')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
  }
}
