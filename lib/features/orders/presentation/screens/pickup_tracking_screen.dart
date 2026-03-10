import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../pickup/data/models/pickup_model.dart';
import 'package:intl/intl.dart';

class PickupTrackingScreen extends StatelessWidget {
  final PickupModel pickup;

  const PickupTrackingScreen({super.key, required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Track Pickup',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPickupSummaryCard(),
            const SizedBox(height: 32),
            _buildTrackingTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup.plasticType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Pickup ID: ${pickup.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(pickup.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pickup.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(pickup.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(),
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Pickup Location',
            pickup.address,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Scheduled For',
            DateFormat('MMM dd, yyyy • hh:mm a').format(pickup.scheduledTime),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.line_weight_rounded,
            'Estimated Weight',
            '${pickup.estimatedWeight} kg',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline() {
    final statuses = [
      {
        'title': 'Pickup Requested',
        'status': PickupStatus.pending,
        'desc': 'We have received your pickup request.',
      },
      {
        'title': 'Accepted by Partner',
        'status': PickupStatus.assigned,
        'desc': 'A recycling partner has been assigned.',
      },
      {
        'title': 'Partner Pickup Done',
        'status': PickupStatus.picked,
        'desc': 'The partner has collected the items.',
      },
      {
        'title': 'Payment Success',
        'status': PickupStatus.completed,
        'desc': 'Payment has been transferred to your wallet.',
      },
    ];

    int currentIndex = _getStatusIndex(pickup.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Tracking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statuses.length,
            itemBuilder: (context, index) {
              final isCompleted = index <= currentIndex;
              final isLast = index == statuses.length - 1;
              final item = statuses[index];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.primary
                              : Colors.grey.withValues(alpha: 0.2),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.primary
                                : Colors.grey.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          color: isCompleted && index < currentIndex
                              ? AppColors.primary
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['desc'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted
                                ? AppColors.textSecondary
                                : AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return AppColors.warning;
      case PickupStatus.assigned:
        return Colors.blue;
      case PickupStatus.picked:
        return Colors.purple;
      case PickupStatus.completed:
        return AppColors.success;
      case PickupStatus.cancelled:
        return AppColors.error;
    }
  }

  int _getStatusIndex(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return 0;
      case PickupStatus.assigned:
        return 1;
      case PickupStatus.picked:
        return 2;
      case PickupStatus.completed:
        return 3;
      case PickupStatus.cancelled:
        return -1;
    }
  }
}
