class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.badge,
    required this.inStock,
  });

  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String description;
  final String category;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String? badge;
  final bool inStock;

  factory Product.fromJson(Map<String, dynamic> json) {
    final originalPrice = _readOptional(
      json,
      const <String>['originalPrice', 'original_price'],
    );
    final stockValue = _readOptional(
      json,
      const <String>['inStock', 'in_stock', 'stock'],
    );

    return Product(
      id: _readString(json, const <String>['id', '_id']),
      name: _readString(json, const <String>['name', 'title']),
      price: _toDouble(json['price']),
      originalPrice: originalPrice == null ? null : _toDouble(originalPrice),
      description: _readString(json, const <String>['description']),
      category: _readCategory(json),
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(
        _readOptional(json, const <String>['reviewCount', 'review_count']),
      ),
      imageUrl: _readImageUrl(json),
      badge: _readNullableString(json, const <String>['badge']),
      inStock: stockValue == null ? true : _toBool(stockValue),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'description': description,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'badge': badge,
      'inStock': inStock,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value > 0;

    final text = '$value'.toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    return _readNullableString(json, keys) ?? '';
  }

  static String? _readNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final value = _readOptional(json, keys);
    return value == null ? null : '$value';
  }

  static dynamic _readOptional(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) {
        return json[key];
      }
    }

    return null;
  }

  static String _readImageUrl(Map<String, dynamic> json) {
    final value = _readOptional(
      json,
      const <String>['imageUrl', 'image_url', 'thumbnail'],
    );
    if (value != null) {
      return '$value';
    }

    final images = json['images'];
    if (images is List<dynamic> && images.isNotEmpty) {
      return '${images.first}';
    }

    return '';
  }

  static String _readCategory(Map<String, dynamic> json) {
    final value = _readOptional(json, const <String>['category', 'categoryId']);
    if (value is Map<String, dynamic>) {
      return _readString(value, const <String>['id', '_id', 'slug', 'name']);
    }

    return value == null ? '' : '$value';
  }
}
