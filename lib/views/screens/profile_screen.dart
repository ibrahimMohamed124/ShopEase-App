import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/controllers/auth_controller.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/views/widgets/loading_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onOpenLogin,
    required this.onOpenRegister,
  });

  final VoidCallback onOpenLogin;
  final VoidCallback onOpenRegister;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final cartItems = context.select<CartController, int>(
      (cart) => cart.totalItems,
    );

    if (authController.isLoading) {
      return const LoadingState(message: 'Loading profile...');
    }

    if (!authController.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppPalette.muted,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: AppPalette.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to your account',
                  style: TextStyle(
                    color: AppPalette.foreground,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access your orders, saved items, and exclusive deals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppPalette.mutedForeground),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onOpenLogin,
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onOpenRegister,
                    child: const Text('Create Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = authController.user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppPalette.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0x44FFFFFF),
                  child: Text(
                    user.name.isEmpty ? 'U' : user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Color(0xD9FFFFFF),
                    fontSize: 13,
                  ),
                ),
                if ((user.phone ?? '').isNotEmpty)
                  Text(
                    user.phone!,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatItem(label: 'Orders', value: '12'),
                    const _StatDivider(),
                    _StatItem(label: 'In Cart', value: '$cartItems'),
                    const _StatDivider(),
                    const _StatItem(label: 'Wishlist', value: '5'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle(text: 'Account'),
          _ProfileTile(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            subtitle: 'Update your personal info',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.map_outlined,
            label: 'Shipping Address',
            subtitle:
                user.address?.isNotEmpty == true
                    ? user.address!
                    : 'Add an address',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.credit_card_outlined,
            label: 'Payment Methods',
            subtitle: 'Manage cards and wallets',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          const _SectionTitle(text: 'Orders'),
          _ProfileTile(
            icon: Icons.inventory_2_outlined,
            label: 'My Orders',
            subtitle: 'Track and manage orders',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.favorite_border_rounded,
            label: 'Wishlist',
            subtitle: 'Items you have saved',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.refresh_rounded,
            label: 'Returns & Refunds',
            subtitle: 'Start a return',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _ProfileTile(
            icon: Icons.logout_rounded,
            iconColor: AppPalette.destructive,
            label: 'Sign Out',
            labelColor: AppPalette.destructive,
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(color: AppPalette.destructive),
                          ),
                        ),
                      ],
                    ),
              );
              if (shouldLogout == true && context.mounted) {
                await context.read<AuthController>().logout();
              }
            },
          ),
          const SizedBox(height: 10),
          const Text(
            'ShopEase v1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppPalette.mutedForeground, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1,
      height: 34,
      child: DecoratedBox(decoration: BoxDecoration(color: Color(0x80FFFFFF))),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
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

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (iconColor ?? AppPalette.primary).withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor ?? AppPalette.primary, size: 19),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: labelColor ?? AppPalette.foreground,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle:
            subtitle == null
                ? null
                : Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppPalette.mutedForeground,
                    fontSize: 12,
                  ),
                ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
