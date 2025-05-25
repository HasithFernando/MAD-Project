import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(success: true, user: result.user);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult(success: false, error: _getErrorMessage(e.code));
    } catch (e) {
      print('General Exception: $e');
      return AuthResult(
          success: false, error: 'An unexpected error occurred: $e');
    }
  }

  // Create account with email and password
  Future<AuthResult> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check if Firebase is initialized
      if (FirebaseAuth.instance.app == null) {
        return AuthResult(success: false, error: 'Firebase not initialized');
      }

      print('Creating user with email: $email');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully: ${result.user?.uid}');

      if (result.user != null) {
        try {
          // Update display name
          await result.user!.updateDisplayName(name);
          print('Display name updated');

          // Save user data to Firestore
          await _saveUserToFirestore(result.user!, name, email);
          print('User data saved to Firestore');

          return AuthResult(success: true, user: result.user);
        } catch (firestoreError) {
          print('Firestore error: $firestoreError');
          // Even if Firestore fails, the user account was created successfully
          return AuthResult(success: true, user: result.user);
        }
      } else {
        return AuthResult(
            success: false, error: 'User creation failed - no user returned');
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult(success: false, error: _getErrorMessage(e.code));
    } catch (e) {
      print('General Exception during user creation: $e');
      return AuthResult(
          success: false, error: 'An unexpected error occurred: $e');
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
        'profileCompleted': false,
      });
      print('User data saved to Firestore successfully');
    } catch (e) {
      print('Error saving to Firestore: $e');
      throw e; // Re-throw to handle in calling method
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(success: true, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.code} - ${e.message}');
      return AuthResult(success: false, error: _getErrorMessage(e.code));
    } catch (e) {
      print('General error during password reset: $e');
      return AuthResult(success: false, error: 'An unexpected error occurred');
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

  // Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please check your Firebase configuration.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return 'Authentication failed: $errorCode. Please try again.';
    }
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
