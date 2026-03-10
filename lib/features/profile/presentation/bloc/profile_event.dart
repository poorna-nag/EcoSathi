import 'package:equatable/equatable.dart';
import 'package:ecosathi/features/pickup/data/models/address_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class AddAddressEvent extends ProfileEvent {
  final AddressModel address;
  const AddAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class DeleteAddressEvent extends ProfileEvent {
  final String addressId;
  const DeleteAddressEvent(this.addressId);

  @override
  List<Object?> get props => [addressId];
}
