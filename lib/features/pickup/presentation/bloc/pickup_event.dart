import 'package:equatable/equatable.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';

abstract class PickupEvent extends Equatable {
  const PickupEvent();

  @override
  List<Object?> get props => [];
}

class LoadPickupsEvent extends PickupEvent {
  const LoadPickupsEvent();
}

class RequestPickupEvent extends PickupEvent {
  final PickupModel pickup;
  const RequestPickupEvent(this.pickup);

  @override
  List<Object?> get props => [pickup];
}

class DeletePickupEvent extends PickupEvent {
  final String pickupId;
  const DeletePickupEvent(this.pickupId);

  @override
  List<Object?> get props => [pickupId];
}
