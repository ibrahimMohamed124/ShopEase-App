import 'package:flutter/material.dart';

import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/register_screen.dart';
import '../../views/screens/checkout_screen.dart';
import '../../views/screens/main_scaffold.dart';
import '../../views/screens/not_found_screen.dart';
import '../../views/screens/product_details_screen.dart';
import '../../views/screens/search_screen.dart';

import 'routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainScaffold(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case AppRoutes.search:
        final query = settings.arguments as String? ?? '';

        return MaterialPageRoute(
          builder: (_) => SearchScreen(
            initialQuery: query,
          ),
        );

      case AppRoutes.product:
        final productId = settings.arguments as String?;

        if (productId == null || productId.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const NotFoundScreen(),
          );
        }

        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(
            productId: productId,
          ),
        );

      case AppRoutes.checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        );
    }
  }
}