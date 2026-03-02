import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'App Guidelines',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Why use EcoSathi?',
              icon: Icons.eco_rounded,
              color: Colors.green,
              content:
                  'EcoSathi is more than just a waste collection app. It is a movement towards a cleaner planet. By using this app, you:\n\n'
                  '• Reduce plastic waste in landfills and oceans.\n'
                  '• Earn actual money for items you would normally throw away.\n'
                  '• Track your environmental impact (trees saved, CO2 reduced).\n'
                  '• Support local recycling partners and the circular economy.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'How it works?',
              icon: Icons.settings_suggest_rounded,
              color: Colors.blue,
              content:
                  'Our process is simple, transparent, and efficient:\n\n'
                  '1. Request: You notify us about the plastic you have.\n'
                  '2. Assignment: A verified recycling partner near you is assigned.\n'
                  '3. Collection: The partner visits your doorstep at the scheduled time.\n'
                  '4. Verification: Items are weighed using certified digital scales.\n'
                  '5. Payment: Funds are instantly transferred to your in-app wallet.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'How to use the app?',
              icon: Icons.touch_app_rounded,
              color: Colors.orange,
              content:
                  'Follow these steps for a smooth experience:\n\n'
                  '• Check Rates: Visit the "Rate List" to see current prices for different plastics.\n'
                  '• Schedule Pickup: Click the "Request Pickup" button on the home screen.\n'
                  '• Select Types: Choose the types of plastic you have (PET, HDPE, etc.).\n'
                  '• Set Location: Use GPS to mark your pickup address.\n'
                  '• Track Status: Go to "History" to see live tracking of your request.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Best Practices',
              icon: Icons.star_rounded,
              color: Colors.purple,
              content:
                  'To get the best rates and help the environment:\n\n'
                  '• Clean items: Rinse out food containers and bottles.\n'
                  '• Sort items: Keep different types of plastic (like PET and HDPE) separate.\n'
                  '• Dry waste: Ensure the plastic is dry before the partner arrives.\n'
                  '• Bulk up: Try to collect at least 2-5kg for a more efficient pickup.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Towards a Greener Future',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Learn how EcoSathi helps you turn your plastic waste into value.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
