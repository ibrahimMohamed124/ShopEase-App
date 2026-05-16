import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/controllers/auth_controller.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/controllers/catalog_controller.dart';
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
    final authController = context.watch<AuthController>();
    final catalogController = context.watch<CatalogController>();
    final cartController = context.watch<CartController>();
    final rawName = authController.user?.name.trim() ?? '';
    final userName = rawName.isEmpty ? 'Shopper' : rawName.split(' ').first;
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 48) / 2;

    if (catalogController.isLoading && catalogController.products.isEmpty) {
      return const LoadingState(message: 'Loading products...');
    }

    if (catalogController.error != null && catalogController.products.isEmpty) {
      return ErrorState(
        message: catalogController.error!,
        onRetry: catalogController.loadInitial,
      );
    }

    return RefreshIndicator(
      color: AppPalette.primary,
      onRefresh: () => catalogController.loadInitial(isRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: AppPalette.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$userName 👋',
                      style: const TextStyle(
                        color: AppPalette.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Find your perfect item',
                      style: TextStyle(
                        color: AppPalette.foreground,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppPalette.primary,
                  backgroundColor: const Color(0xFFFFF0F0),
                ),
                onPressed: widget.onOpenCartTab,
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: Text(
                  cartController.totalItems > 0
                      ? '${cartController.totalItems} item(s)'
                      : 'Cart',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              catalogController.setSearchQuery(value);
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                widget.onOpenSearch(value.trim());
              }
            },
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon:
                  _searchQuery.trim().isEmpty
                      ? null
                      : IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          catalogController.setSearchQuery('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
            ),
          ),
          if (_searchQuery.trim().isEmpty) ...[
            const SizedBox(height: 20),
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
                itemCount: catalogController.featuredProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = catalogController.featuredProducts[index];
                  return _FeaturedCard(
                    product: product,
                    onTap: () => _openProduct(context, product.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Categories',
              style: TextStyle(
                color: AppPalette.foreground,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _AllCategoryChip(
                    selected: catalogController.selectedCategoryId == null,
                    onTap: () => catalogController.setSelectedCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...catalogController.categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        category: category,
                        selected:
                            catalogController.selectedCategoryId == category.id,
                        onTap:
                            () => catalogController.setSelectedCategory(
                              catalogController.selectedCategoryId ==
                                      category.id
                                  ? null
                                  : category.id,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.trim().isNotEmpty
                    ? 'Results for "$_searchQuery"'
                    : catalogController.selectedCategoryId != null
                    ? 'Filtered Products'
                    : 'All Products',
                style: const TextStyle(
                  color: AppPalette.foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                '${catalogController.filteredProducts.length} items',
                style: const TextStyle(
                  color: AppPalette.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (catalogController.filteredProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No products found. Try adjusting your filters.',
                  style: TextStyle(color: AppPalette.mutedForeground),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  catalogController.filteredProducts.map((product) {
                    return ProductCard(
                      product: product,
                      width: cardWidth,
                      inCart: cartController.isInCart(product.id),
                      onOpen: () => _openProduct(context, product.id),
                      onAddToCart: () => cartController.addToCart(product),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context, String productId) {
    Navigator.of(context).pushNamed('/product', arguments: productId);
  }
}

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
        child: Text(
          'All',
          style: TextStyle(
            color: selected ? Colors.white : AppPalette.foreground,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(product.imageUrl),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
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
                    horizontal: 8,
                    vertical: 3,
                  ),
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
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
