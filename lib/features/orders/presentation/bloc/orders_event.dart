import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserOrdersEvent extends OrdersEvent {
  final String userId;
  const LoadUserOrdersEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadPartnerOrdersEvent extends OrdersEvent {
  final String partnerId;
  const LoadPartnerOrdersEvent(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}

class TrackOrderEvent extends OrdersEvent {
  final String orderId;
  const TrackOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
