import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecosathi/core/constants/app_colors.dart';
import 'package:ecosathi/features/partner/presentation/bloc/partner_bloc.dart';
import 'package:ecosathi/features/partner/presentation/bloc/partner_event.dart';
import 'package:ecosathi/features/partner/presentation/bloc/partner_state.dart';

class PartnerVerificationScreen extends StatefulWidget {
  final String partnerId;
  const PartnerVerificationScreen({super.key, required this.partnerId});

  @override
  State<PartnerVerificationScreen> createState() =>
      _PartnerVerificationScreenState();
}

class _PartnerVerificationScreenState extends State<PartnerVerificationScreen> {
  final ImagePicker _picker = ImagePicker();

  String? _aadharFront;
  String? _aadharBack;
  String? _panFront;
  String? _panBack;
  String? _selfie;

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(
      source: type == 'selfie' ? ImageSource.camera : ImageSource.camera,
      preferredCameraDevice: type == 'selfie'
          ? CameraDevice.front
          : CameraDevice.rear,
    );

    if (image != null) {
      setState(() {
        switch (type) {
          case 'aadharFront':
            _aadharFront = image.path;
            break;
          case 'aadharBack':
            _aadharBack = image.path;
            break;
          case 'panFront':
            _panFront = image.path;
            break;
          case 'panBack':
            _panBack = image.path;
            break;
          case 'selfie':
            _selfie = image.path;
            break;
        }
      });
    }
  }

  bool get _isFormValid =>
      _aadharFront != null &&
      _aadharBack != null &&
      _panFront != null &&
      _panBack != null &&
      _selfie != null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PartnerBloc, PartnerState>(
      listener: (context, state) {
        if (state is PartnerLoaded &&
            state.partner.verificationStatus == 'pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification submitted successfully!'),
            ),
          );
          Navigator.pop(context);
        } else if (state is PartnerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF9),
        appBar: AppBar(
          title: const Text(
            'Identity Verification',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete your profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload clear photos of your documents to start earning.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Aadhar Card'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadCard(
                      'Front Side',
                      _aadharFront,
                      () => _pickImage('aadharFront'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUploadCard(
                      'Back Side',
                      _aadharBack,
                      () => _pickImage('aadharBack'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('PAN Card'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadCard(
                      'Front Side',
                      _panFront,
                      () => _pickImage('panFront'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUploadCard(
                      'Back Side',
                      _panBack,
                      () => _pickImage('panBack'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Live Selfie'),
              const SizedBox(height: 12),
              _buildUploadCard(
                'Take a Selfie',
                _selfie,
                () => _pickImage('selfie'),
                isFullWidth: true,
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: BlocBuilder<PartnerBloc, PartnerState>(
                  builder: (context, state) {
                    final isLoading = state is PartnerLoading;
                    return ElevatedButton(
                      onPressed: (_isFormValid && !isLoading) ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit Verification',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildUploadCard(
    String label,
    String? path,
    VoidCallback onTap, {
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: path != null ? AppColors.primary : Colors.grey.shade300,
            width: path != null ? 2 : 1,
            style: path != null ? BorderStyle.solid : BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: path != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(path), fit: BoxFit.cover),
                    Container(color: Colors.black26),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _submit() {
    context.read<PartnerBloc>().add(
      SubmitVerificationEvent(
        partnerId: widget.partnerId,
        aadharFrontPath: _aadharFront!,
        aadharBackPath: _aadharBack!,
        panFrontPath: _panFront!,
        panBackPath: _panBack!,
        selfiePath: _selfie!,
      ),
    );
  }
}
