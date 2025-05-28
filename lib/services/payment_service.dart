import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftale/models/payment_method_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Get user's payment methods
  Stream<List<PaymentMethod>> getPaymentMethods() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PaymentMethod.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add new payment method
  Future<String> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      // If this is the first payment method, make it default
      final existingMethods = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .get();

      bool shouldBeDefault =
          existingMethods.docs.isEmpty || paymentMethod.isDefault;

      // If making this default, unset other defaults
      if (shouldBeDefault) {
        await _unsetAllDefaults();
      }

      PaymentMethod newPaymentMethod = paymentMethod.copyWith(
        isDefault: shouldBeDefault,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .add(newPaymentMethod.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  // Update payment method
  Future<void> updatePaymentMethod(
      String paymentMethodId, PaymentMethod paymentMethod) async {
    try {
      // If making this default, unset other defaults
      if (paymentMethod.isDefault) {
        await _unsetAllDefaults();
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(paymentMethodId)
          .update(paymentMethod.toMap());
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  // Delete payment method
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(paymentMethodId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  // Set default payment method
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      // First unset all defaults
      await _unsetAllDefaults();

      // Then set the selected one as default
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(paymentMethodId)
          .update({'isDefault': true});
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  // Get default payment method - Updated to handle no payment methods scenario
  Future<PaymentMethod?> getDefaultPaymentMethod() async {
    try {
      // First try to get the default payment method
      var snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PaymentMethod.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }

      // If no default found, get any payment method and make it default
      snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Make this payment method the default
        await setDefaultPaymentMethod(snapshot.docs.first.id);
        return PaymentMethod.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }

      // If no payment methods exist, return a default placeholder
      return _createDefaultPaymentMethod();
    } catch (e) {
      // Return default payment method in case of error
      return _createDefaultPaymentMethod();
    }
  }

  // Create a default payment method for display purposes
  PaymentMethod _createDefaultPaymentMethod() {
    return PaymentMethod(
      id: 'default',
      type: 'visa',
      cardNumber: '1234',
      expiryMonth: 12,
      expiryYear: 2025,
      cardHolderName: 'Default Card',
      isDefault: true,
      createdAt: DateTime.now(),
      cvv: '',
    );
  }

  // Private method to unset all default payment methods
  Future<void> _unsetAllDefaults() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('paymentMethods')
        .where('isDefault', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
