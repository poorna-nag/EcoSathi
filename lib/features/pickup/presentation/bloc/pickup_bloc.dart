import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecosathi/features/pickup/data/repositories/pickup_repository.dart';
import 'pickup_event.dart';
import 'pickup_state.dart';

class PickupBloc extends Bloc<PickupEvent, PickupState> {
  final PickupRepository repository;

  PickupBloc({required this.repository}) : super(PickupInitial()) {
    on<LoadPickupsEvent>(_onLoadPickups);
    on<RequestPickupEvent>(_onRequestPickup);
  }

  Future<void> _onLoadPickups(
    LoadPickupsEvent event,
    Emitter<PickupState> emit,
  ) async {
    emit(PickupLoading());
    try {
      final pickups = await repository.getPickups();
      emit(PickupsLoaded(pickups));
    } catch (e) {
      emit(PickupError(e.toString()));
    }
  }

  Future<void> _onRequestPickup(
    RequestPickupEvent event,
    Emitter<PickupState> emit,
  ) async {
    final currentState = state;
    emit(PickupLoading());
    try {
      await repository.addPickup(event.pickup);
      emit(PickupRequestSuccess());
      // Reload the pickups after adding
      add(const LoadPickupsEvent());
    } catch (e) {
      emit(PickupError(e.toString()));
      // Revert back to previous state if possible
      if (currentState is PickupsLoaded) {
        emit(currentState);
      }
    }
  }
}
