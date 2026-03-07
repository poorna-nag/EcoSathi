import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecosathi/features/partner/data/repositories/partner_repository.dart';
import 'partner_event.dart';
import 'partner_state.dart';

class PartnerBloc extends Bloc<PartnerEvent, PartnerState> {
  final PartnerRepository repository;

  PartnerBloc({required this.repository}) : super(PartnerInitial()) {
    on<LoadPartnerProfileEvent>(_onLoadPartnerProfile);
    on<LoadNearbyRequestsEvent>(_onLoadNearbyRequests);
    on<LoadPartnerTasksEvent>(_onLoadPartnerTasks);
    on<UpdateTaskStatusEvent>(_onUpdateTaskStatus);
    on<ToggleOnlineStatusEvent>(_onToggleOnlineStatus);
    on<AcceptPickupEvent>(_onAcceptPickup);
    on<UpdatePartnerLocationEvent>(_onUpdatePartnerLocation);
    on<SubmitVerificationEvent>(_onSubmitVerification);
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
          emit(
            PartnerLoaded(
              partner: partner,
              requests: const [],
              tasks: const [],
            ),
          );
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

  Future<void> _onLoadPartnerTasks(
    LoadPartnerTasksEvent event,
    Emitter<PartnerState> emit,
  ) async {
    await emit.forEach(
      repository.getPartnerTasks(event.partnerId),
      onData: (tasks) {
        if (state is PartnerLoaded) {
          return (state as PartnerLoaded).copyWith(tasks: tasks);
        }
        return state; // Should ideally ensure PartnerLoaded exists
      },
      onError: (error, stackTrace) => PartnerError(error.toString()),
    );
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatusEvent event,
    Emitter<PartnerState> emit,
  ) async {
    try {
      await repository.updateTaskStatus(event.pickupId, event.status);
    } catch (e) {
      emit(PartnerError(e.toString()));
    }
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

  Future<void> _onSubmitVerification(
    SubmitVerificationEvent event,
    Emitter<PartnerState> emit,
  ) async {
    emit(PartnerLoading());
    try {
      await repository.submitVerification(
        partnerId: event.partnerId,
        aadharFrontPath: event.aadharFrontPath,
        aadharBackPath: event.aadharBackPath,
        panFrontPath: event.panFrontPath,
        panBackPath: event.panBackPath,
        selfiePath: event.selfiePath,
      );
      add(LoadPartnerProfileEvent(event.partnerId));
    } catch (e) {
      emit(PartnerError(e.toString()));
    }
  }
}
