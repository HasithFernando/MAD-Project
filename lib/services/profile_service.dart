import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thriftale/models/auth_result.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Create a unique filename
      final String fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create reference to storage location
      final Reference storageRef =
          _storage.ref().child('profile_images').child(fileName);

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadURL = await snapshot.ref.getDownloadURL();

      print('Profile image uploaded successfully: $downloadURL');
      return downloadURL;
    } on FirebaseException catch (e) {
      print('Firebase error uploading image: ${e.code} - ${e.message}');
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete profile image from Firebase Storage
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      print('Profile image deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }

  /// Update user profile in Firestore
  Future<AuthResult> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      // Add metadata
      profileData['updatedAt'] = FieldValue.serverTimestamp();

      // Update user document
      await _usersCollection.doc(userId).set(
            profileData,
            SetOptions(merge: true),
          );

      print('User profile updated successfully');
      return AuthResult(success: true);
    } on FirebaseException catch (e) {
      print('Firebase error updating profile: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      print('Error updating user profile: $e');
      return AuthResult(
        success: false,
        error: 'Failed to update profile: $e',
      );
    }
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final DocumentSnapshot doc = await _usersCollection.doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        print('User profile retrieved successfully');
        return data;
      } else {
        print('User profile not found');
        return null;
      }
    } on FirebaseException catch (e) {
      print('Firebase error getting profile: ${e.code} - ${e.message}');
      throw Exception('Failed to get profile: ${e.message}');
    } catch (e) {
      print('Error getting user profile: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Check if user profile is complete
  Future<bool> isProfileComplete(String userId) async {
    try {
      final Map<String, dynamic>? profile = await getUserProfile(userId);

      if (profile == null) return false;

      // Check required fields
      final bool hasName = profile['name'] != null &&
          profile['name'].toString().trim().isNotEmpty;
      final bool hasPhone = profile['phone'] != null &&
          profile['phone'].toString().trim().isNotEmpty;
      final bool hasGender = profile['gender'] != null &&
          profile['gender'].toString().trim().isNotEmpty;
      final bool isCompleted = profile['profileCompleted'] == true;

      return hasName && hasPhone && hasGender && isCompleted;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  /// Create initial user profile
  Future<AuthResult> createUserProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      final Map<String, dynamic> profileData = {
        'name': name,
        'email': email,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _usersCollection.doc(userId).set(profileData);

      print('Initial user profile created successfully');
      return AuthResult(success: true);
    } on FirebaseException catch (e) {
      print('Firebase error creating profile: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      print('Error creating user profile: $e');
      return AuthResult(
        success: false,
        error: 'Failed to create profile: $e',
      );
    }
  }

  /// Update specific profile fields
  Future<AuthResult> updateProfileField({
    required String userId,
    required String fieldName,
    required dynamic value,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        fieldName: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Profile field $fieldName updated successfully');
      return AuthResult(success: true);
    } on FirebaseException catch (e) {
      print('Firebase error updating field: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      print('Error updating profile field: $e');
      return AuthResult(
        success: false,
        error: 'Failed to update $fieldName: $e',
      );
    }
  }

  /// Get user profile stream for real-time updates
  Stream<DocumentSnapshot> getUserProfileStream(String userId) {
    return _usersCollection.doc(userId).snapshots();
  }

  /// Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int limit = 10,
  }) async {
    try {
      final String searchQuery = query.toLowerCase().trim();

      if (searchQuery.isEmpty) return [];

      // Search by name
      Query nameQuery = _usersCollection
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .limit(limit);

      final QuerySnapshot nameSnapshot = await nameQuery.get();

      // Search by email
      Query emailQuery = _usersCollection
          .where('email', isGreaterThanOrEqualTo: searchQuery)
          .where('email', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .limit(limit);

      final QuerySnapshot emailSnapshot = await emailQuery.get();

      // Combine results and remove duplicates
      final Set<String> userIds = {};
      final List<Map<String, dynamic>> results = [];

      for (var doc in [...nameSnapshot.docs, ...emailSnapshot.docs]) {
        if (!userIds.contains(doc.id)) {
          userIds.add(doc.id);
          final data = doc.data() as Map<String, dynamic>;
          data['userId'] = doc.id;
          results.add(data);
        }
      }

      return results;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // You can expand this to include more statistics
      final Map<String, dynamic> stats = {
        'profileViews': 0,
        'itemsSold': 0,
        'itemsBought': 0,
        'rating': 0.0,
        'reviewCount': 0,
        'joinDate': null,
      };

      final userData = await getUserProfile(userId);
      if (userData != null) {
        stats['joinDate'] = userData['createdAt'];
        // Add more stats from other collections as needed
      }

      return stats;
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  /// Validate profile data
  Map<String, String> validateProfileData(Map<String, dynamic> data) {
    final Map<String, String> errors = {};

    // Validate name
    if (data['name'] == null || data['name'].toString().trim().isEmpty) {
      errors['name'] = 'Name is required';
    } else if (data['name'].toString().trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    } else if (data['name'].toString().trim().length > 50) {
      errors['name'] = 'Name must be less than 50 characters';
    }

    // Validate phone
    if (data['phone'] == null || data['phone'].toString().trim().isEmpty) {
      errors['phone'] = 'Phone number is required';
    } else {
      final String phone =
          data['phone'].toString().replaceAll(RegExp(r'[^\d]'), '');
      if (phone.length < 9) {
        errors['phone'] = 'Please enter a valid phone number';
      } else if (phone.length > 15) {
        errors['phone'] = 'Phone number is too long';
      }
    }

    // Validate gender
    if (data['gender'] == null || data['gender'].toString().trim().isEmpty) {
      errors['gender'] = 'Gender is required';
    } else {
      final List<String> validGenders = ['Male', 'Female', 'Other'];
      if (!validGenders.contains(data['gender'].toString())) {
        errors['gender'] = 'Please select a valid gender';
      }
    }

    return errors;
  }

  /// Delete user profile and associated data
  Future<AuthResult> deleteUserProfile(String userId) async {
    try {
      // Get user profile to check for profile image
      final userData = await getUserProfile(userId);

      // Delete profile image if exists
      if (userData != null && userData['profileImageUrl'] != null) {
        await deleteProfileImage(userData['profileImageUrl']);
      }

      // Delete user document
      await _usersCollection.doc(userId).delete();

      print('User profile deleted successfully');
      return AuthResult(success: true);
    } on FirebaseException catch (e) {
      print('Firebase error deleting profile: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      print('Error deleting user profile: $e');
      return AuthResult(
        success: false,
        error: 'Failed to delete profile: $e',
      );
    }
  }

  /// Get Firebase error messages
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'permission-denied':
        return 'You do not have permission to perform this action';
      case 'not-found':
        return 'User profile not found';
      case 'already-exists':
        return 'Profile already exists';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later';
      case 'unauthenticated':
        return 'Please sign in to continue';
      case 'deadline-exceeded':
        return 'Request timeout. Please check your internet connection';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again';
      default:
        return 'An error occurred. Please try again';
    }
  }

  /// Batch update multiple users (admin function)
  Future<AuthResult> batchUpdateUsers({
    required List<String> userIds,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      for (String userId in userIds) {
        final DocumentReference userRef = _usersCollection.doc(userId);
        batch.update(userRef, updateData);
      }

      await batch.commit();

      print('Batch update completed for ${userIds.length} users');
      return AuthResult(success: true);
    } on FirebaseException catch (e) {
      print('Firebase error in batch update: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      print('Error in batch update: $e');
      return AuthResult(
        success: false,
        error: 'Failed to update users: $e',
      );
    }
  }

  /// Get users with pagination
  Future<List<Map<String, dynamic>>> getUsersWithPagination({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _usersCollection;

      // Add ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      // Add pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['userId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting users with pagination: $e');
      return [];
    }
  }

  /// Update user last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last active: $e');
      // Don't throw error as this is not critical
    }
  }

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final QuerySnapshot snapshot = await _usersCollection
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['userId'] = doc.id;
        return data;
      }

      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final QuerySnapshot snapshot = await _usersCollection
          .where('username', isEqualTo: username.toLowerCase().trim())
          .limit(1)
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  /// Generate unique username suggestions
  Future<List<String>> generateUsernameSuggestions(String baseName) async {
    try {
      final List<String> suggestions = [];
      final String cleanBase =
          baseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

      // Generate variations
      for (int i = 1; i <= 5; i++) {
        final String suggestion = '$cleanBase$i';
        if (await isUsernameAvailable(suggestion)) {
          suggestions.add(suggestion);
        }
      }

      // Add random number suggestions
      for (int i = 0; i < 3; i++) {
        final int random = DateTime.now().millisecondsSinceEpoch % 1000;
        final String suggestion = '$cleanBase$random';
        if (await isUsernameAvailable(suggestion)) {
          suggestions.add(suggestion);
        }
      }

      return suggestions;
    } catch (e) {
      print('Error generating username suggestions: $e');
      return [];
    }
  }
}
