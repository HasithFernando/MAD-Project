import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID safely
  String? get userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Check if user is authenticated
  bool get isUserAuthenticated {
    return FirebaseAuth.instance.currentUser != null;
  }

  // Create order from cart items
  Future<String> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> paymentMethod,
    required double totalAmount,
    required double totalCO2Saved,
    required int itemsRescued,
  }) async {
    try {
      // Check authentication first
      if (!isUserAuthenticated || userId == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      print('Creating order for user: $userId'); // Debug log

      // Create order document with proper error handling
      DocumentReference orderRef = await _firestore.collection('orders').add({
        'userId': userId,
        'items': cartItems,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'orderSummary': {
          'subtotal': totalAmount,
          'deliveryFee': 0.0, // Free delivery
          'total': totalAmount,
          'co2Saved': totalCO2Saved,
          'itemsRescued': itemsRescued,
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Order created with ID: ${orderRef.id}'); // Debug log
      return orderRef.id;
    } catch (e) {
      print('Error creating order: $e'); // Debug log
      if (e.toString().contains('permission-denied')) {
        throw Exception(
            'Permission denied. Please check your Firestore security rules or contact support.');
      }
      throw Exception('Failed to create order: $e');
    }
  }

  // Process payment (placeholder for actual payment integration)
  Future<bool> processPayment({
    required String orderId,
    required double amount,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      if (!isUserAuthenticated || userId == null) {
        throw Exception('User not authenticated');
      }

      print('Processing payment for order: $orderId'); // Debug log

      // In a real app, integrate with payment gateway like Stripe, PayPal, etc.
      // For now, we'll simulate successful payment
      await Future.delayed(const Duration(seconds: 2));

      // Update order status to paid
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'paid',
        'paymentStatus': 'completed',
        'paymentDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Payment processed successfully for order: $orderId'); // Debug log
      return true;
    } catch (e) {
      print('Payment processing error: $e'); // Debug log

      try {
        // Update order status to payment failed
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'payment_failed',
          'paymentStatus': 'failed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (updateError) {
        print('Failed to update order status: $updateError');
      }

      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied during payment processing.');
      }
      throw Exception('Payment processing failed: $e');
    }
  }

  // Clear cart after successful order
  Future<void> clearCart() async {
    try {
      if (!isUserAuthenticated || userId == null) {
        throw Exception('User not authenticated');
      }

      print('Clearing cart for user: $userId'); // Debug log

      QuerySnapshot cartSnapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .get();

      if (cartSnapshot.docs.isEmpty) {
        print('No cart items to clear');
        return;
      }

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('Cart cleared successfully'); // Debug log
    } catch (e) {
      print('Error clearing cart: $e'); // Debug log
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied while clearing cart.');
      }
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Complete checkout process with better error handling
  Future<Map<String, dynamic>> completeCheckout({
    required List<Map<String, dynamic>> cartItems,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> paymentMethod,
    required double totalAmount,
    required double totalCO2Saved,
    required int itemsRescued,
  }) async {
    try {
      // Validate inputs
      if (cartItems.isEmpty) {
        return {
          'success': false,
          'message': 'Cart is empty. Please add items before checkout.',
        };
      }

      if (!isUserAuthenticated || userId == null) {
        return {
          'success': false,
          'message': 'Please log in to continue with checkout.',
        };
      }

      print('Starting checkout process for user: $userId'); // Debug log

      // Step 1: Create order
      String orderId = await createOrder(
        cartItems: cartItems,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        totalCO2Saved: totalCO2Saved,
        itemsRescued: itemsRescued,
      );

      print('Order created successfully: $orderId'); // Debug log

      // Step 2: Process payment
      bool paymentSuccess = await processPayment(
        orderId: orderId,
        amount: totalAmount,
        paymentMethod: paymentMethod,
      );

      if (paymentSuccess) {
        print('Payment successful, completing checkout...'); // Debug log

        // Step 3: Clear cart
        await clearCart();

        // Step 4: Update product quantities/availability
        await _updateProductInventory(cartItems);

        // Step 5: Create user activity record
        await _createUserActivity(
            orderId, totalAmount, totalCO2Saved, itemsRescued);

        print('Checkout completed successfully'); // Debug log

        return {
          'success': true,
          'orderId': orderId,
          'message': 'Order placed successfully!',
        };
      } else {
        return {
          'success': false,
          'orderId': orderId,
          'message': 'Payment failed. Please try again.',
        };
      }
    } catch (e) {
      print('Checkout error: $e'); // Debug log

      String errorMessage = 'Checkout failed. Please try again.';

      if (e.toString().contains('permission-denied')) {
        errorMessage =
            'Permission denied. Please contact support or check your account status.';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('User not authenticated')) {
        errorMessage = 'Please log in again and try checkout.';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error': e.toString(), // Include detailed error for debugging
      };
    }
  }

  // Update product inventory after purchase
  Future<void> _updateProductInventory(
      List<Map<String, dynamic>> cartItems) async {
    try {
      if (!isUserAuthenticated || userId == null) {
        print('User not authenticated for inventory update');
        return;
      }

      print('Updating product inventory...'); // Debug log

      WriteBatch batch = _firestore.batch();

      for (Map<String, dynamic> item in cartItems) {
        if (item['productId'] != null) {
          DocumentReference productRef =
              _firestore.collection('products').doc(item['productId']);

          // Mark product as sold or reduce quantity
          batch.update(productRef, {
            'status': 'sold',
            'soldAt': FieldValue.serverTimestamp(),
            'soldTo': userId,
          });
        }
      }

      await batch.commit();
      print('Product inventory updated successfully'); // Debug log
    } catch (e) {
      print('Error updating product inventory: $e');
      // Don't throw error here as it's not critical for checkout completion
    }
  }

  // Create user activity record for analytics
  Future<void> _createUserActivity(String orderId, double totalAmount,
      double totalCO2Saved, int itemsRescued) async {
    try {
      if (!isUserAuthenticated || userId == null) {
        print('User not authenticated for activity record');
        return;
      }

      print('Creating user activity record...'); // Debug log

      await _firestore.collection('user_activities').add({
        'userId': userId,
        'type': 'purchase',
        'orderId': orderId,
        'amount': totalAmount,
        'co2Saved': totalCO2Saved,
        'itemsRescued': itemsRescued,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('User activity record created successfully'); // Debug log
    } catch (e) {
      print('Error creating user activity: $e');
      // Don't throw error here as it's not critical for checkout completion
    }
  }

  // Get user's shipping addresses
  Stream<List<Map<String, dynamic>>> getUserAddresses() {
    if (!isUserAuthenticated || userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('user_addresses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Add new shipping address
  Future<void> addShippingAddress(Map<String, dynamic> address) async {
    try {
      if (!isUserAuthenticated || userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('user_addresses').add({
        'userId': userId,
        ...address,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied. Cannot add address.');
      }
      throw Exception('Failed to add address: $e');
    }
  }

  // Get user's payment methods
  Stream<List<Map<String, dynamic>>> getUserPaymentMethods() {
    if (!isUserAuthenticated || userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('user_payment_methods')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Add new payment method
  Future<void> addPaymentMethod(Map<String, dynamic> paymentMethod) async {
    try {
      if (!isUserAuthenticated || userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('user_payment_methods').add({
        'userId': userId,
        ...paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied. Cannot add payment method.');
      }
      throw Exception('Failed to add payment method: $e');
    }
  }

  // Get order details
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('orders').doc(orderId).get();

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied. Cannot access order details.');
      }
      throw Exception('Failed to get order: $e');
    }
  }

  // Get user's order history
  Stream<List<Map<String, dynamic>>> getUserOrders() {
    if (!isUserAuthenticated || userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList())
        .handleError((error) {
      print('Error getting user orders: $error');
      return <Map<String, dynamic>>[];
    });
  }

  // Calculate order summary from cart items
  Future<Map<String, dynamic>> calculateOrderSummary(
      List<Map<String, dynamic>> cartItems) async {
    double subtotal = 0;
    double totalCO2 = 0;
    int itemsRescued = cartItems.length;

    // You might want to fetch product details to get accurate pricing
    for (Map<String, dynamic> item in cartItems) {
      // Assuming cart items have price and co2Saved fields
      subtotal += (item['price'] ?? 0.0);
      totalCO2 += (item['co2Saved'] ?? 0.0);
    }

    double deliveryFee = 0.0; // Free delivery
    double total = subtotal + deliveryFee;

    return {
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'co2Saved': totalCO2,
      'itemsRescued': itemsRescued,
    };
  }
}
