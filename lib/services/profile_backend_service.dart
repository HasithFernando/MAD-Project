import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thriftale/models/auth_result.dart';

class ProfileBackendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Update complete profile with image, name, and email
  Future<AuthResult> updateCompleteProfile({
    required String userId,
    required String name,
    required String email,
    File? profileImage,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'name': name.trim(),
        'email': email.toLowerCase().trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Handle profile image upload if provided
      if (profileImage != null) {
        print('Uploading new profile image...');

        // Get current user data to delete old image if exists
        final currentUserData = await getUserProfile(userId);

        // Upload new image
        final String newImageUrl = await _uploadProfileImage(
          userId: userId,
          imageFile: profileImage,
        );

        // Delete old image if exists
        if (currentUserData != null &&
            currentUserData['profileImageUrl'] != null &&
            currentUserData['profileImageUrl'].toString().isNotEmpty) {
          await _deleteOldProfileImage(currentUserData['profileImageUrl']);
        }

        updateData['profileImageUrl'] = newImageUrl;
        print('Profile image updated successfully');
      }

      // Update user document in Firestore
      await _usersCollection.doc(userId).set(
            updateData,
            SetOptions(merge: true),
          );

      print('Complete profile updated successfully');
      return AuthResult(success: true);
    } on FirebaseException catch (e) {
      print(
          'Firebase error updating complete profile: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      print('Error updating complete profile: $e');
      return AuthResult(
        success: false,
        error: 'Failed to update profile: $e',
      );
    }
  }

  /// Update only profile image
  Future<AuthResult> updateProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      print('Starting profile image update...');

      // Get current user data to delete old image
      final currentUserData = await getUserProfile(userId);

      // Upload new image
      final String newImageUrl = await _uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );

      // Delete old image if exists
      if (currentUserData != null &&
          currentUserData['profileImageUrl'] != null &&
          currentUserData['profileImageUrl'].toString().isNotEmpty) {
        await _deleteOldProfileImage(currentUserData['profileImageUrl']);
      }

      // Update Firestore with new image URL
      await _usersCollection.doc(userId).update({
        'profileImageUrl': newImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Profile image updated successfully');
      return AuthResult(success: true);
    } on FirebaseException catch (e) {
      print('Firebase error updating profile image: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      print('Error updating profile image: $e');
      return AuthResult(
        success: false,
        error: 'Failed to update profile image: $e',
      );
    }
  }

  /// Update only name and email (no image)
  Future<AuthResult> updateBasicProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      print('Updating basic profile info...');

      final Map<String, dynamic> updateData = {
        'name': name.trim(),
        'email': email.toLowerCase().trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _usersCollection.doc(userId).update(updateData);

      print('Basic profile updated successfully');
      return AuthResult(success: true);
    } on FirebaseException catch (e) {
      print('Firebase error updating basic profile: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      print('Error updating basic profile: $e');
      return AuthResult(
        success: false,
        error: 'Failed to update profile: $e',
      );
    }
  }

  /// Get user profile data from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('Fetching user profile for: $userId');

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

  /// Get real-time profile updates
  Stream<DocumentSnapshot> getProfileStream(String userId) {
    return _usersCollection.doc(userId).snapshots();
  }

  /// Private method to upload profile image to Firebase Storage
  Future<String> _uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Create unique filename with timestamp
      final String fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create storage reference
      final Reference storageRef =
          _storage.ref().child('profile_images').child(fileName);

      // Upload file with metadata
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

      // Wait for upload completion
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadURL = await snapshot.ref.getDownloadURL();

      print('Profile image uploaded: $downloadURL');
      return downloadURL;
    } on FirebaseException catch (e) {
      print('Firebase storage error: ${e.code} - ${e.message}');
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Private method to delete old profile image
  Future<void> _deleteOldProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('firebase')) {
        final Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
        print('Old profile image deleted successfully');
      }
    } catch (e) {
      print('Error deleting old profile image: $e');
      // Don't throw error as this is not critical for the update process
    }
  }

  /// Validate profile update data
  Map<String, String> validateProfileData({
    required String name,
    required String email,
    File? imageFile,
  }) {
    final Map<String, String> errors = {};

    // Validate name
    if (name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    } else if (name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    } else if (name.trim().length > 50) {
      errors['name'] = 'Name must be less than 50 characters';
    }

    // Validate email
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!_isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    // Validate image file if provided
    if (imageFile != null) {
      if (!imageFile.existsSync()) {
        errors['image'] = 'Selected image file does not exist';
      } else {
        final int fileSizeInBytes = imageFile.lengthSync();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          errors['image'] = 'Image size must be less than 5MB';
        }

        final String fileName = imageFile.path.toLowerCase();
        if (!fileName.endsWith('.jpg') &&
            !fileName.endsWith('.jpeg') &&
            !fileName.endsWith('.png')) {
          errors['image'] = 'Only JPG, JPEG, and PNG images are allowed';
        }
      }
    }

    return errors;
  }

  /// Check if profile exists
  Future<bool> profileExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }

  /// Remove profile image only (keep other data)
  Future<AuthResult> removeProfileImage(String userId) async {
    try {
      // Get current user data
      final currentUserData = await getUserProfile(userId);

      if (currentUserData != null &&
          currentUserData['profileImageUrl'] != null &&
          currentUserData['profileImageUrl'].toString().isNotEmpty) {
        // Delete image from storage
        await _deleteOldProfileImage(currentUserData['profileImageUrl']);

        // Remove image URL from Firestore
        await _usersCollection.doc(userId).update({
          'profileImageUrl': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('Profile image removed successfully');
        return AuthResult(success: true);
      } else {
        return AuthResult(success: true); // No image to remove
      }
    } catch (e) {
      print('Error removing profile image: $e');
      return AuthResult(
        success: false,
        error: 'Failed to remove profile image: $e',
      );
    }
  }

  /// Private helper method to validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
      case 'storage/unauthorized':
        return 'Unauthorized to upload images';
      case 'storage/canceled':
        return 'Upload was canceled';
      case 'storage/quota-exceeded':
        return 'Storage quota exceeded';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
