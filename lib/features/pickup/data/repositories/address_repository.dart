import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';

class AddressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _addressCollection =>
      _firestore.collection('users').doc(_userId).collection('addresses');

  Future<List<AddressModel>> getAddresses() async {
    if (_userId.isEmpty) return [];
    final snapshot = await _addressCollection.get();
    return snapshot.docs
        .map(
          (doc) =>
              AddressModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  Future<void> addAddress(AddressModel address) async {
    if (_userId.isEmpty) return;
    await _addressCollection.add(address.toMap());
  }

  Future<void> updateAddress(AddressModel address) async {
    if (_userId.isEmpty) return;
    await _addressCollection.doc(address.id).update(address.toMap());
  }

  Future<void> deleteAddress(String addressId) async {
    if (_userId.isEmpty) return;
    await _addressCollection.doc(addressId).delete();
  }

  Future<void> setDefaultAddress(String addressId) async {
    if (_userId.isEmpty) return;
    final batch = _firestore.batch();

    // Set all addresses to not default
    final allAddresses = await _addressCollection.get();
    for (var doc in allAddresses.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }

    // Set the specific address to default
    batch.update(_addressCollection.doc(addressId), {'isDefault': true});

    await batch.commit();
  }
}
