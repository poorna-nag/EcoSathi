import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecosathi/features/partner/data/repositories/partner_repository.dart';
import 'partner_event.dart';
import 'partner_state.dart';

class PartnerBloc extends Bloc<PartnerEvent, PartnerState> {
  final PartnerRepository repository;

  PartnerBloc({required this.repository}) : super(PartnerInitial()) {
    on<LoadPartnerProfileEvent>(_onLoadPartnerProfile);
    on<LoadNearbyRequestsEvent>(_onLoadNearbyRequests);
    on<ToggleOnlineStatusEvent>(_onToggleOnlineStatus);
    on<AcceptPickupEvent>(_onAcceptPickup);
    on<UpdatePartnerLocationEvent>(_onUpdatePartnerLocation);
  }

  Future<void> _onLoadPartnerProfile(
    LoadPartnerProfileEvent event,
    Emitter<PartnerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PartnerLoaded) {
      emit(PartnerLoading());
    }

    try {
      final partner = await repository.getPartnerProfile(event.partnerId);
      if (partner != null) {
        if (currentState is PartnerLoaded) {
          emit(currentState.copyWith(partner: partner));
        } else {
          emit(PartnerLoaded(partner: partner, requests: const []));
        }
      } else {
        emit(const PartnerError('Partner profile not found'));
      }
    } catch (e) {
      emit(PartnerError(e.toString()));
    }
  }

  Future<void> _onLoadNearbyRequests(
    LoadNearbyRequestsEvent event,
    Emitter<PartnerState> emit,
  ) async {
    // currentState is not used here

    await emit.forEach(
      repository.getNearbyRequests(event.lat, event.lng, event.radiusInKm),
      onData: (requests) {
        if (state is PartnerLoaded) {
          return (state as PartnerLoaded).copyWith(requests: requests);
        } else {
          return NearbyRequestsLoaded(requests);
        }
      },
      onError: (error, stackTrace) => PartnerError(error.toString()),
    );
  }

  Future<void> _onToggleOnlineStatus(
    ToggleOnlineStatusEvent event,
    Emitter<PartnerState> emit,
  ) async {
    try {
      await repository.updatePartnerStatus(event.partnerId, event.isOnline);
      add(LoadPartnerProfileEvent(event.partnerId));
    } catch (e) {
      emit(PartnerError(e.toString()));
    }
  }

  Future<void> _onAcceptPickup(
    AcceptPickupEvent event,
    Emitter<PartnerState> emit,
  ) async {
    try {
      await repository.acceptPickup(event.partnerId, event.pickupId);
      // optionally trigger reload requests if needed
    } catch (e) {
      emit(PartnerError(e.toString()));
    }
  }

  Future<void> _onUpdatePartnerLocation(
    UpdatePartnerLocationEvent event,
    Emitter<PartnerState> emit,
  ) async {
    try {
      await repository.updatePartnerLocation(
        event.partnerId,
        event.lat,
        event.lng,
      );
    } catch (e) {
      // ignore
    }
  }
}
