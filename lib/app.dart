import 'package:flutter/material.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/views/screens/auth/login_screen.dart';
import 'package:shopease_mobile/views/screens/auth/register_screen.dart';
import 'package:shopease_mobile/views/screens/checkout_screen.dart';
import 'package:shopease_mobile/views/screens/main_scaffold.dart';
import 'package:shopease_mobile/views/screens/not_found_screen.dart';
import 'package:shopease_mobile/views/screens/product_details_screen.dart';
import 'package:shopease_mobile/views/screens/search_screen.dart';

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const MainScaffold());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/search':
            final query =
                settings.arguments is String
                    ? settings.arguments as String
                    : '';
            return MaterialPageRoute(
              builder: (_) => SearchScreen(initialQuery: query),
            );
          case '/product':
            final productId =
                settings.arguments is String
                    ? settings.arguments as String
                    : null;
            if (productId == null || productId.isEmpty) {
              return MaterialPageRoute(builder: (_) => const NotFoundScreen());
            }
            return MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: productId),
            );
          case '/checkout':
            return MaterialPageRoute(builder: (_) => const CheckoutScreen());
          default:
            return MaterialPageRoute(builder: (_) => const NotFoundScreen());
        }
      },
    );
  }
}
