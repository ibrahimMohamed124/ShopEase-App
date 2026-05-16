import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/controllers/auth_controller.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/controllers/checkout_controller.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().user;
      if (user == null) return;

      _fullNameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();
    final checkoutController = context.watch<CheckoutController>();

    if (cartController.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 70,
                  color: AppPalette.mutedForeground,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(
                    color: AppPalette.foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add items before checking out.',
                  style: TextStyle(color: AppPalette.mutedForeground),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Cart'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final subtotal = cartController.totalPrice;
    final shipping = checkoutController.shippingFor(subtotal);
    final tax = checkoutController.taxFor(subtotal);
    final grandTotal = checkoutController.grandTotalFor(subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  const _SectionHeader(title: 'Contact Information'),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Shipping Address'),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: _requiredValidator,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(labelText: 'State'),
                          validator: _requiredValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _zipController,
                    decoration: const InputDecoration(labelText: 'ZIP Code'),
                    keyboardType: TextInputType.number,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Payment'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppPalette.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: checkoutController.paymentMethod,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'card',
                            child: Text('Credit / Debit Card'),
                          ),
                          DropdownMenuItem(
                            value: 'paypal',
                            child: Text('PayPal'),
                          ),
                          DropdownMenuItem(
                            value: 'cod',
                            child: Text('Cash on Delivery'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          checkoutController.setPaymentMethod(value);
                        },
                      ),
                    ),
                  ),
                  if (checkoutController.error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      checkoutController.error!,
                      style: const TextStyle(
                        color: AppPalette.destructive,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Subtotal',
                            value: '\$${subtotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label:
                                shipping == 0 ? 'Shipping (Free!)' : 'Shipping',
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
                            value: '\$${grandTotal.toStringAsFixed(2)}',
                            labelStyle: const TextStyle(
                              color: AppPalette.foreground,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            valueStyle: const TextStyle(
                              color: AppPalette.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                    checkoutController.isSubmitting
                        ? null
                        : () => _submit(grandTotal),
                icon:
                    checkoutController.isSubmitting
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.lock_outline_rounded),
                label: Text(
                  checkoutController.isSubmitting
                      ? 'Processing...'
                      : 'Place Order • \$${grandTotal.toStringAsFixed(2)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  Future<void> _submit(double total) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await context.read<CheckoutController>().placeOrder(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      zipCode: _zipController.text,
    );

    if (!mounted || !success) {
      return;
    }

    context.read<CartController>().clearCart();

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Order Confirmed'),
            content: Text(
              'Your payment of \$${total.toStringAsFixed(2)} was successful.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
    );

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    context.read<CheckoutController>().reset();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppPalette.foreground,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
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
