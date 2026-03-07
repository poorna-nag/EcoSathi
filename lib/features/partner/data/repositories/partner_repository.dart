import '../models/partner_model.dart';
import 'package:ecosathi/features/pickup/data/models/pickup_model.dart';

abstract class PartnerRepository {
  Future<PartnerModel?> getPartnerProfile(String partnerId);
  Future<void> updatePartnerStatus(String partnerId, bool isOnline);
  Future<void> updatePartnerLocation(String partnerId, double lat, double lng);
  Stream<List<PickupModel>> getNearbyRequests(
    double lat,
    double lng,
    double radiusInKm,
  );
  Future<void> acceptPickup(String partnerId, String pickupId);
  Future<void> completePickup(
    String partnerId,
    String pickupId,
    double finalWeight,
    String photoProof,
  );
  Future<void> updateTaskStatus(String pickupId, PickupStatus status);
  Stream<List<PickupModel>> getPartnerTasks(String partnerId);
  Future<void> submitVerification({
    required String partnerId,
    required String aadharFrontPath,
    required String aadharBackPath,
    required String panFrontPath,
    required String panBackPath,
    required String selfiePath,
  });
}
