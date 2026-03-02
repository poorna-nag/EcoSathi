import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';
import '../repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<PickupModel>> getOrders(String userId) async {
    final snapshot = await _firestore
        .collection('pickups')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PickupModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<PickupModel>> getPartnerOrders(String partnerId) async {
    final snapshot = await _firestore
        .collection('pickups')
        .where('partnerId', isEqualTo: partnerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PickupModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<PickupModel?> trackOrder(String orderId) {
    return _firestore.collection('pickups').doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PickupModel.fromMap(doc.data()!, doc.id);
    });
  }
}
