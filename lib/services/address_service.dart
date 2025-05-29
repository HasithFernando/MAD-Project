import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftale/models/address_model.dart'; // Ensure this path is correct

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _userAddressesCollection() {
    final currentUserId = _userId; // Capture current user ID
    if (currentUserId == null) {
      throw Exception('User not logged in. Cannot access addresses.');
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('addresses');
  }

  Future<String> addAddress(AddressModel address) async {
    if (_userId == null) throw Exception('User not logged in');
    if (address.isDefault) {
      await _unsetAllDefaultAddresses();
    }
    DocumentReference docRef =
        await _userAddressesCollection().add(address.toMap());
    return docRef.id;
  }

  Future<void> updateAddress(AddressModel address) async {
    if (_userId == null) throw Exception('User not logged in');
    if (address.id == null)
      throw Exception('Address ID is required for update');
    if (address.isDefault) {
      await _unsetAllDefaultAddresses();
    }
    await _userAddressesCollection().doc(address.id).update(address.toMap());
  }

  Future<void> deleteAddress(String addressId) async {
    if (_userId == null) throw Exception('User not logged in');
    await _userAddressesCollection().doc(addressId).delete();
  }

  Stream<List<AddressModel>> getAddresses() {
    if (_userId == null) return Stream.value([]);
    return _userAddressesCollection()
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AddressModel.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  Future<AddressModel?> getDefaultAddress() async {
    if (_userId == null) return null;
    final querySnapshot = await _userAddressesCollection()
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return AddressModel.fromDocumentSnapshot(querySnapshot.docs.first);
    }
    return null;
  }

  Future<void> setDefaultAddress(String addressId) async {
    if (_userId == null) throw Exception('User not logged in');
    await _unsetAllDefaultAddresses();
    await _userAddressesCollection().doc(addressId).update({'isDefault': true});
  }

  Future<void> _unsetAllDefaultAddresses() async {
    if (_userId == null) throw Exception('User not logged in');
    final querySnapshot = await _userAddressesCollection()
        .where('isDefault', isEqualTo: true)
        .get();

    WriteBatch batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
