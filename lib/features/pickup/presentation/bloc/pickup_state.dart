import 'package:equatable/equatable.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';

abstract class PickupState extends Equatable {
  const PickupState();

  @override
  List<Object?> get props => [];
}

class PickupInitial extends PickupState {}

class PickupLoading extends PickupState {}

class PickupsLoaded extends PickupState {
  final List<PickupModel> pickups;
  const PickupsLoaded(this.pickups);

  @override
  List<Object?> get props => [pickups];
}

class PickupRequestSuccess extends PickupState {}

class PickupError extends PickupState {
  final String message;
  const PickupError(this.message);

  @override
  List<Object?> get props => [message];
}
