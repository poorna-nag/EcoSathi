import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecosathi/core/constants/app_colors.dart';
import 'package:ecosathi/features/partner/presentation/bloc/partner_bloc.dart';
import 'package:ecosathi/features/partner/presentation/bloc/partner_event.dart';
import 'package:ecosathi/features/partner/presentation/bloc/partner_state.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';
import 'package:ecosathi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecosathi/features/auth/presentation/bloc/auth_state.dart';
import 'package:ecosathi/features/partner/presentation/screens/partner_verification_screen.dart';

class PartnerHomeScreen extends StatefulWidget {
  const PartnerHomeScreen({super.key});

  @override
  State<PartnerHomeScreen> createState() => _PartnerHomeScreenState();
}

class _PartnerHomeScreenState extends State<PartnerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        _refreshData(authState.user.id);
      }
    });
  }

  void _refreshData(String partnerId) {
    context.read<PartnerBloc>().add(LoadPartnerProfileEvent(partnerId));
    context.read<PartnerBloc>().add(
      const LoadNearbyRequestsEvent(lat: 0, lng: 0, radiusInKm: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Scaffold(
            body: Center(child: Text('Please log in for partner access.')),
          );
        }
        final partnerId = authState.user.id;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF9),
          body: BlocBuilder<PartnerBloc, PartnerState>(
            builder: (context, state) {
              if (state is PartnerError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _refreshData(partnerId),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final partner = state is PartnerLoaded
                  ? state.partner
                  : (state is PartnerProfileLoaded ? state.partner : null);
              final requests = state is PartnerLoaded
                  ? state.requests
                  : (state is NearbyRequestsLoaded
                        ? state.requests
                        : <PickupModel>[]);

              if (state is PartnerLoading && partner == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (partner != null && partner.verificationStatus != 'verified') {
                return _buildVerificationStatusOverlay(
                  context,
                  partner,
                  partnerId,
                );
              }

              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _refreshData(partnerId);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(partner, partnerId),
                        const SizedBox(height: 32),
                        _buildQuickActions(),
                        const SizedBox(height: 32),
                        _buildPartnerStats(context, partner),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nearby Requests',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (requests.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text(
                                'No nearby requests available.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...requests.map(
                            (request) => _buildNearbyRequestItem(
                              context,
                              request,
                              partnerId,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(dynamic partner, String partnerId) {
    final bool isOnline = partner?.isOnline ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  partner?.name ?? 'Partner',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        InkWell(
          onTap: () => context.read<PartnerBloc>().add(
            ToggleOnlineStatusEvent(partnerId, !isOnline),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isOnline ? AppColors.primary : Colors.grey).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.primary : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? AppColors.primary : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'High Demand Area!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'More requests in your area right now.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View Heatmap'),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerStats(BuildContext context, dynamic partner) {
    return Row(
      children: [
        _buildStatCard(
          'Earnings',
          '₹${partner?.totalEarnings?.toStringAsFixed(0) ?? "0"}',
          Icons.payments_rounded,
          Colors.green,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Completed',
          '${partner?.completedPickups ?? "0"}',
          Icons.check_circle_rounded,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyRequestItem(
    BuildContext context,
    PickupModel request,
    String partnerId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup Request',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        request.plasticType,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${request.estimatedWeight} kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'ESTIMATED',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.address,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<PartnerBloc>().add(
                    AcceptPickupEvent(partnerId, request.id),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusOverlay(
    BuildContext context,
    dynamic partner,
    String partnerId,
  ) {
    String title = '';
    String description = '';
    IconData icon = Icons.info_outline;
    Color color = Colors.orange;
    bool showButton = false;

    switch (partner.verificationStatus) {
      case 'unsubmitted':
        title = 'Identity Verification Required';
        description =
            'Please upload your documents to start receiving requests.';
        icon = Icons.assignment_ind_outlined;
        showButton = true;
        break;
      case 'pending':
        title = 'Verification Pending';
        description =
            'Your documents are currently being reviewed. This usually takes 24-48 hours.';
        icon = Icons.access_time_rounded;
        color = Colors.blue;
        break;
      case 'rejected':
        title = 'Verification Failed';
        description =
            'Your documents were rejected. Please re-upload clear photos.';
        icon = Icons.error_outline_rounded;
        color = Colors.red;
        showButton = true;
        break;
      default:
        title = 'Identity Verification';
        description = 'Please complete your verification process.';
        icon = Icons.assignment_ind_outlined;
        showButton = true;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: color),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 48),
            if (showButton)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PartnerVerificationScreen(partnerId: partnerId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Verify Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (!showButton && partner.verificationStatus == 'pending')
              ElevatedButton(
                onPressed: () => _refreshData(partnerId),
                child: const Text('Check Status'),
              ),
          ],
        ),
      ),
    );
  }
}
