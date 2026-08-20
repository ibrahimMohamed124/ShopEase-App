import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease_mobile/core/dependency_injection/di.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';
import 'package:shopease_mobile/core/utils/date_formatter.dart';
import 'package:shopease_mobile/cubits/track_order/track_order_cubit.dart';
import 'package:shopease_mobile/models/order_tracking.dart';
import 'package:shopease_mobile/views/widgets/error_state.dart';
import 'package:shopease_mobile/views/widgets/loading_state.dart';

// [جديد] — شاشة تتبع الأوردر. الـTrackOrderCubit بتنادي endpoint جديد
// (GET /orders/:id/tracking) لسه مش موجود في الباك اند (شوف comment في
// track_order_service.dart) — يعني الشاشة هتفضل تعرض ErrorState لحد ما
// يتضاف من ناحية السيرفر، وده متوقع ومش bug في الفلاتر.
class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrackOrderCubit>(
      create: (_) => TrackOrderCubit(
        trackOrderController: AppBlocProviders.trackOrderController,
      )..loadTracking(orderId),
      child: _TrackOrderView(orderId: orderId),
    );
  }
}

class _TrackOrderView extends StatelessWidget {
  const _TrackOrderView({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: BlocBuilder<TrackOrderCubit, TrackOrderState>(
        builder: (context, state) {
          if (state.isLoading && state.tracking == null) {
            return const LoadingState(message: 'Fetching tracking info...');
          }

          if (state.error != null && state.tracking == null) {
            return ErrorState(
              message: state.error!,
              onRetry: () =>
                  context.read<TrackOrderCubit>().loadTracking(orderId),
            );
          }

          final tracking = state.tracking;
          if (tracking == null) {
            return const ErrorState(message: 'Tracking info not available.');
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<TrackOrderCubit>().loadTracking(orderId),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // ── Summary card ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppPalette.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined,
                              color: AppPalette.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tracking.estimatedDelivery != null
                                  ? 'Arriving by ${DateFormatter.date(tracking.estimatedDelivery)}'
                                  : 'On the way',
                              style: const TextStyle(
                                color: AppPalette.foreground,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (tracking.currentLocation != null) ...[
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Current location',
                          value: tracking.currentLocation!,
                        ),
                      ],
                      if (tracking.courier != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Courier',
                          value: tracking.courier!,
                        ),
                      ],
                      if (tracking.trackingNumber != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Tracking number',
                          value: tracking.trackingNumber!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Timeline ─────────────────────────────────────────
                if (tracking.steps.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                    decoration: BoxDecoration(
                      color: AppPalette.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppPalette.border),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < tracking.steps.length; i++)
                          _TimelineStep(
                            step: tracking.steps[i],
                            isLast: i == tracking.steps.length - 1,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppPalette.mutedForeground),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                color: AppPalette.mutedForeground, fontSize: 12.5)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                color: AppPalette.foreground,
                fontWeight: FontWeight.w600,
                fontSize: 12.5),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// [جديد] — كل خطوة زمنية في تايم لاين التتبع (Order Placed → Confirmed →
// Shipped → Out for Delivery → Delivered) بنقطة ملونة وخط واصل بينهم
class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.step, required this.isLast});

  final TrackingStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = step.isCompleted || step.isCurrent
        ? AppPalette.primary
        : AppPalette.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isCompleted ? color : AppPalette.card,
                  border: Border.all(color: color, width: 2),
                ),
                child: step.isCurrent
                    ? Container(
                        margin: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppPalette.primary,
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.isCompleted
                        ? AppPalette.primary
                        : AppPalette.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: step.isCompleted || step.isCurrent
                          ? AppPalette.foreground
                          : AppPalette.mutedForeground,
                      fontWeight: step.isCurrent
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  if (step.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.description!,
                      style: const TextStyle(
                          color: AppPalette.mutedForeground, fontSize: 12),
                    ),
                  ],
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.dateTime(step.timestamp),
                      style: const TextStyle(
                          color: AppPalette.mutedForeground, fontSize: 11.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
