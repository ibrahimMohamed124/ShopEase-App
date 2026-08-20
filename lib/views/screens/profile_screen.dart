import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease_mobile/core/config/app_config.dart';
import 'package:shopease_mobile/cubits/auth/auth_cubit.dart';
import 'package:shopease_mobile/cubits/cart/cart_cubit.dart';
import 'package:shopease_mobile/core/routes/routes.dart';
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final cartItems = context.select<CartCubit, int>(
          (cubit) => cubit.state.totalItems,
        );

        if (authState.isLoading) {
          return const LoadingState(message: 'Loading profile...');
        }

        if (!authState.isAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppPalette.primary, AppPalette.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppPalette.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      'Access your orders, saved items,\nand exclusive deals.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppPalette.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
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

        final user = authState.user!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                    child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppPalette.primary, AppPalette.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            image: user.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      '${AppConfig.apiBaseUrl}${user.avatarUrl}',
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: user.avatarUrl == null
                              ? Center(
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),             // Container
                  ),             // ClipRRect
                ),               // FlexibleSpaceBar
              ),                 // SliverAppBar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _ProfileCard(
                        children: [
                          _ProfileTile(
                            icon: Icons.shopping_bag_outlined,
                            label: 'My Orders',
                            badge: null,
                            onTap: () =>
                                Navigator.of(context).pushNamed(AppRoutes.orders),
                          ),
                          _ProfileTile(
                            icon: Icons.favorite_border_rounded,
                            label: 'Wishlist',
                            badge: null,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.wishlist),
                          ),
                          _ProfileTile(
                            icon: Icons.shopping_cart_outlined,
                            label: 'Cart',
                            badge: cartItems > 0 ? '$cartItems' : null,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ProfileCard(
                        children: [
                          _ProfileTile(
                            icon: Icons.person_outline_rounded,
                            label: 'Edit Profile',
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.editProfile),
                          ),
                          _ProfileTile(
                            icon: Icons.location_on_outlined,
                            label: 'Shipping Address',
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.shippingAddress),
                          ),
                          _ProfileTile(
                            icon: Icons.credit_card_outlined,
                            label: 'Payment Methods',
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.paymentMethods),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ProfileCard(
                        children: [
                          _ProfileTile(
                            icon: Icons.assignment_return_outlined,
                            label: 'Returns & Refunds',
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.returns),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ProfileCard(
                        children: [
                          _ProfileTile(
                            icon: Icons.logout_rounded,
                            label: 'Sign Out',
                            labelColor: AppPalette.destructive,
                            iconColor: AppPalette.destructive,
                            onTap: () async {
                              await context.read<AuthCubit>().logout();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: children
            .map((child) => child)
            .expand((child) sync* {
              yield child;
              if (child != children.last) {
                yield const Divider(height: 1, indent: 56);
              }
            })
            .toList(),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? AppPalette.foreground,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? AppPalette.foreground,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppPalette.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : const Icon(Icons.chevron_right_rounded,
              color: AppPalette.mutedForeground),
    );
  }
}