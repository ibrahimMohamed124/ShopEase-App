import 'package:flutter/material.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returns & Refunds')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: context.colors.secondary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.verified_user_outlined,
                      color: context.colors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('30-Day Return Policy',
                          style: TextStyle(
                              color: context.colors.foreground,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      SizedBox(height: 2),
                      Text(
                          'Return most items within 30 days of delivery for a full refund.',
                          style: TextStyle(
                              color: context.colors.mutedForeground, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'ACTIVE RETURNS'),
          const _ReturnCard(
            orderId: '#ORD-7412',
            productName: 'Wireless Bluetooth Headphones',
            requestedDate: 'Jul 5, 2025',
            refundAmount: 89.99,
            status: _ReturnStatus.inReview,
          ),
          const SizedBox(height: 12),
          const _SectionHeader(title: 'PAST RETURNS'),
          const _ReturnCard(
            orderId: '#ORD-6892',
            productName: 'Smart Watch Series X',
            requestedDate: 'Jun 2, 2025',
            refundAmount: 199.00,
            status: _ReturnStatus.refunded,
          ),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'START A RETURN'),
          _ReturnOptionTile(
            icon: Icons.assignment_return_outlined,
            title: 'Request a Return',
            subtitle: 'Select an item from a delivered order',
            onTap: () => _showStartReturnSheet(context),
          ),
          const SizedBox(height: 10),
          _ReturnOptionTile(
            icon: Icons.headset_mic_outlined,
            title: 'Contact Support',
            subtitle: 'Chat or email our support team',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _ReturnOptionTile(
            icon: Icons.help_outline_rounded,
            title: 'Return FAQs',
            subtitle: 'Answers to common return questions',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.muted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Refund Timeline',
                    style: TextStyle(
                        color: context.colors.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                SizedBox(height: 8),
                _TimelineStep(
                    step: '1',
                    label: 'Return Request',
                    detail: 'Submit online — instant confirmation'),
                _TimelineStep(
                    step: '2',
                    label: 'Ship Item Back',
                    detail: 'Use the prepaid label provided'),
                _TimelineStep(
                    step: '3',
                    label: 'Item Received',
                    detail: 'Warehouse inspection (1-3 days)'),
                _TimelineStep(
                    step: '4',
                    label: 'Refund Issued',
                    detail: '3-5 business days to original payment',
                    isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStartReturnSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start a Return',
                    style: TextStyle(
                        color: context.colors.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
                'Select your delivered order to begin the return process.',
                style: TextStyle(color: context.colors.mutedForeground)),
            const SizedBox(height: 16),
            _SelectableOrder(
              orderId: '#ORD-7821',
              date: 'Jul 18, 2025',
              total: 149.97,
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Return request submitted for #ORD-7821.')));
              },
            ),
            const SizedBox(height: 10),
            _SelectableOrder(
              orderId: '#ORD-7103',
              date: 'Jun 12, 2025',
              total: 59.99,
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Return request submitted for #ORD-7103.')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum _ReturnStatus { inReview, refunded, rejected }

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({
    required this.orderId,
    required this.productName,
    required this.requestedDate,
    required this.refundAmount,
    required this.status,
  });
  final String orderId;
  final String productName;
  final String requestedDate;
  final double refundAmount;
  final _ReturnStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      _ReturnStatus.inReview => ('In Review', context.colors.star),
      _ReturnStatus.refunded => ('Refunded', context.colors.success),
      _ReturnStatus.rejected => ('Rejected', context.colors.destructive),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(orderId,
                        style: TextStyle(
                            color: context.colors.mutedForeground, fontSize: 12))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(productName,
                style: TextStyle(
                    color: context.colors.foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Requested $requestedDate',
                    style: TextStyle(
                        color: context.colors.mutedForeground, fontSize: 12)),
                Text('Refund: \$${refundAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReturnOptionTile extends StatelessWidget {
  const _ReturnOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: context.colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: context.colors.foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: context.colors.mutedForeground, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    required this.label,
    required this.detail,
    this.isLast = false,
  });
  final String step;
  final String label;
  final String detail;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: context.colors.primary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(step,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: context.colors.border,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: context.colors.foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(detail,
                      style: TextStyle(
                          color: context.colors.mutedForeground, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableOrder extends StatelessWidget {
  const _SelectableOrder({
    required this.orderId,
    required this.date,
    required this.total,
    required this.onTap,
  });
  final String orderId;
  final String date;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.muted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orderId,
                      style: TextStyle(
                          color: context.colors.foreground,
                          fontWeight: FontWeight.w700)),
                  Text('$date • \$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: context.colors.mutedForeground, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: context.colors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: context.colors.mutedForeground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
