import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecosathi/core/constants/app_colors.dart';
import 'package:ecosathi/features/pickup/data/models/address_model.dart';
import 'package:ecosathi/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecosathi/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecosathi/features/profile/presentation/bloc/profile_state.dart';

class AddressListScreen extends StatefulWidget {
  final bool selectMode;
  const AddressListScreen({super.key, this.selectMode = false});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.selectMode ? 'Select Address' : 'My Addresses',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<AddressModel> addresses = [];
          if (state is ProfileLoaded) {
            addresses = state.addresses;
          }

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    size: 64,
                    color: AppColors.textHint.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No addresses saved yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: addresses.length,
            itemBuilder: (context, index) =>
                _buildAddressCard(addresses[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add New Address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: address.isDefault
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (widget.selectMode) Navigator.pop(context, address.address);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconForLabel(address.label),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        address.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.selectMode)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        context.read<ProfileBloc>().add(
                          DeleteAddressEvent(address.id),
                        );
                      } else if (value == 'edit') {
                        _showAddressDialog(context, address: address);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.business_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  void _showAddressDialog(BuildContext context, {AddressModel? address}) {
    final houseNoController = TextEditingController(text: address?.houseNumber);
    final streetController = TextEditingController(text: address?.street);
    final landmarkController = TextEditingController(text: address?.landmark);
    final cityController = TextEditingController(text: address?.city);
    final zipController = TextEditingController(text: address?.zipCode);
    String currentLabelType = address?.label ?? 'Home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      address == null ? 'Add New Address' : 'Edit Address',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: ['Home', 'Work', 'Other']
                      .map(
                        (label) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: currentLabelType == label,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => currentLabelType = label);
                              }
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  houseNoController,
                  'Flat / House No',
                  Icons.home_work_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  streetController,
                  'Street / Area',
                  Icons.streetview_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  landmarkController,
                  'Landmark',
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        cityController,
                        'City',
                        Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        zipController,
                        'Zip Code',
                        Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (houseNoController.text.isEmpty ||
                          streetController.text.isEmpty ||
                          cityController.text.isEmpty ||
                          zipController.text.isEmpty) {
                        return;
                      }
                      final fullAddress =
                          "${houseNoController.text}, ${streetController.text}, ${cityController.text} - ${zipController.text}";
                      final newAddress = AddressModel(
                        id: address?.id ?? '',
                        label: currentLabelType,
                        houseNumber: houseNoController.text,
                        street: streetController.text,
                        landmark: landmarkController.text,
                        city: cityController.text,
                        zipCode: zipController.text,
                        address: fullAddress,
                        isDefault: address?.isDefault ?? false,
                      );
                      context.read<ProfileBloc>().add(
                        AddAddressEvent(newAddress),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      address == null ? 'Save Address' : 'Update Address',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
