import 'package:equatable/equatable.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';

abstract class PartnerEvent extends Equatable {
  const PartnerEvent();

  @override
  List<Object?> get props => [];
}

class LoadPartnerProfileEvent extends PartnerEvent {
  final String partnerId;
  const LoadPartnerProfileEvent(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}

class LoadNearbyRequestsEvent extends PartnerEvent {
  final double lat;
  final double lng;
  final double radiusInKm;

  const LoadNearbyRequestsEvent({
    required this.lat,
    required this.lng,
    required this.radiusInKm,
  });

  @override
  List<Object?> get props => [lat, lng, radiusInKm];
}

class ToggleOnlineStatusEvent extends PartnerEvent {
  final String partnerId;
  final bool isOnline;

  const ToggleOnlineStatusEvent(this.partnerId, this.isOnline);

  @override
  List<Object?> get props => [partnerId, isOnline];
}

class AcceptPickupEvent extends PartnerEvent {
  final String partnerId;
  final String pickupId;

  const AcceptPickupEvent(this.partnerId, this.pickupId);

  @override
  List<Object?> get props => [partnerId, pickupId];
}

class UpdatePartnerLocationEvent extends PartnerEvent {
  final String partnerId;
  final double lat;
  final double lng;

  const UpdatePartnerLocationEvent(this.partnerId, this.lat, this.lng);

  @override
  List<Object?> get props => [partnerId, lat, lng];
}

class LoadPartnerTasksEvent extends PartnerEvent {
  final String partnerId;
  const LoadPartnerTasksEvent(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}

class UpdateTaskStatusEvent extends PartnerEvent {
  final String pickupId;
  final PickupStatus status;

  const UpdateTaskStatusEvent(this.pickupId, this.status);

  @override
  List<Object?> get props => [pickupId, status];
}

class SubmitVerificationEvent extends PartnerEvent {
  final String partnerId;
  final String aadharFrontPath;
  final String aadharBackPath;
  final String panFrontPath;
  final String panBackPath;
  final String selfiePath;

  const SubmitVerificationEvent({
    required this.partnerId,
    required this.aadharFrontPath,
    required this.aadharBackPath,
    required this.panFrontPath,
    required this.panBackPath,
    required this.selfiePath,
  });

  @override
  List<Object?> get props => [
    partnerId,
    aadharFrontPath,
    aadharBackPath,
    panFrontPath,
    panBackPath,
    selfiePath,
  ];
}
