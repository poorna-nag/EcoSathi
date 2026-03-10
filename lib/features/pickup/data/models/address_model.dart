import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  final String id;
  final String label;
  final String houseNumber;
  final String street;
  final String city;
  final String zipCode;
  final String landmark;
  final String address; // Full formatted address
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.houseNumber,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.landmark,
    required this.address,
    this.isDefault = false,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map, String docId) {
    return AddressModel(
      id: docId,
      label: map['label'] ?? 'Home',
      houseNumber: map['houseNumber'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      zipCode: map['zipCode'] ?? '',
      landmark: map['landmark'] ?? '',
      address: map['address'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'houseNumber': houseNumber,
      'street': street,
      'city': city,
      'zipCode': zipCode,
      'landmark': landmark,
      'address': address,
      'isDefault': isDefault,
    };
  }

  @override
  List<Object?> get props => [
    id,
    label,
    houseNumber,
    street,
    city,
    zipCode,
    landmark,
    address,
    isDefault,
  ];
}
