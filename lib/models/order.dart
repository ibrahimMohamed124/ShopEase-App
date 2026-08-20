import 'package:shopease_mobile/models/payment_method.dart';
import 'package:shopease_mobile/models/product.dart';

enum OrderStatus { processing, shipped, delivered, cancelled }

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  double get subtotal => price * quantity;

  // [جديد] — عشان "Buy Again" يقدر يضيف العنصر للـcart فعليًا، محتاجين
  // Product كامل (CartCubit.addToCart بتاخد Product مش OrderItem). الـ
  // order item مفيهوش كل حقول الـProduct (rating/category/description..)
  // فبنعمل fallback بقيم افتراضية آمنة لحد ما ترجع بيانات المنتج الحقيقية
  // من الـcatalog، بالظبط زي الـdefaults الموجودة في Product.fromJson.
  Product toProduct() {
    return Product(
      id: productId,
      name: name,
      price: price,
      description: '',
      category: '',
      rating: 0,
      reviewCount: 0,
      imageUrl: imageUrl,
      inStock: true,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: '${json['productId'] ?? json['product_id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      imageUrl: '${json['imageUrl'] ?? json['image_url'] ?? ''}',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
      };
}

class Order {
  const Order({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
    this.estimatedDelivery,
    this.deliveredDate,
    this.paymentMethod,
  });

  final String id;
  final String date;
  final double total;
  final OrderStatus status;
  final List<OrderItem> items;

  // [جديد] — تاريخ التسليم المتوقع (لسه شحن/جاري التحضير)، بييجي من
  // الـbackend كـstring جاهز للعرض عشان نتفادى تعقيد الـtimezone/format
  // على الموبايل، بالظبط زي طريقة الـ`date` الأصلي.
  final String? estimatedDelivery;

  // [جديد] — تاريخ التسليم الفعلي، بيتملى بس لما status == delivered.
  final String? deliveredDate;

  // [جديد] — وسيلة الدفع المستخدمة في الأوردر ده، بنعيد استخدام نفس
  // الـPaymentMethod model الموجود أصلًا في شاشة Payment Methods.
  final PaymentMethod? paymentMethod;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  // [جديد] — بس الأوردر لسه بيتحضر ينفع نلغيه؛ بعد الشحن بيبقى متأخر أوي
  bool get isCancellable => status == OrderStatus.processing;

  factory Order.fromJson(Map<String, dynamic> json) {
    final statusStr = '${json['status'] ?? 'processing'}';
    final status = switch (statusStr.toLowerCase()) {
      'shipped' => OrderStatus.shipped,
      'delivered' => OrderStatus.delivered,
      'cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.processing,
    };

    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <OrderItem>[];

    final rawPaymentMethod = json['paymentMethod'] ?? json['payment_method'];

    return Order(
      id: '${json['id'] ?? json['_id'] ?? ''}',
      date: '${json['date'] ?? ''}',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: status,
      items: items,
      estimatedDelivery: (json['estimatedDelivery'] ?? json['estimated_delivery']) as String?,
      deliveredDate: (json['deliveredDate'] ?? json['delivered_date']) as String?,
      paymentMethod: rawPaymentMethod is Map<String, dynamic>
          ? PaymentMethod.fromJson(rawPaymentMethod)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'total': total,
        'status': status.name,
        'items': items.map((i) => i.toJson()).toList(),
        'estimatedDelivery': estimatedDelivery,
        'deliveredDate': deliveredDate,
        'paymentMethod': paymentMethod?.toJson(),
      };

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      date: date,
      total: total,
      status: status ?? this.status,
      items: items,
      estimatedDelivery: estimatedDelivery,
      deliveredDate: deliveredDate,
      paymentMethod: paymentMethod,
    );
  }
}
