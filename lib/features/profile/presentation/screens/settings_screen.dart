import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/localization/language_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = (state is Authenticated) ? state.user : null;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildSettingsGroup('ACCOUNT', [
                  _buildSettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: AppLocalizations.of(context)!.editProfile,
                    onTap: () {
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              currentName: user.name,
                              currentEmail: user.email,
                              currentPhone: user.phone,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: AppLocalizations.of(context)!.changePassword,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.security_outlined,
                    title: AppLocalizations.of(context)!.privacySettings,
                    onTap: () => _showPrivacySettingsDialog(context),
                  ),
                ]),
                _buildSettingsGroup('NOTIFICATIONS', [
                  _buildToggleTile(
                    icon: Icons.notifications_none_rounded,
                    title: AppLocalizations.of(context)!.pushNotifications,
                    value: _pushNotifications,
                    onChanged: (val) =>
                        setState(() => _pushNotifications = val),
                  ),
                  _buildToggleTile(
                    icon: Icons.alternate_email_rounded,
                    title: AppLocalizations.of(context)!.emailNotifications,
                    value: _emailAlerts,
                    onChanged: (val) => setState(() => _emailAlerts = val),
                  ),
                ]),
                _buildSettingsGroup('APP PREFERENCES', [
                  _buildToggleTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
                  ),
                  _buildSettingsTile(
                    icon: Icons.language_rounded,
                    title: AppLocalizations.of(context)!.language,
                    trailing: Text(
                      _getLanguageName(context),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _showLanguageDialog(context),
                  ),
                ]),
                _buildSettingsGroup('ABOUT', [
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: AppLocalizations.of(context)!.privacyPolicy,
                    onTap: () => _launchUrl('https://ecosathi.com/privacy'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: AppLocalizations.of(context)!.termsOfService,
                    onTap: () => _launchUrl('https://ecosathi.com/terms'),
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.appVersion,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ),
                ]),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton(
                    onPressed: () => _showDeleteAccountDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline_rounded),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.deleteAccount,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 24, 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textHint,
          ),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This action is permanent and will delete all your pickup history and earnings.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // 1. Delete Firestore data
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .delete();
                  // 2. Delete Auth user
                  await user.delete();
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    context.read<AuthBloc>().add(
                      LogoutEvent(),
                    ); // Trigger logout from Bloc
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: $e. You might need to re-login to delete account.',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text(
          'Select Language',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        children: [
          _buildLanguageOption(
            AppLocalizations.of(context)!.english,
            Localizations.localeOf(context).languageCode == 'en',
            'en',
          ),
          _buildLanguageOption(
            AppLocalizations.of(context)!.kannada,
            Localizations.localeOf(context).languageCode == 'kn',
            'kn',
          ),
          _buildLanguageOption(
            AppLocalizations.of(context)!.hindi,
            Localizations.localeOf(context).languageCode == 'hi',
            'hi',
          ),
          _buildLanguageOption(
            AppLocalizations.of(context)!.telugu,
            Localizations.localeOf(context).languageCode == 'te',
            'te',
          ),
          _buildLanguageOption(
            AppLocalizations.of(context)!.tamil,
            Localizations.localeOf(context).languageCode == 'ta',
            'ta',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title, bool isSelected, String code) {
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        context.read<LanguageCubit>().changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showPrivacySettingsDialog(BuildContext context) {
    bool shareData = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Privacy Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile.adaptive(
                title: const Text(
                  'Share usage data',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Help us improve EcoSathi by sharing anonymous usage data.',
                  style: TextStyle(fontSize: 12),
                ),
                value: shareData,
                onChanged: (val) => setDialogState(() => shareData = val),
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'kn':
        return AppLocalizations.of(context)!.kannada;
      case 'hi':
        return AppLocalizations.of(context)!.hindi;
      case 'te':
        return AppLocalizations.of(context)!.telugu;
      case 'ta':
        return AppLocalizations.of(context)!.tamil;
      default:
        return AppLocalizations.of(context)!.english;
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }
}
