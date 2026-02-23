import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PartnerEditProfileScreen extends StatefulWidget {
  const PartnerEditProfileScreen({super.key});

  @override
  State<PartnerEditProfileScreen> createState() =>
      _PartnerEditProfileScreenState();
}

class _PartnerEditProfileScreenState extends State<PartnerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(label: 'Full Name', initialValue: 'Partner Jack'),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Email Address',
                initialValue: 'jack@ecosathi.com',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Vehicle Number',
                initialValue: 'KA 01 EK 1234',
              ),
              const SizedBox(height: 20),
              _buildTextField(label: 'Experience', initialValue: '2 Years'),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Address',
                initialValue: 'HSR Layout, Bangalore',
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              const Text(
                'Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDocumentTile('Aadhar Card', true),
              _buildDocumentTile('Driving License', true),
              _buildDocumentTile('Vehicle Insurance', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTile(String name, bool isVerified) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            isVerified
                ? Icons.verified_user_rounded
                : Icons.pending_actions_rounded,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(name)),
          TextButton(
            onPressed: () {},
            child: Text(isVerified ? 'View' : 'Upload'),
          ),
        ],
      ),
    );
  }
}
