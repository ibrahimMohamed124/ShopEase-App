import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/app.dart';
import 'package:shopease_mobile/controllers/auth_controller.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/controllers/catalog_controller.dart';
import 'package:shopease_mobile/controllers/checkout_controller.dart';
import 'package:shopease_mobile/controllers/search_controller.dart';
import 'package:shopease_mobile/services/local_storage_service.dart';
import 'package:shopease_mobile/services/mock_data_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dataService = MockDataService();
  final storageService = LocalStorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) => AuthController(
                dataService: dataService,
                storageService: storageService,
              )..restoreSession(),
        ),
        ChangeNotifierProvider(
          create:
              (_) =>
                  CartController(storageService: storageService)..restoreCart(),
        ),
        ChangeNotifierProvider(
          create:
              (_) => CatalogController(dataService: dataService)..loadInitial(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchController(dataService: dataService),
        ),
        ChangeNotifierProvider(create: (_) => CheckoutController()),
      ],
      child: const ShopEaseApp(),
    ),
  );
}
