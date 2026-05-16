import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/views/widgets/loading_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.onContinueShopping,
    required this.onCheckout,
  });

  final VoidCallback onContinueShopping;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();

    if (cartController.isLoading) {
      return const LoadingState(message: 'Loading cart...');
    }

    if (cartController.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Cart')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 72,
                  color: AppPalette.mutedForeground,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(
                    color: AppPalette.foreground,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add products from Home or Categories.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppPalette.mutedForeground),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: onContinueShopping,
                  child: const Text('Start Shopping'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final subtotal = cartController.totalPrice;
    final shipping = subtotal > 100 ? 0.0 : 9.99;
    final tax = subtotal * 0.08;
    final total = subtotal + shipping + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          TextButton(
            onPressed: cartController.clearCart,
            child: const Text(
              'Clear',
              style: TextStyle(color: AppPalette.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              itemCount: cartController.items.length,
              itemBuilder: (context, index) {
                final item = cartController.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: ColoredBox(
                                    color: AppPalette.muted,
                                    child: Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppPalette.foreground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$${item.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppPalette.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove_rounded,
                                    onTap:
                                        () => cartController.updateQuantity(
                                          item.product.id,
                                          item.quantity - 1,
                                        ),
                                  ),
                                  SizedBox(
                                    width: 34,
                                    child: Text(
                                      '${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppPalette.foreground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add_rounded,
                                    onTap:
                                        () => cartController.updateQuantity(
                                          item.product.id,
                                          item.quantity + 1,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed:
                              () => cartController.removeFromCart(
                                item.product.id,
                              ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppPalette.destructive,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppPalette.card,
              border: Border(top: BorderSide(color: AppPalette.border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Subtotal',
                  value: '\$${subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 6),
                _SummaryRow(
                  label: shipping == 0 ? 'Shipping (Free!)' : 'Shipping',
                  value:
                      shipping == 0
                          ? 'FREE'
                          : '\$${shipping.toStringAsFixed(2)}',
                  valueColor:
                      shipping == 0
                          ? AppPalette.success
                          : AppPalette.foreground,
                ),
                const SizedBox(height: 6),
                _SummaryRow(
                  label: 'Tax (8%)',
                  value: '\$${tax.toStringAsFixed(2)}',
                ),
                const Divider(height: 20),
                _SummaryRow(
                  label: 'Total',
                  value: '\$${total.toStringAsFixed(2)}',
                  labelStyle: const TextStyle(
                    color: AppPalette.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  valueStyle: const TextStyle(
                    color: AppPalette.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtotal <= 100)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Add \$${(100 - subtotal).toStringAsFixed(2)} more for free shipping.',
                      style: const TextStyle(
                        color: AppPalette.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCheckout,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      'Proceed to Checkout • \$${total.toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Ink(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppPalette.muted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppPalette.foreground),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              const TextStyle(color: AppPalette.mutedForeground, fontSize: 14),
        ),
        Text(
          value,
          style:
              valueStyle ??
              TextStyle(
                color: valueColor ?? AppPalette.foreground,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
