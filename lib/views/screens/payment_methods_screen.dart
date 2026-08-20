import 'package:flutter/material.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_SavedCard> _cards = [
    _SavedCard(brand: 'Visa', lastFour: '4242', expiry: '08/26', isDefault: true),
    _SavedCard(brand: 'Mastercard', lastFour: '8912', expiry: '03/27', isDefault: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          TextButton.icon(
            onPressed: () => _showAddCardSheet(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add'),
            style: TextButton.styleFrom(foregroundColor: AppPalette.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const _SectionHeader(title: 'SAVED CARDS'),
          ..._cards.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CardTile(
                    card: entry.value,
                    onSetDefault: () {
                      setState(() {
                        for (int i = 0; i < _cards.length; i++) {
                          _cards[i] = _SavedCard(
                            brand: _cards[i].brand,
                            lastFour: _cards[i].lastFour,
                            expiry: _cards[i].expiry,
                            isDefault: i == entry.key,
                          );
                        }
                      });
                    },
                    onDelete: () {
                      setState(() => _cards.removeAt(entry.key));
                    },
                  ),
                ),
              ),
          const SizedBox(height: 8),
          const _SectionHeader(title: 'OTHER METHODS'),
          _OtherMethodTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'PayPal',
            subtitle: 'Connect your PayPal account',
            color: const Color(0xFF003087),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _OtherMethodTile(
            icon: Icons.local_shipping_outlined,
            label: 'Cash on Delivery',
            subtitle: 'Pay when your order arrives',
            color: AppPalette.success,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showAddCardSheet(context),
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('Add a New Card'),
          ),
        ],
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddCardSheet(),
    );
  }
}

class _SavedCard {
  _SavedCard({
    required this.brand,
    required this.lastFour,
    required this.expiry,
    required this.isDefault,
  });
  String brand;
  String lastFour;
  String expiry;
  bool isDefault;
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.onSetDefault,
    required this.onDelete,
  });
  final _SavedCard card;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isVisa = card.brand == 'Visa';
    final brandColor =
        isVisa ? const Color(0xFF1A1F71) : const Color(0xFFEB001B);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 30,
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppPalette.border),
              ),
              alignment: Alignment.center,
              child: Text(
                card.brand,
                style: TextStyle(
                    color: brandColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•••• •••• •••• ${card.lastFour}',
                    style: const TextStyle(
                        color: AppPalette.foreground,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Expires ${card.expiry}',
                    style: const TextStyle(
                        color: AppPalette.mutedForeground, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (card.isDefault)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppPalette.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                      color: AppPalette.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              )
            else
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (value) {
                  if (value == 'default') onSetDefault();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'default', child: Text('Set as default')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Remove',
                        style: TextStyle(color: AppPalette.destructive)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _OtherMethodTile extends StatelessWidget {
  const _OtherMethodTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppPalette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppPalette.foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppPalette.mutedForeground, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add New Card',
                    style: TextStyle(
                        color: AppPalette.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'Card Number',
                  prefixIcon: Icon(Icons.credit_card_rounded)),
              validator: (v) =>
                  (v == null || v.trim().length < 16) ? 'Enter a valid card number.' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'MM/YY'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'CVV'),
                    validator: (v) =>
                        (v == null || v.trim().length < 3) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Card added successfully.')),
                    );
                  }
                },
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Add Card'),
              ),
            ),
          ],
        ),
      ),
    );
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
          color: AppPalette.mutedForeground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
