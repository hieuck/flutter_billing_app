import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';
import 'features/expense/presentation/bloc/expense_bloc.dart';
import 'features/ai_order/presentation/bloc/ai_order_bloc.dart';
import 'features/ai_assistant/presentation/bloc/assistant_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? initError;
  try {
    await HiveDatabase.init();
    await di.init();
  } catch (e) {
    initError = e.toString();
    debugPrint('Init error: $e');
  }
  runApp(MyApp(initError: initError));
}

class MyApp extends StatelessWidget {
  final String? initError;
  const MyApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Error:\n$initError',
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ),
        ),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
            create: (context) => di.sl<ProductBloc>()..add(LoadProducts())),
        BlocProvider<ShopBloc>(
            create: (context) => di.sl<ShopBloc>()..add(LoadShopEvent())),
        BlocProvider<BillingBloc>(
            create: (context) => BillingBloc(
          getProductByBarcodeUseCase: di.sl(),
          invoiceRepository: di.sl(),
        )),
        BlocProvider<PrinterBloc>(
            create: (context) => di.sl<PrinterBloc>()..add(InitPrinterEvent())),
        BlocProvider<ExpenseBloc>(
            create: (context) => di.sl<ExpenseBloc>()),
        BlocProvider<AiOrderBloc>(
            create: (context) => di.sl<AiOrderBloc>()),
        BlocProvider<AssistantBloc>(
            create: (context) => di.sl<AssistantBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Billing App',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('vi'),
        ],
        locale: const Locale('vi'),
      ),
    );
  }
}
