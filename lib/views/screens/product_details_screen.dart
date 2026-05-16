import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/controllers/catalog_controller.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/models/product.dart';
import 'package:shopease_mobile/views/widgets/error_state.dart';
import 'package:shopease_mobile/views/widgets/loading_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<Product?> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = context.read<CatalogController>().fetchProductById(
      widget.productId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState(message: 'Loading product...');
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _productFuture = context
                      .read<CatalogController>()
                      .fetchProductById(widget.productId);
                });
              },
            );
          }

          final product = snapshot.data;
          if (product == null) {
            return const ErrorState(message: 'Product not found.');
          }

          final inCart = cartController.isInCart(product.id);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const ColoredBox(
                                color: AppPalette.muted,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (product.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppPalette.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              product.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Icon(
                          product.inStock
                              ? Icons.check_circle_outline_rounded
                              : Icons.remove_circle_outline_rounded,
                          color:
                              product.inStock
                                  ? AppPalette.success
                                  : AppPalette.destructive,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          product.inStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            color:
                                product.inStock
                                    ? AppPalette.success
                                    : AppPalette.destructive,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: AppPalette.foreground,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppPalette.star,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating} (${product.reviewCount} reviews)',
                          style: const TextStyle(
                            color: AppPalette.mutedForeground,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppPalette.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        ),
                        if (product.originalPrice != null) ...[
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '\$${product.originalPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppPalette.mutedForeground,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: AppPalette.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: AppPalette.mutedForeground,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: AppPalette.card,
                    border: Border(top: BorderSide(color: AppPalette.border)),
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        product.inStock
                            ? () {
                              cartController.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    inCart
                                        ? '${product.name} quantity increased in cart.'
                                        : '${product.name} added to cart.',
                                  ),
                                ),
                              );
                            }
                            : null,
                    icon: Icon(
                      inCart
                          ? Icons.check_rounded
                          : Icons.add_shopping_cart_rounded,
                    ),
                    label: Text(inCart ? 'Added to Cart' : 'Add to Cart'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
