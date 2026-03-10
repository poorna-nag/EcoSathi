import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'admin_dashboard_screen.dart';
import 'partner_approval_screen.dart';

class AdminMainNavigationScreen extends StatefulWidget {
  const AdminMainNavigationScreen({super.key});

  @override
  State<AdminMainNavigationScreen> createState() =>
      _AdminMainNavigationScreenState();
}

class _AdminMainNavigationScreenState extends State<AdminMainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const PartnerApprovalScreen(),
    const Center(child: Text('User Management coming soon')),
    const Center(child: Text('Admin Profile')),
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
          indicatorColor: AppColors.primary.withValues(alpha: 0.1),
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(
                Icons.dashboard_rounded,
                color: AppColors.primary,
              ),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.how_to_reg_outlined),
              selectedIcon: Icon(
                Icons.how_to_reg_rounded,
                color: AppColors.primary,
              ),
              label: 'Approvals',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(
                Icons.people_rounded,
                color: AppColors.primary,
              ),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.primary,
              ),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}
