import 'package:shopease_mobile/core/network/api_client.dart';
import 'package:shopease_mobile/models/order_tracking.dart';

class TrackOrderService {
  TrackOrderService({required ApiClient client}) : _client = client;

  final ApiClient _client;

  // GET /orders/:id/tracking — لسه مش موجودة في السيرفر (شوف orders.controller.ts
  // فيه بس GET / و GET /:id و PATCH /:id/status و PATCH /:id/cancel). لما
  // تتضاف، لازم ترجع نفس شكل OrderTracking.fromJson (orderId, trackingNumber,
  // courier, estimatedDelivery, currentLocation, steps[]). لحد ما تتضاف، أي
  // نداء هنا هيرمي 404 وTrackOrderCubit هيعرضها كـerror state طبيعي.
  Future<OrderTracking> fetchTracking(String orderId) {
    return _client.get<OrderTracking>(
      '/orders/$orderId/tracking',
      parser: (data) {
        final trackingJson = data is Map<String, dynamic>
            ? (data['tracking'] ?? data['data'] ?? data)
            : data;
        return OrderTracking.fromJson(trackingJson as Map<String, dynamic>);
      },
    );
  }
}
