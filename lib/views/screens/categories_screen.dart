import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/controllers/catalog_controller.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/core/utils/icon_mapper.dart';
import 'package:shopease_mobile/models/category.dart';
import 'package:shopease_mobile/views/widgets/error_state.dart';
import 'package:shopease_mobile/views/widgets/loading_state.dart';
import 'package:shopease_mobile/views/widgets/product_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final catalogController = context.watch<CatalogController>();
    final cartController = context.watch<CartController>();

    if (catalogController.isLoading && catalogController.categories.isEmpty) {
      return const LoadingState(message: 'Loading categories...');
    }

    if (catalogController.error != null &&
        catalogController.categories.isEmpty) {
      return ErrorState(
        message: catalogController.error!,
        onRetry: catalogController.loadInitial,
      );
    }

    if (_selectedCategory == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: catalogController.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = catalogController.categories[index];
            return _CategoryTile(
              category: category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
            );
          },
        ),
      );
    }

    final categoryProducts = catalogController.productsByCategory(
      _selectedCategory!.id,
    );
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 48) / 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            setState(() {
              _selectedCategory = null;
            });
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(_selectedCategory!.name),
      ),
      body:
          categoryProducts.isEmpty
              ? const Center(
                child: Text(
                  'No products found in this category.',
                  style: TextStyle(color: AppPalette.mutedForeground),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      categoryProducts.map((product) {
                        return ProductCard(
                          product: product,
                          width: cardWidth,
                          inCart: cartController.isInCart(product.id),
                          onOpen:
                              () => Navigator.of(
                                context,
                              ).pushNamed('/product', arguments: product.id),
                          onAddToCart: () => cartController.addToCart(product),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _colorFromHex(category.colorHex);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppPalette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(mapCategoryIcon(category.icon), color: categoryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: AppPalette.foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.productCount} products',
                    style: const TextStyle(
                      color: AppPalette.mutedForeground,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final raw = hex.replaceFirst('#', '');
    return Color(int.parse('FF$raw', radix: 16));
  }
}
