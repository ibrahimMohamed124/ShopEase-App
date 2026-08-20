import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease_mobile/cubits/catalog/catalog_cubit.dart';
import 'package:shopease_mobile/core/routes/routes.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/core/utils/icon_mapper.dart';
import 'package:shopease_mobile/models/category.dart';
import 'package:shopease_mobile/views/widgets/error_state.dart';
import 'package:shopease_mobile/views/widgets/loading_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    final value = int.tryParse('FF$clean', radix: 16) ?? 0xFF6C63FF;
    return Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state.isLoading && state.categories.isEmpty) {
          return const Scaffold(
            body: LoadingState(message: 'Loading categories...'),
          );
        }

        if (state.error != null && state.categories.isEmpty) {
          return Scaffold(
            body: ErrorState(
              message: state.error!,
              onRetry: () => context.read<CatalogCubit>().loadInitial(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppPalette.background,
          body: CustomScrollView(
            slivers: [
              // ── SliverAppBar ────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppPalette.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    'Shop by Category',
                    style: TextStyle(
                      color: AppPalette.foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  background: Container(
                    color: AppPalette.background,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      '${state.categories.length} categories',
                      style: const TextStyle(
                        color: AppPalette.mutedForeground,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Category Grid ────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = state.categories[index];
                      return _CategoryCard(
                        category: cat,
                        accentColor: _hexToColor(cat.colorHex),
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.categoryProducts,
                          arguments: cat,
                        ),
                      );
                    },
                    childCount: state.categories.length,
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

// ── Category Card Widget ──────────────────────────────────────────────────────

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.category,
    required this.accentColor,
    required this.onTap,
  });

  final Category category;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final accent = widget.accentColor;
    final lightAccent = accent.withOpacity(0.12);
    final hasImage = cat.imageUrl.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: AppPalette.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppPalette.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image Area ─────────────────────────────────────────
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background
                    if (hasImage)
                      Image.network(
                        cat.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _iconBackground(lightAccent, accent),
                      )
                    else
                      _iconBackground(lightAccent, accent),

                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.35),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),

                    // Product count badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '${cat.productCount} items',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Label Area ─────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: AppPalette.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          color: AppPalette.foreground,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Explore →',
                              style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBackground(Color lightAccent, Color accent) {
    return Container(
      color: lightAccent,
      alignment: Alignment.center,
      child: Icon(
        IconMapper.forCategory(widget.category.name),
        size: 52,
        color: accent.withOpacity(0.7),
      ),
    );
  }
}
