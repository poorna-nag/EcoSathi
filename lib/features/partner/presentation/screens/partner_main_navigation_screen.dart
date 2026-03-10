import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:ecosathi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecosathi/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/partner_bloc.dart';
import '../bloc/partner_event.dart';
import '../bloc/partner_state.dart';
import 'partner_dashboard_screen.dart';
import 'partner_tasks_screen.dart';
import 'partner_earnings_screen.dart';
import 'partner_profile_screen.dart';
import 'partner_verification_screen.dart';

class PartnerMainNavigationScreen extends StatefulWidget {
  const PartnerMainNavigationScreen({super.key});

  @override
  State<PartnerMainNavigationScreen> createState() =>
      _PartnerMainNavigationScreenState();
}

class _PartnerMainNavigationScreenState
    extends State<PartnerMainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<PartnerBloc>().add(
          LoadPartnerProfileEvent(authState.user.id),
        );
      }
    });
  }

  final List<Widget> _screens = [
    const PartnerDashboardScreen(),
    const PartnerTasksScreen(),
    const PartnerEarningsScreen(),
    const PartnerProfileScreen(),
  ];

  void _refreshData(String partnerId) {
    context.read<PartnerBloc>().add(LoadPartnerProfileEvent(partnerId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final partnerId = authState is Authenticated ? authState.user.id : '';

    return BlocBuilder<PartnerBloc, PartnerState>(
      builder: (context, state) {
        final partner = state is PartnerLoaded
            ? state.partner
            : (state is PartnerProfileLoaded ? state.partner : null);

        if (state is PartnerLoading && partner == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (partner != null && partner.verificationStatus != 'verified') {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: _buildVerificationStatusOverlay(context, partner, partnerId),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              backgroundColor: Colors.white,
              indicatorColor: AppColors.secondary.withValues(alpha: 0.1),
              height: 70,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(
                    Icons.dashboard_rounded,
                    color: AppColors.secondary,
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(
                    Icons.assignment_rounded,
                    color: AppColors.secondary,
                  ),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.secondary,
                  ),
                  label: 'Earnings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: AppColors.secondary,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
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
