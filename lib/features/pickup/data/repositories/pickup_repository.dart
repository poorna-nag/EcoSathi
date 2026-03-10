import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pickup_model.dart';

class PickupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _pickupCollection => _firestore.collection('pickups');

  Future<List<PickupModel>> getPickups() async {
    if (_userId.isEmpty) return [];

    final snapshot = await _pickupCollection
        .where('userId', isEqualTo: _userId)
        .get();

    final pickups = snapshot.docs
        .map(
          (doc) =>
              PickupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    // Sort in memory to avoid needing a composite index in Firestore
    pickups.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    return pickups;
  }

  Future<void> addPickup(PickupModel pickup) async {
    if (_userId.isEmpty) return;

    // Add the current user ID to the pickup if not present
    final pickupData = pickup.toMap();
    pickupData['userId'] = _userId;

    await _pickupCollection.add(pickupData);
  }

  Future<void> updatePickupStatus(String pickupId, PickupStatus status) async {
    await _pickupCollection.doc(pickupId).update({'status': status.name});
  }

  Future<PickupModel?> getPickupById(String pickupId) async {
    final doc = await _pickupCollection.doc(pickupId).get();
    if (doc.exists) {
      return PickupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
