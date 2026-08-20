// [جديد] — model مستقل عن Order عمدًا: بيانات التتبع (tracking number,
// courier, الخطوات الزمنية) حاجة تانية عن الأوردر نفسه (items/total/status)،
// وعادة بتيجي من endpoint منفصل عشان مش كل شاشة محتاجة كل التفاصيل دي.
// الـbackend لسه مفيهوش /orders/:id/tracking (شغل الفلاتر بس دلوقتي زي ما
// اتقال)، فلحد ما يتضاف، الشاشة هتعرض error state طبيعي (زي أي endpoint
// تاني مش موجود) بدل ما تكسر أو تحط بيانات وهمية.
class TrackingStep {
  const TrackingStep({
    required this.title,
    this.description,
    this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
  });

  final String title;
  final String? description;
  final String? timestamp;
  final bool isCompleted;
  final bool isCurrent;

  factory TrackingStep.fromJson(Map<String, dynamic> json) {
    return TrackingStep(
      title: '${json['title'] ?? ''}',
      description: json['description'] as String?,
      timestamp: json['timestamp'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'timestamp': timestamp,
        'isCompleted': isCompleted,
        'isCurrent': isCurrent,
      };
}

class OrderTracking {
  const OrderTracking({
    required this.orderId,
    this.trackingNumber,
    this.courier,
    this.estimatedDelivery,
    this.currentLocation,
    required this.steps,
  });

  final String orderId;
  final String? trackingNumber;
  final String? courier;
  final String? estimatedDelivery;
  final String? currentLocation;
  final List<TrackingStep> steps;

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] ?? json['timeline'];
    final steps = rawSteps is List
        ? rawSteps
            .map((e) => TrackingStep.fromJson(e as Map<String, dynamic>))
            .toList()
        : <TrackingStep>[];

    return OrderTracking(
      orderId: '${json['orderId'] ?? json['order_id'] ?? ''}',
      trackingNumber:
          (json['trackingNumber'] ?? json['tracking_number']) as String?,
      courier: json['courier'] as String?,
      estimatedDelivery:
          (json['estimatedDelivery'] ?? json['estimated_delivery']) as String?,
      currentLocation:
          (json['currentLocation'] ?? json['current_location']) as String?,
      steps: steps,
    );
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'trackingNumber': trackingNumber,
        'courier': courier,
        'estimatedDelivery': estimatedDelivery,
        'currentLocation': currentLocation,
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}
