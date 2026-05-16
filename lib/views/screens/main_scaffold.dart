import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/views/screens/cart_screen.dart';
import 'package:shopease_mobile/views/screens/categories_screen.dart';
import 'package:shopease_mobile/views/screens/home_screen.dart';
import 'package:shopease_mobile/views/screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartController, int>(
      (cart) => cart.totalItems,
    );

    final screens = <Widget>[
      HomeScreen(
        onOpenSearch:
            (query) =>
                Navigator.of(context).pushNamed('/search', arguments: query),
        onOpenCartTab: () => _switchTab(2),
      ),
      const CategoriesScreen(),
      CartScreen(
        onContinueShopping: () => _switchTab(0),
        onCheckout: () => Navigator.of(context).pushNamed('/checkout'),
      ),
      ProfileScreen(
        onOpenLogin: () => Navigator.of(context).pushNamed('/login'),
        onOpenRegister: () => Navigator.of(context).pushNamed('/register'),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        height: 70,
        backgroundColor: AppPalette.card,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: -9,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        cartCount > 99 ? '99+' : '$cartCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            selectedIcon: const Icon(Icons.shopping_cart_rounded),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
