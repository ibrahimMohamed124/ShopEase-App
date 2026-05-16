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
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: _toDouble(json['price']),
      originalPrice:
          json['originalPrice'] == null
              ? null
              : _toDouble(json['originalPrice']),
      description: json['description'] as String,
      category: json['category'] as String,
      rating: _toDouble(json['rating']),
      reviewCount: json['reviewCount'] as int,
      imageUrl: json['imageUrl'] as String,
      badge: json['badge'] as String?,
      inStock: json['inStock'] as bool,
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
}
