import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import '../../data/repositories/orders_repository.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository _ordersRepository;

  OrdersBloc(this._ordersRepository) : super(OrdersInitial()) {
    on<LoadUserOrdersEvent>(_onLoadUserOrders);
    on<LoadPartnerOrdersEvent>(_onLoadPartnerOrders);
    on<TrackOrderEvent>(_onTrackOrder);
  }

  void _onLoadUserOrders(
    LoadUserOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final orders = await _ordersRepository.getOrders(event.userId);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  void _onLoadPartnerOrders(
    LoadPartnerOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final orders = await _ordersRepository.getPartnerOrders(event.partnerId);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  void _onTrackOrder(TrackOrderEvent event, Emitter<OrdersState> emit) {
    _ordersRepository.trackOrder(event.orderId).listen((order) {
      if (order != null) {
        emit(OrderTrackingState(order));
      }
    });
  }
}
