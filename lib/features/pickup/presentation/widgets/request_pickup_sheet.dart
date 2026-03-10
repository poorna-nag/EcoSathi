import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ecosathi/core/constants/app_colors.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';
import 'package:ecosathi/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:ecosathi/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:ecosathi/features/pickup/presentation/bloc/pickup_state.dart';
import 'package:ecosathi/features/profile/presentation/screens/address_list_screen.dart';

class RequestPickupSheet extends StatefulWidget {
  final String? initialPlasticType;
  const RequestPickupSheet({super.key, this.initialPlasticType});

  @override
  State<RequestPickupSheet> createState() => _RequestPickupSheetState();
}

class _RequestPickupSheetState extends State<RequestPickupSheet> {
  late final List<String> _selectedPlasticTypes;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  final List<String> _plasticTypes = [
    'PET Bottle',
    'HDPE Plastic',
    'PVC / Pipes',
    'LDPE Plastic',
    'PP Plastic',
    'PS / Styrofoam',
    'Multi-layer (MLP)',
    'Mixed Plastic',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlasticTypes = widget.initialPlasticType != null
        ? [widget.initialPlasticType!]
        : [];
  }

  @override
  void dispose() {
    _weightController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      _latitude = position.latitude;
      _longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _addressController.text =
              '${place.street}, ${place.subLocality}, ${place.locality} - ${place.postalCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PickupBloc, PickupState>(
      listener: (context, state) {
        if (state is PickupRequestSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup scheduled successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state is PickupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  'Schedule Pickup',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plastic Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _plasticTypes.map((type) {
                        final isSelected = _selectedPlasticTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPlasticTypes.add(type);
                              } else {
                                _selectedPlasticTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Estimated Weight',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter weight in kg',
                        suffixText: 'kg',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pickup Location',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final selectedAddress =
                                await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddressListScreen(
                                          selectMode: true,
                                        ),
                                  ),
                                );
                            if (selectedAddress != null) {
                              setState(
                                () => _addressController.text = selectedAddress,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.bookmark_added_rounded,
                            size: 16,
                          ),
                          label: const Text(
                            'Saved Addresses',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _isLoadingLocation
                          ? null
                          : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded, size: 18),
                      label: Text(
                        _isLoadingLocation
                            ? 'Locating...'
                            : 'Use Current Location',
                      ),
                    ),
                    TextField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Address will appear here or enter manually',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<PickupBloc, PickupState>(
              builder: (context, state) {
                final isSaving = state is PickupLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            if (_selectedPlasticTypes.isEmpty ||
                                _weightController.text.isEmpty ||
                                _addressController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                ),
                              );
                              return;
                            }
                            final weight = double.tryParse(
                              _weightController.text.trim(),
                            );
                            if (weight == null || weight <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid weight'),
                                ),
                              );
                              return;
                            }
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              return;
                            }

                            final newPickup = PickupModel(
                              id: '',
                              userId: user.uid,
                              plasticType: _selectedPlasticTypes.join(', '),
                              estimatedWeight: weight,
                              address: _addressController.text.trim(),
                              latitude: _latitude ?? 0.0,
                              longitude: _longitude ?? 0.0,
                              scheduledTime: DateTime.now(),
                              status: PickupStatus.pending,
                              ratePerKg: 15.0,
                            );
                            context.read<PickupBloc>().add(
                              RequestPickupEvent(newPickup),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Confirm Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
