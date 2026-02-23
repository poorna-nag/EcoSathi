import 'package:equatable/equatable.dart';

enum UserRole { user, partner, admin }

class UserModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double totalEarnings;
  final double totalPlasticCollected;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.address,
    this.latitude,
    this.longitude,
    this.totalEarnings = 0.0,
    this.totalPlasticCollected = 0.0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      totalEarnings: map['totalEarnings']?.toDouble() ?? 0.0,
      totalPlasticCollected: map['totalPlasticCollected']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'totalEarnings': totalEarnings,
      'totalPlasticCollected': totalPlasticCollected,
    };
  }

  @override
  List<Object?> get props => [id, name, phone, role];
}
