import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get current user (alternative getter for backward compatibility)
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create user with email and password
  Future<AuthResult> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('Starting Firebase user creation...');

      // Check if Firebase is initialized
      if (FirebaseAuth.instance.app == null) {
        return AuthResult(success: false, error: 'Firebase not initialized');
      }

      print('Creating user with email: $email');

      // Create user in Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        print('Firebase user created successfully: ${user.uid}');

        try {
          // Update user display name
          await user.updateDisplayName(name.trim());
          print('Display name updated');

          // Save user data to Firestore
          await _saveUserToFirestore(user, name.trim(), email.trim());
          print('User data saved to Firestore');

          return AuthResult(success: true, user: user);
        } catch (firestoreError) {
          print('Firestore error: $firestoreError');
          // Delete the Firebase Auth user if profile creation fails
          try {
            await user.delete();
          } catch (deleteError) {
            print('Failed to delete user after Firestore error: $deleteError');
          }
          return AuthResult(
            success: false,
            error: 'Failed to create user profile: $firestoreError',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'User creation failed - no user returned',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      print('General Exception during user creation: $e');
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign in process...');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        print('User signed in successfully: ${result.user!.uid}');

        // Update last active timestamp
        await _updateLastActive(result.user!.uid);

        return AuthResult(success: true, user: result.user);
      } else {
        return AuthResult(
          success: false,
          error: 'Sign in failed',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      print('General Exception: $e');
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserToFirestore(
      User user, String name, String email) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'profileCompleted': false,
      });
      print('User data saved to Firestore successfully');
    } catch (e) {
      print('Error saving to Firestore: $e');
      throw e; // Re-throw to handle in calling method
    }
  }

  // Update last active timestamp
  Future<void> _updateLastActive(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last active: $e');
      // Don't throw error as this is not critical
    }
  }

  // Sign out
  Future<AuthResult> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
      return AuthResult(success: true);
    } catch (e) {
      print('Error signing out: $e');
      return AuthResult(
        success: false,
        error: 'Failed to sign out: $e',
      );
    }
  }

  // Reset password
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('Password reset email sent to: $email');
      return AuthResult(success: true, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.code} - ${e.message}');
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      print('General error during password reset: $e');
      return AuthResult(success: false, error: 'An unexpected error occurred');
    }
  }

  // Update user profile (display name and photo URL)
  Future<AuthResult> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final User? user = getCurrentUser();
      if (user == null) {
        return AuthResult(
          success: false,
          error: 'No user signed in',
        );
      }

      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Reload user to get updated data
      await user.reload();

      print('User profile updated successfully');
      return AuthResult(success: true, user: _auth.currentUser);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error updating profile: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Error updating user profile: $e');
      return AuthResult(
        success: false,
        error: 'Failed to update profile: $e',
      );
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final User? user = getCurrentUser();
      if (user == null) {
        return AuthResult(
          success: false,
          error: 'No user signed in',
        );
      }

      // Re-authenticate user with current password
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      print('Password updated successfully');
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error changing password: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Error changing password: $e');
      return AuthResult(
        success: false,
        error: 'Failed to change password: $e',
      );
    }
  }

  // Update email
  Future<AuthResult> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final User? user = getCurrentUser();
      if (user == null) {
        return AuthResult(
          success: false,
          error: 'No user signed in',
        );
      }

      // Re-authenticate user
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.updateEmail(newEmail.trim());

      // Update email in Firestore
      await updateUserData(user.uid, {'email': newEmail.trim()});

      print('Email updated successfully');
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error updating email: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Error updating email: $e');
      return AuthResult(
        success: false,
        error: 'Failed to update email: $e',
      );
    }
  }

  // Delete user account
  Future<AuthResult> deleteAccount({required String password}) async {
    try {
      final User? user = getCurrentUser();
      if (user == null) {
        return AuthResult(
          success: false,
          error: 'No user signed in',
        );
      }

      // Re-authenticate user
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();

      print('User account deleted successfully');
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error deleting account: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Error deleting account: $e');
      return AuthResult(
        success: false,
        error: 'Failed to delete account: $e',
      );
    }
  }

  // Send email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final User? user = getCurrentUser();
      if (user == null) {
        return AuthResult(
          success: false,
          error: 'No user signed in',
        );
      }

      if (user.emailVerified) {
        return AuthResult(
          success: false,
          error: 'Email is already verified',
        );
      }

      await user.sendEmailVerification();
      print('Email verification sent');
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      print(
          'Firebase Auth error sending verification: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      print('Error sending email verification: $e');
      return AuthResult(
        success: false,
        error: 'Failed to send verification email: $e',
      );
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data in Firestore
  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // Check if user profile is complete
  Future<bool> isUserProfileComplete() async {
    final User? user = getCurrentUser();
    if (user == null) return false;

    try {
      final userData = await getUserData(user.uid);
      return userData?['profileCompleted'] ?? false;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfileData() async {
    final User? user = getCurrentUser();
    if (user == null) return null;

    return await getUserData(user.uid);
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    return getCurrentUser() != null;
  }

  // Get user email
  String? getUserEmail() {
    return getCurrentUser()?.email;
  }

  // Get user display name
  String? getUserDisplayName() {
    return getCurrentUser()?.displayName;
  }

  // Get user photo URL
  String? getUserPhotoURL() {
    return getCurrentUser()?.photoURL;
  }

  // Check if email is verified
  bool isEmailVerified() {
    return getCurrentUser()?.emailVerified ?? false;
  }

  // Reload current user
  Future<void> reloadUser() async {
    final User? user = getCurrentUser();
    if (user != null) {
      await user.reload();
    }
  }

  // Convert Firebase error codes to user-friendly messages (updated)
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'The provided credentials are invalid';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'missing-verification-code':
        return 'Please enter the verification code';
      case 'missing-verification-id':
        return 'Missing verification ID';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later';
      default:
        return 'An error occurred. Please try again';
    }
  }

  // Legacy method name for backward compatibility
  String _getErrorMessage(String errorCode) {
    return _getAuthErrorMessage(errorCode);
  }
}

// Auth result class to handle responses
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? message;

  AuthResult({
    required this.success,
    this.user,
    this.error,
    this.message,
  });
}
