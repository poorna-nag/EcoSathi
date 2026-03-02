import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';

abstract class OrdersRepository {
  Future<List<PickupModel>> getOrders(String userId);
  Future<List<PickupModel>> getPartnerOrders(String partnerId);
  Stream<PickupModel?> trackOrder(String orderId);
}
