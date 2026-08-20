import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease_mobile/cubits/auth/auth_cubit.dart';
import 'package:shopease_mobile/cubits/cart/cart_cubit.dart';
import 'package:shopease_mobile/cubits/catalog/catalog_cubit.dart';
import 'package:shopease_mobile/core/routes/routes.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/models/product.dart';
import 'package:shopease_mobile/views/widgets/category_chip.dart';
import 'package:shopease_mobile/views/widgets/error_state.dart';
import 'package:shopease_mobile/views/widgets/loading_state.dart';
import 'package:shopease_mobile/views/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenSearch,
    required this.onOpenCartTab,
  });

  final ValueChanged<String> onOpenSearch;
  final VoidCallback onOpenCartTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, catalogState) {
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final rawName = authState.user?.name.trim() ?? '';
                final userName =
                    rawName.isEmpty ? 'Shopper' : rawName.split(' ').first;
                final width = MediaQuery.of(context).size.width;
                final cardWidth = (width - 48) / 2;

                if (catalogState.isLoading && catalogState.products.isEmpty) {
                  return const LoadingState(message: 'Loading products...');
                }

                if (catalogState.error != null &&
                    catalogState.products.isEmpty) {
                  return ErrorState(
                    message: catalogState.error!,
                    onRetry: () =>
                        context.read<CatalogCubit>().loadInitial(),
                  );
                }

                return RefreshIndicator(
                  color: AppPalette.primary,
                  onRefresh: () => context
                      .read<CatalogCubit>()
                      .loadInitial(isRefresh: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      _HomeHeader(
                        userName: userName,
                        cartCount: cartState.totalItems,
                        onOpenCart: widget.onOpenCartTab,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Transform.translate(
                          offset: const Offset(0, -22),
                          child: _SearchBar(
                            query: _searchQuery,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                              context
                                  .read<CatalogCubit>()
                                  .setSearchQuery(value);
                            },
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                widget.onOpenSearch(value.trim());
                              }
                            },
                            onClear: () {
                              setState(() => _searchQuery = '');
                              context
                                  .read<CatalogCubit>()
                                  .setSearchQuery('');
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_searchQuery.trim().isEmpty) ...[
                              const Text(
                                'Featured',
                                style: TextStyle(
                                  color: AppPalette.foreground,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 170,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      catalogState.featuredProducts.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final product =
                                        catalogState.featuredProducts[index];
                                    return _FeaturedCard(
                                      product: product,
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(AppRoutes.product,
                                              arguments: product.id),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Categories row
                              if (catalogState.categories.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Shop by Category',
                                      style: TextStyle(
                                        color: AppPalette.foreground,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 38,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    // [جديد] +1 عشان "All" chip في الأول
                                    itemCount:
                                        catalogState.categories.length + 1,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      // [جديد] أول عنصر بيبقى "All" —
                                      // بيرجّع selectedCategoryId لـnull
                                      // عشان يمسح الفلتر ويعرض كل المنتجات
                                      if (index == 0) {
                                        return _AllCategoryChip(
                                          selected: catalogState
                                                  .selectedCategoryId ==
                                              null,
                                          onTap: () => context
                                              .read<CatalogCubit>()
                                              .setSelectedCategory(null),
                                        );
                                      }
                                      final cat = catalogState
                                          .categories[index - 1];
                                      return CategoryChip(
                                        category: cat,
                                        selected:
                                            catalogState.selectedCategoryId ==
                                                cat.id,
                                        onTap: () =>
                                            context
                                                .read<CatalogCubit>()
                                                .setSelectedCategory(
                                                  catalogState
                                                              .selectedCategoryId ==
                                                          cat.id
                                                      ? null
                                                      : cat.id,
                                                ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              const Text(
                                'All Products',
                                style: TextStyle(
                                  color: AppPalette.foreground,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],

                            // Products grid
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: catalogState.filteredProducts
                                  .map((product) => ProductCard(
                                        product: product,
                                        width: cardWidth,
                                        inCart:
                                            cartState.isInCart(product.id),
                                        onOpen: () =>
                                            Navigator.of(context).pushNamed(
                                          AppRoutes.product,
                                          arguments: product.id,
                                        ),
                                        onAddToCart: () => context
                                            .read<CartCubit>()
                                            .addToCart(product),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.cartCount,
    required this.onOpenCart,
  });

  final String userName;
  final int cartCount;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(36),
        bottomRight: Radius.circular(36),
      ),
      child: Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPalette.primary, AppPalette.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 36),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'What are you looking for today?',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onOpenCart,
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white, size: 26),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      cartCount > 9 ? '9+' : '$cartCount',
                      style: const TextStyle(
                        color: AppPalette.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),   // Container
    );   // ClipRRect
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      shadowColor: Colors.black12,
      child: TextField(
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppPalette.card,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              product.imageUrl,
              width: 200,
              height: 170,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 200,
                height: 170,
                color: AppPalette.muted,
              ),
            ),
            Container(
              width: 200,
              height: 170,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xC0000000)],
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (product.badge != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppPalette.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style:
                        const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// [جديد] — نفس شكل CategoryChip بالظبط، لكن ثابت ("All") بدل ما يتبني من
// Category؛ بيمسح selectedCategoryId عشان يرجّع عرض كل المنتجات تاني
class _AllCategoryChip extends StatelessWidget {
  const _AllCategoryChip({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : AppPalette.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppPalette.primary : AppPalette.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apps_rounded,
              size: 15,
              color: selected ? Colors.white : AppPalette.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'All',
              style: TextStyle(
                color: selected ? Colors.white : AppPalette.foreground,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}