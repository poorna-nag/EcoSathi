import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:ecosathi/features/partner/data/models/partner_model.dart';
import 'package:ecosathi/features/partner/data/repositories/partner_repository.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';
import 'package:ecosathi/core/utils/logger.dart';

class PartnerRepositoryImpl implements PartnerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<PartnerModel?> getPartnerProfile(String partnerId) async {
    final doc = await _firestore.collection('partners').doc(partnerId).get();

    if (doc.exists && doc.data() != null) {
      return PartnerModel.fromMap(doc.data()!, doc.id);
    }

    // If not found, check if it's a valid user who needs a partner profile doc
    final userDoc = await _firestore.collection('users').doc(partnerId).get();
    if (userDoc.exists && userDoc.data()?['role'] == 'partner') {
      final userData = userDoc.data()!;
      final newPartner = PartnerModel(
        id: partnerId,
        name: userData['name'] ?? 'Partner',
        isOnline: false,
        todayPickups: 0,
        todayEarnings: 0.0,
        rating: 5.0,
      );

      await _firestore
          .collection('partners')
          .doc(partnerId)
          .set(newPartner.toMap());
      return newPartner;
    }

    return null;
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

  @override
  Future<void> updateTaskStatus(String pickupId, PickupStatus status) async {
    await _firestore.collection('pickups').doc(pickupId).update({
      'status': status.name,
    });
  }

  @override
  Stream<List<PickupModel>> getPartnerTasks(String partnerId) {
    return _firestore
        .collection('pickups')
        .where('partnerId', isEqualTo: partnerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PickupModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  @override
  Future<void> submitVerification({
    required String partnerId,
    required String aadharFrontPath,
    required String aadharBackPath,
    required String panFrontPath,
    required String panBackPath,
    required String selfiePath,
  }) async {
    final storageRef = FirebaseStorage.instance.ref();

    Future<String> uploadFile(String filePath, String name) async {
      try {
        final file = File(filePath);
        if (!await file.exists()) {
          logger.e('UPLOAD ERROR: File does not exist at $filePath');
          throw Exception('File does not exist: $name');
        }

        // Determine content type from extension or default to image/jpeg
        String contentType = 'image/jpeg';
        if (filePath.toLowerCase().endsWith('.png')) contentType = 'image/png';

        final ref = storageRef.child('partners/$partnerId/verification/$name');
        logger.i('Starting upload for $name to ${ref.fullPath}');

        final uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: contentType),
        );

        // Wait for the task to complete
        final snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          logger.i('Successfully uploaded $name. Requesting URL...');
          final url = await ref.getDownloadURL();
          logger.i('URL obtained for $name: $url');
          return url;
        } else {
          logger.e('Upload failed for $name with state: ${snapshot.state}');
          throw Exception('Upload failed for $name: ${snapshot.state}');
        }
      } catch (e) {
        logger.e('CATCH ERROR during $name upload: $e');
        rethrow;
      }
    }

    logger.i(
      'Step 1: Starting sequential document uploads for partner: $partnerId',
    );

    // Upload sequentially to avoid concurrent connection issues and better debugging
    final String aadharFrontUrl = await uploadFile(
      aadharFrontPath,
      'aadhar_front.jpg',
    );
    final String aadharBackUrl = await uploadFile(
      aadharBackPath,
      'aadhar_back.jpg',
    );
    final String panFrontUrl = await uploadFile(panFrontPath, 'pan_front.jpg');
    final String panBackUrl = await uploadFile(panBackPath, 'pan_back.jpg');
    final String selfieUrl = await uploadFile(selfiePath, 'selfie.jpg');

    logger.i('Step 2: All documents uploaded. Updating Firestore docs...');

    final Map<String, dynamic> updateData = {
      'verificationStatus': 'pending',
      'aadharFrontUrl': aadharFrontUrl,
      'aadharBackUrl': aadharBackUrl,
      'panFrontUrl': panFrontUrl,
      'panBackUrl': panBackUrl,
      'selfieUrl': selfieUrl,
      'submittedAt': FieldValue.serverTimestamp(),
    };

    // Save to both collections for redundancy
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .set(updateData, SetOptions(merge: true));

    await _firestore
        .collection('users')
        .doc(partnerId)
        .set(updateData, SetOptions(merge: true));

    logger.i('SUCCESS: Verification submitted and synced to both collections.');
  }
}
