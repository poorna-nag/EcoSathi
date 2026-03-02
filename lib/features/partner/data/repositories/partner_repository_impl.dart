import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecosathi/features/partner/data/models/partner_model.dart';
import 'package:ecosathi/features/partner/data/repositories/partner_repository.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';

class PartnerRepositoryImpl implements PartnerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<PartnerModel?> getPartnerProfile(String partnerId) async {
    final doc = await _firestore.collection('partners').doc(partnerId).get();
    if (!doc.exists || doc.data() == null) return null;
    return PartnerModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> updatePartnerStatus(String partnerId, bool isOnline) async {
    await _firestore.collection('partners').doc(partnerId).update({
      'isOnline': isOnline,
    });
  }

  @override
  Future<void> updatePartnerLocation(
    String partnerId,
    double lat,
    double lng,
  ) async {
    await _firestore.collection('partners').doc(partnerId).update({
      'location': GeoPoint(lat, lng),
    });
  }

  @override
  Stream<List<PickupModel>> getNearbyRequests(
    double lat,
    double lng,
    double radiusInKm,
  ) {
    // For simplicity, we just fetch all pending requests and mock radius logic on frontend or here.
    return _firestore
        .collection('pickups')
        .where('status', isEqualTo: PickupStatus.pending.name)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PickupModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  @override
  Future<void> acceptPickup(String partnerId, String pickupId) async {
    await _firestore.collection('pickups').doc(pickupId).update({
      'status': PickupStatus.assigned.name,
      'partnerId': partnerId,
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completePickup(
    String partnerId,
    String pickupId,
    double finalWeight,
    String photoProof,
  ) async {
    await _firestore.collection('pickups').doc(pickupId).update({
      'status': PickupStatus.completed.name,
      'finalWeight': finalWeight,
      'photoProof': photoProof,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}
