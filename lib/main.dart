import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/data/datasources/auth_local_datasource.dart';
import 'package:cashwave_mobile/data/datasources/auth_remote_datasource.dart';
import 'package:cashwave_mobile/data/datasources/dashboard_remote_datasource.dart';
import 'package:cashwave_mobile/data/datasources/order_remote_datasource.dart';
import 'package:cashwave_mobile/data/datasources/product_local_datasource.dart';
import 'package:cashwave_mobile/data/datasources/product_remote_datasource.dart';
import 'package:cashwave_mobile/data/datasources/report_remote_datasource.dart';

import 'package:cashwave_mobile/presentation/auth/pages/login_page.dart';
import 'package:cashwave_mobile/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:cashwave_mobile/presentation/draft_order/bloc/draft_order/draft_order_bloc.dart';
import 'package:cashwave_mobile/presentation/history/bloc/history/history_bloc.dart';
import 'package:cashwave_mobile/presentation/home/bloc/category/category_bloc.dart';
import 'package:cashwave_mobile/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:cashwave_mobile/presentation/home/bloc/product/product_bloc.dart';
import 'package:cashwave_mobile/presentation/home/pages/dashboard_page.dart';
import 'package:cashwave_mobile/presentation/order/bloc/order/order_bloc.dart';
import 'package:cashwave_mobile/presentation/setting/bloc/report/close_cashier/close_cashier_bloc.dart';
import 'package:cashwave_mobile/presentation/setting/bloc/report/product_sales/product_sales_bloc.dart';
import 'package:cashwave_mobile/presentation/setting/bloc/report/summary/summary_bloc.dart';
import 'package:cashwave_mobile/presentation/setting/bloc/sync_order/sync_order_bloc.dart';

import 'package:cashwave_mobile/presentation/auth/bloc/login/login_bloc.dart';
import 'package:cashwave_mobile/presentation/home/bloc/logout/logout_bloc.dart';

import 'package:google_fonts/google_fonts.dart';

import 'core/constants/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);

    debugPrint('📦 Event: ${bloc.runtimeType} → $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    debugPrint('🔄 Transition: ${bloc.runtimeType} → $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('❌ Error in ${bloc.runtimeType}: $error');

    super.onError(bloc, error, stackTrace);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ============================================================
        // AUTH
        // ============================================================

        BlocProvider(create: (context) => LoginBloc(AuthRemoteDatasource())),

        BlocProvider(create: (context) => LogoutBloc(AuthRemoteDatasource())),

        // ============================================================
        // PRODUCT
        // ============================================================
        BlocProvider(
          create: (context) =>
              ProductBloc(ProductRemoteDatasource())
                ..add(const ProductEvent.fetchLocal()),
        ),

        // ============================================================
        // DASHBOARD
        // ============================================================
        BlocProvider(
          create: (context) =>
              DashboardBloc(DashboardRemoteDatasource())
                ..add(const DashboardEvent.fetch()),
        ),

        // ============================================================
        // CHECKOUT
        // ============================================================
        BlocProvider(create: (context) => CheckoutBloc()),

        // ============================================================
        // ORDER
        // ============================================================
        BlocProvider(create: (context) => OrderBloc()),

        // ============================================================
        // HISTORY
        // ============================================================
        BlocProvider(create: (context) => HistoryBloc()),

        // ============================================================
        // SYNC ORDER
        // ============================================================
        BlocProvider(
          create: (context) => SyncOrderBloc(OrderRemoteDatasource()),
        ),

        // ============================================================
        // CATEGORY
        // ============================================================
        BlocProvider(
          create: (context) => CategoryBloc(ProductRemoteDatasource()),
        ),

        // ============================================================
        // DRAFT ORDER
        // ============================================================
        BlocProvider(
          create: (context) => DraftOrderBloc(ProductLocalDatasource.instance),
        ),

        // ============================================================
        // REPORT - SUMMARY
        // ============================================================
        BlocProvider(
          create: (context) => SummaryBloc(ReportRemoteDatasource()),
        ),

        // ============================================================
        // REPORT - PRODUCT SALES
        // ============================================================
        BlocProvider(
          create: (context) => ProductSalesBloc(ReportRemoteDatasource()),
        ),

        // ============================================================
        // REPORT - CLOSE CASHIER
        // ============================================================
        BlocProvider(
          create: (context) => CloseCashierBloc(ReportRemoteDatasource()),
        ),
      ],

      // ==============================================================
      // APP
      // ==============================================================
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'CashWave App',

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),

          useMaterial3: true,

          textTheme: GoogleFonts.quicksandTextTheme(
            Theme.of(context).textTheme,
          ),

          appBarTheme: AppBarTheme(
            color: AppColors.primary,

            elevation: 0,

            titleTextStyle: GoogleFonts.quicksand(
              color: AppColors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),

            iconTheme: const IconThemeData(color: AppColors.primary),
          ),
        ),

        // ============================================================
        // GLOBAL ERROR HANDLING
        // ============================================================
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Terjadi error:\n\n'
                    '${details.exceptionAsString()}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          };

          return child!;
        },

        // ============================================================
        // HOME / LOGIN
        // ============================================================
        home: FutureBuilder<bool>(
          future: AuthLocalDatasource().isAuth(),

          builder: (context, snapshot) {
            // --------------------------------------------------------
            // LOADING
            // --------------------------------------------------------

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // --------------------------------------------------------
            // AUTHENTICATED
            // --------------------------------------------------------

            if (snapshot.hasData && snapshot.data == true) {
              return const DashboardPage();
            }

            // --------------------------------------------------------
            // NOT AUTHENTICATED
            // --------------------------------------------------------

            return const LoginPage();
          },
        ),
      ),
    );
  }
}
