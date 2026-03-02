import 'package:equatable/equatable.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<PickupModel> orders;
  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderTrackingState extends OrdersState {
  final PickupModel order;
  const OrderTrackingState(this.order);

  @override
  List<Object?> get props => [order];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
