import 'package:shopease_mobile/models/app_user.dart';
import 'package:shopease_mobile/models/category.dart';
import 'package:shopease_mobile/models/product.dart';

class MockDataService {
  static const List<Product> _products = [
    Product(
      id: '1',
      name: 'AirPods Pro Max',
      price: 249.99,
      originalPrice: 299.99,
      description:
          'Premium wireless headphones with industry-leading noise cancellation and immersive spatial audio.',
      category: 'electronics',
      rating: 4.8,
      reviewCount: 2341,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
      badge: 'Sale',
      inStock: true,
    ),
    Product(
      id: '2',
      name: 'Nike Air Max 270',
      price: 129.99,
      originalPrice: 159.99,
      description:
          'Bold silhouette with a large air unit that provides day-long comfort and cushioning.',
      category: 'fashion',
      rating: 4.6,
      reviewCount: 1876,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
      badge: 'Hot',
      inStock: true,
    ),
    Product(
      id: '3',
      name: 'MacBook Pro 14"',
      price: 1999.0,
      originalPrice: 2199.0,
      description:
          'Apple M3 Pro performance, stunning display, and exceptional battery life for pro workflows.',
      category: 'electronics',
      rating: 4.9,
      reviewCount: 5120,
      imageUrl:
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&q=80',
      badge: 'New',
      inStock: true,
    ),
    Product(
      id: '4',
      name: 'Rolex Submariner',
      price: 899.99,
      description:
          'Timeless watch design with durable construction and premium craftsmanship.',
      category: 'accessories',
      rating: 4.7,
      reviewCount: 432,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80',
      inStock: true,
    ),
    Product(
      id: '5',
      name: 'Sony WH-1000XM5',
      price: 279.99,
      originalPrice: 349.99,
      description:
          'Top-tier noise canceling headphones with clear calls and long battery life.',
      category: 'electronics',
      rating: 4.7,
      reviewCount: 3201,
      imageUrl:
          'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&q=80',
      badge: 'Sale',
      inStock: true,
    ),
    Product(
      id: '6',
      name: 'Levi\'s 501 Original Jeans',
      price: 69.99,
      description: 'The iconic straight fit denim with a classic button fly.',
      category: 'fashion',
      rating: 4.5,
      reviewCount: 8902,
      imageUrl:
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&q=80',
      inStock: true,
    ),
    Product(
      id: '7',
      name: 'iPad Air 5th Gen',
      price: 599.99,
      originalPrice: 699.99,
      description:
          'Thin and light tablet with strong performance and excellent portability.',
      category: 'electronics',
      rating: 4.8,
      reviewCount: 1560,
      imageUrl:
          'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=600&q=80',
      badge: 'Sale',
      inStock: true,
    ),
    Product(
      id: '8',
      name: 'Leather Tote Bag',
      price: 149.99,
      description:
          'Handcrafted full-grain leather tote with polished details and roomy interior.',
      category: 'accessories',
      rating: 4.6,
      reviewCount: 720,
      imageUrl:
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80',
      inStock: true,
    ),
    Product(
      id: '9',
      name: 'Running Pro Elite',
      price: 179.99,
      originalPrice: 219.99,
      description:
          'Lightweight race-ready running shoes with energetic midsole response.',
      category: 'sports',
      rating: 4.7,
      reviewCount: 945,
      imageUrl:
          'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600&q=80',
      badge: 'New',
      inStock: true,
    ),
    Product(
      id: '10',
      name: 'Smart Fitness Tracker',
      price: 89.99,
      description:
          'Track sleep, heart rate, steps, and workouts in a compact waterproof band.',
      category: 'sports',
      rating: 4.4,
      reviewCount: 2870,
      imageUrl:
          'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=600&q=80',
      inStock: false,
    ),
    Product(
      id: '11',
      name: 'Minimalist Desk Lamp',
      price: 49.99,
      description:
          'Adjustable LED desk lamp with brightness presets and modern styling.',
      category: 'home',
      rating: 4.3,
      reviewCount: 1234,
      imageUrl:
          'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600&q=80',
      inStock: true,
    ),
    Product(
      id: '12',
      name: 'Yoga Mat Pro',
      price: 79.99,
      originalPrice: 99.99,
      description:
          'Eco-friendly yoga mat with anti-slip surface and comfort support.',
      category: 'sports',
      rating: 4.6,
      reviewCount: 3411,
      imageUrl:
          'https://images.unsplash.com/photo-1601925228133-2e0f0450b272?w=600&q=80',
      badge: 'Sale',
      inStock: true,
    ),
  ];

  static const List<Category> _categories = [
    Category(
      id: 'electronics',
      name: 'Electronics',
      icon: 'cpu',
      colorHex: '#6C63FF',
      productCount: 4,
    ),
    Category(
      id: 'fashion',
      name: 'Fashion',
      icon: 'shopping-bag',
      colorHex: '#FF6B6B',
      productCount: 2,
    ),
    Category(
      id: 'accessories',
      name: 'Accessories',
      icon: 'watch',
      colorHex: '#FFB800',
      productCount: 2,
    ),
    Category(
      id: 'sports',
      name: 'Sports',
      icon: 'activity',
      colorHex: '#22C55E',
      productCount: 3,
    ),
    Category(
      id: 'home',
      name: 'Home',
      icon: 'home',
      colorHex: '#06B6D4',
      productCount: 1,
    ),
  ];

  List<Product> get productsData => List.unmodifiable(_products);

  Future<List<Product>> fetchProducts({
    String? category,
    String? search,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    var results = _products.toList();
    if (category != null && category.isNotEmpty) {
      results =
          results.where((product) => product.category == category).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      results =
          results
              .where(
                (product) =>
                    product.name.toLowerCase().contains(query) ||
                    product.description.toLowerCase().contains(query) ||
                    product.category.toLowerCase().contains(query),
              )
              .toList();
    }

    return results;
  }

  Future<Product?> fetchProductById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _products.where((product) => product.badge != null).take(6).toList();
  }

  Future<List<Category>> fetchCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<Category>.from(_categories);
  }

  Future<AppUser> loginUser(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email and password are required.');
    }
    if (password.length < 6) {
      throw Exception('Invalid credentials.');
    }

    final displayName = email
        .split('@')
        .first
        .replaceAll('.', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');

    return AppUser(
      id: 'user-1',
      name: displayName,
      email: email,
      phone: '+1 (555) 000-0000',
      address: '123 Main St, San Francisco, CA 94102',
    );
  }

  Future<AppUser> registerUser(
    String name,
    String email,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      throw Exception('All fields are required.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    return AppUser(
      id: 'user-new',
      name: name.trim(),
      email: email.trim(),
      address: '',
      phone: '',
    );
  }
}
