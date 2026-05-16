import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopease_mobile/controllers/cart_controller.dart';
import 'package:shopease_mobile/controllers/search_controller.dart'
    as search_vm;
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/views/widgets/error_state.dart';
import 'package:shopease_mobile/views/widgets/loading_state.dart';
import 'package:shopease_mobile/views/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<search_vm.SearchController>().initialize(
        initialQuery: widget.initialQuery,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<search_vm.SearchController>();
    final cart = context.watch<CartController>();
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 48) / 2;

    if (search.isLoading) {
      return const Scaffold(
        body: LoadingState(message: 'Searching products...'),
      );
    }

    if (search.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Search')),
        body: ErrorState(
          message: search.error!,
          onRetry:
              () => search.initialize(initialQuery: _searchController.text),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TextField(
            controller: _searchController,
            onChanged: search.setQuery,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon:
                  _searchController.text.isEmpty
                      ? null
                      : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          search.setQuery('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _filtersExpanded = !_filtersExpanded;
              });
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune_rounded),
                if (search.activeFilterCount > 0)
                  Positioned(
                    right: -7,
                    top: -5,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppPalette.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${search.activeFilterCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              color: AppPalette.card,
              border: Border(bottom: BorderSide(color: AppPalette.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${search.results.length} result${search.results.length == 1 ? '' : 's'}'
                    '${search.query.trim().isNotEmpty ? ' for "${search.query.trim()}"' : ''}',
                    style: const TextStyle(
                      color: AppPalette.foreground,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (search.activeFilterCount > 0)
                  TextButton(
                    onPressed: search.resetFilters,
                    child: const Text('Clear all'),
                  ),
              ],
            ),
          ),
          if (_filtersExpanded) _FilterPanel(controller: search),
          Expanded(
            child:
                search.results.isEmpty
                    ? const _EmptySearchState()
                    : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            search.results.map((product) {
                              return ProductCard(
                                product: product,
                                width: cardWidth,
                                inCart: cart.isInCart(product.id),
                                onOpen:
                                    () => Navigator.of(context).pushNamed(
                                      '/product',
                                      arguments: product.id,
                                    ),
                                onAddToCart: () => cart.addToCart(product),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.controller});

  final search_vm.SearchController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: AppPalette.card,
        border: Border(bottom: BorderSide(color: AppPalette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterLabel(text: 'Sort'),
          DropdownButtonFormField<search_vm.SearchSort>(
            value: controller.sort,
            items: const [
              DropdownMenuItem(
                value: search_vm.SearchSort.featured,
                child: Text('Featured'),
              ),
              DropdownMenuItem(
                value: search_vm.SearchSort.priceAsc,
                child: Text('Price: Low to High'),
              ),
              DropdownMenuItem(
                value: search_vm.SearchSort.priceDesc,
                child: Text('Price: High to Low'),
              ),
              DropdownMenuItem(
                value: search_vm.SearchSort.rating,
                child: Text('Top Rated'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              controller.setSort(value);
            },
          ),
          const SizedBox(height: 10),
          _FilterLabel(text: 'Price Range'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Choice(
                label: 'Any',
                selected:
                    controller.priceRange == search_vm.SearchPriceRange.any,
                onTap:
                    () => controller.setPriceRange(
                      search_vm.SearchPriceRange.any,
                    ),
              ),
              _Choice(
                label: 'Under \$50',
                selected:
                    controller.priceRange == search_vm.SearchPriceRange.under50,
                onTap:
                    () => controller.setPriceRange(
                      search_vm.SearchPriceRange.under50,
                    ),
              ),
              _Choice(
                label: '\$50-\$200',
                selected:
                    controller.priceRange ==
                    search_vm.SearchPriceRange.from50to200,
                onTap:
                    () => controller.setPriceRange(
                      search_vm.SearchPriceRange.from50to200,
                    ),
              ),
              _Choice(
                label: '\$200-\$500',
                selected:
                    controller.priceRange ==
                    search_vm.SearchPriceRange.from200to500,
                onTap:
                    () => controller.setPriceRange(
                      search_vm.SearchPriceRange.from200to500,
                    ),
              ),
              _Choice(
                label: '\$500+',
                selected:
                    controller.priceRange == search_vm.SearchPriceRange.over500,
                onTap:
                    () => controller.setPriceRange(
                      search_vm.SearchPriceRange.over500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FilterLabel(text: 'Min Rating'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Choice(
                label: 'Any',
                selected:
                    controller.ratingFilter == search_vm.SearchRatingFilter.any,
                onTap:
                    () => controller.setRatingFilter(
                      search_vm.SearchRatingFilter.any,
                    ),
              ),
              _Choice(
                label: '4+ ★',
                selected:
                    controller.ratingFilter ==
                    search_vm.SearchRatingFilter.from4,
                onTap:
                    () => controller.setRatingFilter(
                      search_vm.SearchRatingFilter.from4,
                    ),
              ),
              _Choice(
                label: '4.5+ ★',
                selected:
                    controller.ratingFilter ==
                    search_vm.SearchRatingFilter.from45,
                onTap:
                    () => controller.setRatingFilter(
                      search_vm.SearchRatingFilter.from45,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FilterLabel(text: 'Category'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                controller.categoryOptions.map((category) {
                  return _Choice(
                    label: _readableCategory(category),
                    selected: controller.category == category,
                    onTap: () => controller.setCategory(category),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  String _readableCategory(String category) {
    if (category == 'all') return 'All';
    return '${category[0].toUpperCase()}${category.substring(1)}';
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : AppPalette.muted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppPalette.foreground,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppPalette.foreground,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.search_off_rounded,
              size: 70,
              color: AppPalette.mutedForeground,
            ),
            SizedBox(height: 12),
            Text(
              'No results found',
              style: TextStyle(
                color: AppPalette.foreground,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try changing your search keywords or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
