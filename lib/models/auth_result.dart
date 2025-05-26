import 'package:firebase_auth/firebase_auth.dart';

/// Model class for authentication and profile operation results
class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final Map<String, dynamic>? data;

  const AuthResult({
    required this.success,
    this.error,
    this.user,
    this.data,
  });

  /// Factory constructor for successful result
  factory AuthResult.success({
    User? user,
    Map<String, dynamic>? data,
  }) {
    return AuthResult(
      success: true,
      user: user,
      data: data,
    );
  }

  /// Factory constructor for error result
  factory AuthResult.error({
    required String error,
    User? user,
    Map<String, dynamic>? data,
  }) {
    return AuthResult(
      success: false,
      error: error,
      user: user,
      data: data,
    );
  }

  /// Convert to Map for debugging or logging
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'error': error,
      'hasUser': user != null,
      'userId': user?.uid,
      'userEmail': user?.email,
      'data': data,
    };
  }

  /// String representation for debugging
  @override
  String toString() {
    return 'AuthResult(success: $success, error: $error, hasUser: ${user != null}, data: $data)';
  }

  /// Check if result has user data
  bool get hasUser => user != null;

  /// Check if result has error
  bool get hasError => error != null;

  /// Check if result has additional data
  bool get hasData => data != null && data!.isNotEmpty;
}
