import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/catalog_controller.dart';
import 'controllers/checkout_controller.dart';
import 'controllers/search_controller.dart';

import 'services/local_storage_service.dart';
import 'services/mock_data_service.dart';

import 'core/routes/router.dart';
import 'core/theme/app_theme.dart';

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = MockDataService();
    final storageService = LocalStorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            dataService: dataService,
            storageService: storageService,
          )..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CartController(storageService: storageService)
                ..restoreCart(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CatalogController(dataService: dataService)
                ..loadInitial(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SearchController(dataService: dataService),
        ),
        ChangeNotifierProvider(
          create: (_) => CheckoutController(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}