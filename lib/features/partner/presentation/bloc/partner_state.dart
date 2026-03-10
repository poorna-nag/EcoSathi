import 'package:equatable/equatable.dart';
import 'package:ecosathi/features/partner/data/models/partner_model.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';

abstract class PartnerState extends Equatable {
  const PartnerState();

  @override
  List<Object?> get props => [];
}

class PartnerInitial extends PartnerState {}

class PartnerLoading extends PartnerState {}

class PartnerLoaded extends PartnerState {
  final PartnerModel partner;
  final List<PickupModel> requests;
  final List<PickupModel> tasks;

  const PartnerLoaded({
    required this.partner,
    required this.requests,
    required this.tasks,
  });

  @override
  List<Object?> get props => [partner, requests, tasks];

  PartnerLoaded copyWith({
    PartnerModel? partner,
    List<PickupModel>? requests,
    List<PickupModel>? tasks,
  }) {
    return PartnerLoaded(
      partner: partner ?? this.partner,
      requests: requests ?? this.requests,
      tasks: tasks ?? this.tasks,
    );
  }
}

class PartnerError extends PartnerState {
  final String message;
  const PartnerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Keeping these just in case they are used elsewhere, but PartnerLoaded is preferred
class PartnerProfileLoaded extends PartnerState {
  final PartnerModel partner;
  const PartnerProfileLoaded(this.partner);
  @override
  List<Object?> get props => [partner];
}

class NearbyRequestsLoaded extends PartnerState {
  final List<PickupModel> requests;
  const NearbyRequestsLoaded(this.requests);
  @override
  List<Object?> get props => [requests];
}
