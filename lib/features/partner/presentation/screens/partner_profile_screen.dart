import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/localization/language_cubit.dart';

import 'partner_edit_profile_screen.dart';

class PartnerProfileScreen extends StatelessWidget {
  const PartnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF9),
          body: CustomScrollView(
            slivers: [
              _buildSliverHeader(context, user),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPerformanceOverview(),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Account'),
                      _buildSettingsGroup([
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Personal Information',
                          subtitle: 'Name, phone, and vehicle details',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PartnerEditProfileScreen(),
                            ),
                          ),
                        ),
                        _buildMenuTile(
                          icon: Icons.description_outlined,
                          title: 'Verification Documents',
                          subtitle: 'Manage your Aadhar and License',
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Preferences'),
                      _buildSettingsGroup([
                        _buildMenuTile(
                          icon: Icons.language_rounded,
                          title: 'App Language',
                          subtitle: 'Choose your preferred language',
                          onTap: () => _showLanguagePicker(context),
                        ),
                        _buildMenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notification Settings',
                          subtitle: 'Control alerts and updates',
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Support & Legal'),
                      _buildSettingsGroup([
                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help Center',
                          subtitle: 'Find answers and tutorials',
                          onTap: () {},
                        ),
                        _buildMenuTile(
                          icon: Icons.policy_outlined,
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                        _buildMenuTile(
                          icon: Icons.gavel_rounded,
                          title: 'Terms of Service',
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 40),
                      _buildActionButton(
                        context: context,
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        color: Colors.red,
                        onTap: () =>
                            context.read<AuthBloc>().add(LogoutEvent()),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        context: context,
                        icon: Icons.delete_forever_rounded,
                        label: 'Delete Account',
                        color: Colors.grey[600]!,
                        onTap: () {},
                      ),

                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Version 1.0.4 (Build 412)\nMade with ❤️ by EcoSathi Team',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.withValues(alpha: 0.5),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverHeader(BuildContext context, dynamic user) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.secondary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.secondary, Color(0xFF1B5E20)],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'profile-avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'P',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Eco-Partner',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Partner ID: #PART-98234',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Rating', '4.9', Icons.star_rounded, Colors.orange),
            VerticalDivider(
              color: Colors.grey.withValues(alpha: 0.1),
              thickness: 1,
            ),
            _buildStatItem('Impact', '840kg', Icons.eco_rounded, Colors.green),
            VerticalDivider(
              color: Colors.grey.withValues(alpha: 0.1),
              thickness: 1,
            ),
            _buildStatItem('Jobs', '124', Icons.history_rounded, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[700], size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(18),
          backgroundColor: color.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select App Language',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildLanguageOption(context, 'English', 'en'),
              _buildLanguageOption(context, 'Hindi', 'hi'),
              _buildLanguageOption(context, 'Kannada', 'kn'),
              _buildLanguageOption(context, 'Tamil', 'ta'),
              _buildLanguageOption(context, 'Telugu', 'te'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        context.read<LanguageCubit>().changeLanguage(code);
        Navigator.pop(context);
      },
      trailing: context.read<LanguageCubit>().state.languageCode == code
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}
