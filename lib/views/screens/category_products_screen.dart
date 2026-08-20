import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease_mobile/core/dependency_injection/di.dart'; // [تعديل] عشان الوصول لـ subcategoryController
import 'package:shopease_mobile/core/routes/routes.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/cubits/cart/cart_cubit.dart';
import 'package:shopease_mobile/cubits/catalog/catalog_cubit.dart';
import 'package:shopease_mobile/cubits/subcategory/subcategory_cubit.dart'; // [تعديل] جديد
import 'package:shopease_mobile/models/category.dart';
import 'package:shopease_mobile/models/product.dart';
import 'package:shopease_mobile/views/widgets/product_card.dart';

// ── Sort options ──────────────────────────────────────────────────────────────

enum _SortOption {
  popular('Most Popular'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low'),
  rating('Top Rated'),
  newest('Newest');

  const _SortOption(this.label);
  final String label;
}

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final Category category;

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedSubcategory = 'All'; // لسه مستخدمة في fallback الـlegacy strings بس
  _SortOption _sortOption = _SortOption.popular;
  RangeValues _priceRange = const RangeValues(0, 2500);
  bool _inStockOnly = false;
  bool _showFilters = false;

  Color get _accent {
    final hex = widget.category.colorHex.replaceFirst('#', '');
    final value = int.tryParse('FF$hex', radix: 16) ?? 0xFF6C63FF;
    return Color(value);
  }

  List<Product> _applyFilters(List<Product> products) {
    var result = List<Product>.from(products);

    // Search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }

    // In-stock only
    if (_inStockOnly) {
      result = result.where((p) => p.inStock).toList();
    }

    // Price range
    result = result
        .where((p) => p.price >= _priceRange.start && p.price <= _priceRange.end)
        .toList();

    // TODO: فلترة حسب الـsubcategory المختارة مش متاحة لسه —
    // Product model محتاج subcategoryId من الـbackend، أو /products
    // endpoint يقبل query param اسمه subcategory. راجع الملاحظة اللي
    // اتقالت قبل كده قبل ما تفعّل الفلترة دي فعليًا.

    // Sort
    switch (_sortOption) {
      case _SortOption.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _SortOption.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _SortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _SortOption.newest:
        result = result.reversed.toList();
        break;
      case _SortOption.popular:
        result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return result;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [تعديل] غلّفنا الشاشة كلها بـ BlocProvider<SubcategoryCubit> جديد،
    // بيتعمل مرة واحدة لكل category ويعمل load تلقائي.
    return BlocProvider<SubcategoryCubit>(
      create: (_) => SubcategoryCubit(
        subcategoryController: AppBlocProviders.subcategoryController,
      )..loadSubcategories(widget.category.id),
      child: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, catalogState) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final raw =
                  catalogState.productsByCategory(widget.category.id);
              final products = _applyFilters(raw);

              return Scaffold(
                backgroundColor: AppPalette.background,
                body: NestedScrollView(
                  headerSliverBuilder: (context, _) => [
                    _buildAppBar(context, raw.length),
                  ],
                  body: Column(
                    children: [
                      // ── Search bar ────────────────────────────────────
                      _buildSearchBar(),

                      // ── Subcategory chips ─────────────────────────────
                      // [تعديل] بقينا دايمًا بننده على _buildSubcategoryRow()،
                      // وهي بنفسها بتقرر تعرض إيه (live / legacy / مفيش حاجة).
                      _buildSubcategoryRow(),

                      // ── Sort + Filter bar ─────────────────────────────
                      _buildSortFilterBar(products.length),

                      // ── Filter panel (expandable) ─────────────────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: _showFilters
                            ? _buildFilterPanel()
                            : const SizedBox.shrink(),
                      ),

                      // ── Products grid ─────────────────────────────────
                      Expanded(
                        child: products.isEmpty
                            ? _buildEmpty()
                            : _buildGrid(
                                context, products, cartState),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, int total) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            // Focus the search field below
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.cart),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              '$total products',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.category.imageUrl.isNotEmpty)
              Image.network(
                widget.category.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: _accent),
              )
            else
              Container(color: _accent),
            // Gradient
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _accent.withOpacity(0.3),
                    _accent.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search in ${widget.category.name}...',
          hintStyle: const TextStyle(
            color: AppPalette.mutedForeground,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppPalette.mutedForeground,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppPalette.mutedForeground,
                    size: 18,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          filled: true,
          fillColor: AppPalette.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Subcategory Chips ───────────────────────────────────────────────────────

  // [تعديل] الميثود دي بقت بتقرر تعرض إيه: لودينج / chips حقيقية من السيرفر
  // / fallback على الـstrings القديمة / مفيش حاجة خالص.
  Widget _buildSubcategoryRow() {
    return BlocBuilder<SubcategoryCubit, SubcategoryState>(
      builder: (context, subState) {
        if (subState.isLoading) {
          return const SizedBox(
            height: 44,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (subState.subcategories.isNotEmpty) {
          return _buildLiveSubcategoryRow(subState);
        }

        if (widget.category.subcategories.isNotEmpty) {
          return _buildLegacySubcategoryRow();
        }

        return const SizedBox.shrink();
      },
    );
  }

  // [تعديل] جديد — الـchips اللي جايه من السيرفر عن طريق SubcategoryCubit
  Widget _buildLiveSubcategoryRow(SubcategoryState subState) {
    final subs = subState.subcategories;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: subs.length + 1, // +1 لـ "All"
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isAll = i == 0;
          final sub = isAll ? null : subs[i - 1];
          final isSelected = isAll
              ? subState.selectedSubcategoryId == null
              : subState.selectedSubcategoryId == sub!.id;

          return GestureDetector(
            onTap: () => context
                .read<SubcategoryCubit>()
                .selectSubcategory(isAll ? null : sub!.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _accent : AppPalette.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? _accent : AppPalette.border,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _accent.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                isAll ? 'All' : sub!.name,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppPalette.foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // [تعديل] الكود القديم بتاع الـchips اتنقل هنا زي ما هو، كـfallback بس
  // لما مفيش subcategories راجعة من السيرفر (مثلاً لسه Mock mode).
  Widget _buildLegacySubcategoryRow() {
    final subs = widget.category.subcategories;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: subs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sub = subs[i];
          final isSelected = _selectedSubcategory == sub;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubcategory = sub),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _accent : AppPalette.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? _accent : AppPalette.border,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _accent.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                sub,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppPalette.foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Sort + Filter bar ───────────────────────────────────────────────────────

  Widget _buildSortFilterBar(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Text(
            '$count results',
            style: const TextStyle(
              color: AppPalette.mutedForeground,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          // Sort button
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppPalette.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppPalette.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded,
                      size: 15, color: _accent),
                  const SizedBox(width: 5),
                  Text(
                    _sortOption.label.split(':').first,
                    style: TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter button
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _showFilters ? _accent : AppPalette.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _showFilters ? _accent : AppPalette.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color:
                        _showFilters ? Colors.white : _accent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: _showFilters
                          ? Colors.white
                          : _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Panel ────────────────────────────────────────────────────────────

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price range
          Row(
            children: [
              const Text(
                'Price Range',
                style: TextStyle(
                  color: AppPalette.foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '\$${_priceRange.start.toInt()} – \$${_priceRange.end.toInt()}',
                style: const TextStyle(
                  color: AppPalette.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _accent,
              thumbColor: _accent,
              inactiveTrackColor: AppPalette.border,
              overlayColor: _accent.withOpacity(0.15),
              trackHeight: 3,
              rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 8),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: 2500,
              divisions: 50,
              onChanged: (v) => setState(() => _priceRange = v),
            ),
          ),

          const SizedBox(height: 8),

          // In-stock toggle
          Row(
            children: [
              const Text(
                'In Stock Only',
                style: TextStyle(
                  color: AppPalette.foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Switch(
                value: _inStockOnly,
                onChanged: (v) => setState(() => _inStockOnly = v),
                activeColor: _accent,
                materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Reset button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() {
                _priceRange = const RangeValues(0, 2500);
                _inStockOnly = false;
                _showFilters = false;
              }),
              style: TextButton.styleFrom(
                foregroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: _accent.withOpacity(0.4)),
                ),
              ),
              child: const Text(
                'Reset Filters',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sort Bottom Sheet ───────────────────────────────────────────────────────

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPalette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.foreground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ..._SortOption.values.map((opt) {
              final isSelected = _sortOption == opt;
              return ListTile(
                onTap: () {
                  setState(() => _sortOption = opt);
                  Navigator.of(context).pop();
                },
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? _accent : AppPalette.mutedForeground,
                  size: 22,
                ),
                title: Text(
                  opt.label,
                  style: TextStyle(
                    color: isSelected
                        ? _accent
                        : AppPalette.foreground,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // ── Product Grid ────────────────────────────────────────────────────────────

  Widget _buildGrid(
    BuildContext context,
    List<Product> products,
    CartState cartState,
  ) {
    final width = (MediaQuery.of(context).size.width - 48) / 2;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          width: width,
          inCart: cartState.isInCart(product.id),
          onOpen: () => Navigator.of(context).pushNamed(
            AppRoutes.product,
            arguments: product.id,
          ),
          onAddToCart: () =>
              context.read<CartCubit>().addToCart(product),
        );
      },
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: _accent.withOpacity(0.35),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
              color: AppPalette.foreground,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: AppPalette.mutedForeground,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              setState(() {
                _searchCtrl.clear();
                _searchQuery = '';
                _selectedSubcategory = 'All';
                _priceRange = const RangeValues(0, 2500);
                _inStockOnly = false;
              });
              // [تعديل] لازم نصفّر اختيار الـSubcategoryCubit كمان،
              // مش بس الـlegacy string، وإلا الـchip الحي هيفضل متعلّم.
              context.read<SubcategoryCubit>().selectSubcategory(null);
            },
            style: TextButton.styleFrom(foregroundColor: _accent),
            child: const Text(
              'Clear all filters',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}