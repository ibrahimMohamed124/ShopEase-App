import 'package:flutter/material.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.inCart,
    required this.onOpen,
    required this.onAddToCart,
    this.width = 170,
  });

  final Product product;
  final bool inCart;
  final VoidCallback onOpen;
  final VoidCallback onAddToCart;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onOpen,
      child: Ink(
        width: width,
        decoration: BoxDecoration(
          color: AppPalette.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const ColoredBox(
                            color: AppPalette.muted,
                            child: Center(
                              child: Icon(Icons.image_not_supported_outlined),
                            ),
                          ),
                    ),
                  ),
                ),
                if (product.badge != null)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _badgeColor(product.badge!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                if (!product.inStock)
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0x80000000),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppPalette.foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppPalette.star,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${product.rating} (${product.reviewCount})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppPalette.mutedForeground,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppPalette.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (product.originalPrice != null)
                              Text(
                                '\$${product.originalPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppPalette.mutedForeground,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton.filled(
                        onPressed: product.inStock ? onAddToCart : null,
                        icon: Icon(
                          inCart ? Icons.check_rounded : Icons.add_rounded,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              inCart
                                  ? const Color(0xFFFFF0F0)
                                  : AppPalette.primary,
                          foregroundColor:
                              inCart ? AppPalette.primary : Colors.white,
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(String badge) {
    switch (badge) {
      case 'Sale':
        return AppPalette.primary;
      case 'New':
        return AppPalette.secondary;
      default:
        return AppPalette.star;
    }
  }
}
