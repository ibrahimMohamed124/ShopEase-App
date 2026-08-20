import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease_mobile/cubits/auth/auth_cubit.dart';
import 'package:shopease_mobile/cubits/cart/cart_cubit.dart';
import 'package:shopease_mobile/cubits/checkout/checkout_cubit.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _zipCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _zipCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, checkoutState) {
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            if (checkoutState.orderPlaced) {
              return _OrderSuccessView(
                orderId: checkoutState.placedOrder?.id,
                onContinue: () {
                  context.read<CartCubit>().clearCart();
                  context.read<CheckoutCubit>().reset();
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                },
              );
            }

            final subtotal = cartState.totalPrice;
            final checkoutCubit = context.read<CheckoutCubit>();
            final shipping = checkoutCubit.shippingFor(subtotal);
            final tax = checkoutCubit.taxFor(subtotal);
            final total = checkoutCubit.grandTotalFor(subtotal);

            return Scaffold(
              appBar: AppBar(title: const Text('Checkout')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error
                      if (checkoutState.error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppPalette.destructive.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            checkoutState.error!,
                            style: const TextStyle(
                                color: AppPalette.destructive),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _SectionTitle(title: 'Shipping Information'),
                      const SizedBox(height: 12),
                      _Field(
                          controller: _nameCtrl, label: 'Full Name'),
                      const SizedBox(height: 12),
                      _Field(
                          controller: _emailCtrl,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _Field(
                          controller: _phoneCtrl,
                          label: 'Phone',
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      _Field(
                          controller: _addressCtrl,
                          label: 'Address'),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _Field(
                                controller: _cityCtrl,
                                label: 'City')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _Field(
                                controller: _stateCtrl,
                                label: 'State')),
                      ]),
                      const SizedBox(height: 12),
                      _Field(
                          controller: _zipCtrl,
                          label: 'ZIP Code',
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 24),

                      _SectionTitle(title: 'Payment Method'),
                      const SizedBox(height: 12),
                      _PaymentOptions(
                        selected: checkoutState.paymentMethod,
                        onChanged: (m) => context
                            .read<CheckoutCubit>()
                            .setPaymentMethod(m),
                      ),
                      const SizedBox(height: 24),

                      _SectionTitle(title: 'Order Summary'),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              ...cartState.items.map((item) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.product.name,
                                            style: const TextStyle(
                                                fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '×${item.quantity}  \$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color:
                                                  AppPalette.mutedForeground),
                                        ),
                                      ],
                                    ),
                                  )),
                              const Divider(),
                              _Row('Subtotal',
                                  '\$${subtotal.toStringAsFixed(2)}'),
                              _Row(
                                  'Shipping',
                                  shipping == 0
                                      ? 'Free'
                                      : '\$${shipping.toStringAsFixed(2)}'),
                              _Row('Tax (8%)',
                                  '\$${tax.toStringAsFixed(2)}'),
                              const Divider(),
                              _Row(
                                'Total',
                                '\$${total.toStringAsFixed(2)}',
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: checkoutState.isSubmitting
                              ? null
                              : _placeOrder,
                          child: checkoutState.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : const Text('Place Order'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cartState = context.read<CartCubit>().state;
    final checkoutCubit = context.read<CheckoutCubit>();
    final subtotal = cartState.totalPrice;
    await checkoutCubit.placeOrder(
          cartItems: cartState.items,
          total: checkoutCubit.grandTotalFor(subtotal),
          fullName: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          address: _addressCtrl.text,
          city: _cityCtrl.text,
          state: _stateCtrl.text,
          zipCode: _zipCtrl.text,
        );
  }
}

class _OrderSuccessView extends StatelessWidget {
  const _OrderSuccessView({required this.onContinue, this.orderId});

  final VoidCallback onContinue;
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppPalette.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 52),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  color: AppPalette.foreground,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Thank you for your purchase.\nYou\'ll receive a confirmation email shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppPalette.mutedForeground, height: 1.5),
              ),
              if (orderId != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Order #$orderId',
                  style: const TextStyle(
                    color: AppPalette.foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppPalette.foreground,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? '$label is required' : null,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      fontSize: bold ? 15 : 14,
      color: AppPalette.foreground,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: bold
                  ? style
                  : style.copyWith(color: AppPalette.mutedForeground)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _PaymentOptions extends StatelessWidget {
  const _PaymentOptions(
      {required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaymentTile(
          value: 'card',
          selected: selected,
          label: 'Credit / Debit Card',
          icon: Icons.credit_card_rounded,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        _PaymentTile(
          value: 'paypal',
          selected: selected,
          label: 'PayPal',
          icon: Icons.account_balance_wallet_outlined,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        _PaymentTile(
          value: 'cod',
          selected: selected,
          label: 'Cash on Delivery',
          icon: Icons.local_shipping_outlined,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.value,
    required this.selected,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  final String value;
  final String selected;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppPalette.primary.withOpacity(0.08)
              : AppPalette.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppPalette.primary : AppPalette.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppPalette.primary
                    : AppPalette.mutedForeground),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppPalette.primary
                    : AppPalette.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppPalette.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
