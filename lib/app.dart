import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/finance/presentation/bloc/finance_bloc.dart';
import 'features/finance/presentation/bloc/finance_event.dart';
import 'features/finance/presentation/pages/main_navigation_page.dart';
import 'features/savings/presentation/bloc/savings_bloc.dart';

class BeeSavingApp extends StatelessWidget {
  const BeeSavingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<FinanceBloc>(
          create: (context) => sl<FinanceBloc>()..add(FetchTransactionsEvent()),
        ),
        BlocProvider<SavingsBloc>(
          create: (context) => sl<SavingsBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'BeeSaving',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('vi', ''),
        ],
        home: const SplashPage(),
      ),
    );
  }
}
