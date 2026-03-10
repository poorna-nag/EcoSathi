import 'package:equatable/equatable.dart';

enum PickupStatus { pending, assigned, picked, completed, cancelled }

class PickupModel extends Equatable {
  final String id;
  final String userId;
  final String? partnerId;
  final String plasticType;
  final double estimatedWeight;
  final double? finalWeight;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime scheduledTime;
  final PickupStatus status;
  final double ratePerKg;
  final double? totalAmount;
  final String? photoProof;

  const PickupModel({
    required this.id,
    required this.userId,
    this.partnerId,
    required this.plasticType,
    required this.estimatedWeight,
    this.finalWeight,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.scheduledTime,
    required this.status,
    required this.ratePerKg,
    this.totalAmount,
    this.photoProof,
  });

  factory PickupModel.fromMap(Map<String, dynamic> map, String docId) {
    return PickupModel(
      id: docId,
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'],
      plasticType: map['plasticType'] ?? '',
      estimatedWeight: map['estimatedWeight']?.toDouble() ?? 0.0,
      finalWeight: map['finalWeight']?.toDouble(),
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      scheduledTime: (map['scheduledTime'] as dynamic).toDate(),
      status: PickupStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PickupStatus.pending,
      ),
      ratePerKg: map['ratePerKg']?.toDouble() ?? 15.0,
      totalAmount: map['totalAmount']?.toDouble(),
      photoProof: map['photoProof'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'partnerId': partnerId,
      'plasticType': plasticType,
      'estimatedWeight': estimatedWeight,
      'finalWeight': finalWeight,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledTime': scheduledTime,
      'status': status.name,
      'ratePerKg': ratePerKg,
      'totalAmount': totalAmount,
      'photoProof': photoProof,
    };
  }

  @override
  List<Object?> get props => [id, userId, status];
}
