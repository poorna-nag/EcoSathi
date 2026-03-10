import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecosathi/features/pickup/data/repositories/address_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AddressRepository addressRepository;

  ProfileBloc({required this.addressRepository}) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<AddAddressEvent>(_onAddAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final addresses = await addressRepository.getAddresses();
      emit(ProfileLoaded(addresses));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAddAddress(
    AddAddressEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await addressRepository.addAddress(event.address);
      add(const LoadProfileEvent());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddressEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await addressRepository.deleteAddress(event.addressId);
      add(const LoadProfileEvent());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
