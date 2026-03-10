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

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
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
      const LoadNearbyRequestsEvent(lat: 0, lng: 0, radiusInKm: 10),
    );
    context.read<PartnerBloc>().add(LoadPartnerTasksEvent(partnerId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final partnerId = authState is Authenticated ? authState.user.id : '';

    return Scaffold(
      backgroundColor: AppColors.background,
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
            return _buildVerificationStatusOverlay(context, partner, partnerId);
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (partnerId.isNotEmpty) _refreshData(partnerId);
            },
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(partner, partnerId),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(partner),
                        const SizedBox(height: 24),
                        _buildStatsRow(partner),
                        const SizedBox(height: 28),
                        _buildProgressSection(
                          state is PartnerLoaded ? state.tasks : [],
                        ),
                        const SizedBox(height: 28),
                        _buildSectionHeader('Nearby Requests', () {}),
                        const SizedBox(height: 16),
                        if (requests.isEmpty)
                          _buildEmptyState()
                        else
                          ...requests
                              .take(3)
                              .map((req) => _buildRequestCard(req, partnerId)),
                        const SizedBox(height: 28),
                        _buildSectionHeader('Insights', () {}),
                        const SizedBox(height: 16),
                        _buildInsightsCard(),
                        const SizedBox(height: 100), // Spacing for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic partner, String partnerId) {
    final bool isOnline = partner?.isOnline ?? false;
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: AppColors.primary,
            ),
          ),
          _buildOnlineToggle(isOnline, partnerId),
        ],
      ),
    );
  }

  Widget _buildOnlineToggle(bool isOnline, String partnerId) {
    return GestureDetector(
      onTap: () {
        if (partnerId.isNotEmpty) {
          context.read<PartnerBloc>().add(
            ToggleOnlineStatusEvent(partnerId, !isOnline),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isOnline
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isOnline
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.primary : Colors.grey,
                shape: BoxShape.circle,
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                color: isOnline ? AppColors.primaryDark : Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(dynamic partner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${partner?.name?.split(' ').first ?? "Eco-Partner"}! 👋',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ready to make an impact today?',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(dynamic partner) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Earnings',
            '₹${partner?.todayEarnings?.toStringAsFixed(0) ?? "0"}',
            Icons.account_balance_wallet_rounded,
            AppColors.accent,
            'Today',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pickups',
            '${partner?.todayPickups ?? "0"}',
            Icons.local_shipping_rounded,
            AppColors.primary,
            'Managed',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Rating',
            '${partner?.rating?.toStringAsFixed(1) ?? "0.0"}',
            Icons.star_rounded,
            Colors.orange,
            'Performance',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subLabel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(List<PickupModel> tasks) {
    final completedToday = tasks
        .where((t) => t.status == PickupStatus.completed)
        .length;
    final totalAssigned = tasks.length;
    final progress = totalAssigned > 0 ? (completedToday / totalAssigned) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedToday/$totalAssigned Pickups completed today.\n${progress >= 1.0 ? "Target achieved!" : "Keep recycling!"}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See All',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(PickupModel request, String partnerId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.plasticType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${request.estimatedWeight} kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    'Est. Payout',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (partnerId.isNotEmpty) {
                      context.read<PartnerBloc>().add(
                        AcceptPickupEvent(partnerId, request.id),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Accept Request',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'No nearby requests',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Well notify you when someone needs a pickup.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Weekly Overview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '+12% from last week',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.4, 'Mon'),
                _buildBar(0.6, 'Tue'),
                _buildBar(0.9, 'Wed'),
                _buildBar(0.7, 'Thu'),
                _buildBar(0.5, 'Fri'),
                _buildBar(0.3, 'Sat'),
                _buildBar(0.2, 'Sun'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.4),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
