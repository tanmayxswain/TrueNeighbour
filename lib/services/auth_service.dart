import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current authenticated user (null if not logged in).
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (sign-in, sign-out, token refresh).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send an OTP to [phone]. Works for both new and existing users.
  /// Phone must include country code, e.g. "+911234567890".
  /// Returns the verificationId needed to complete sign in.
  Future<String> verifyPhoneNumber(String phone) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (mostly Android only).
        // If this happens, we could sign in immediately, but typically
        // we wait for the user to enter the code or let the stream handle it.
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timed out. Just in case it wasn't completed yet.
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  /// Verify the OTP [smsCode] using the [verificationId].
  /// Returns the [UserCredential] on success.
  Future<UserCredential> signInWithCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Update the current user's metadata (e.g. display name after signup).
  Future<void> updateUserMetadata(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user != null && data.containsKey('display_name')) {
      await user.updateDisplayName(data['display_name'] as String);
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
