import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'partner_home_screen.dart';
import 'partner_profile_screen.dart';

class PartnerMainNavigationScreen extends StatefulWidget {
  const PartnerMainNavigationScreen({super.key});

  @override
  State<PartnerMainNavigationScreen> createState() =>
      _PartnerMainNavigationScreenState();
}

class _PartnerMainNavigationScreenState
    extends State<PartnerMainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PartnerHomeScreen(),
    const Center(child: Text('Active Tasks')),
    const Center(child: Text('Earnings History')),
    const PartnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
          indicatorColor: AppColors.secondary.withOpacity(0.1),
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
  }
}
