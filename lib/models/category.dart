class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.productCount,
  });

  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final int productCount;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      colorHex: json['colorHex'] as String,
      productCount: json['productCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorHex': colorHex,
      'productCount': productCount,
    };
  }
}
