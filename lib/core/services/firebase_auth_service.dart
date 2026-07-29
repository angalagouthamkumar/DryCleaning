import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuthService() {
    try {
      _auth.setSettings(appVerificationDisabledForTesting: true);
    } catch (_) {}
  }

  String? _verificationId;
  int? _resendToken;

  String? get verificationId => _verificationId;

  /// Initiate Phone Verification by sending SMS to user's phone number
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
    required Function(AuthCredential credential) onAutoVerified,
  }) async {
    try {
      // Format number to international E.164 if needed (e.g. +91XXXXXXXXXX)
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$formattedPhone';
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('[FIREBASE AUTH] SMS Code auto-retrieved successfully!');
          }
          onAutoVerified(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('[FIREBASE AUTH ERROR] Verification failed: ${e.message}');
          }
          onError(e.message ?? 'SMS Verification failed. Check phone number.');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (kDebugMode) {
            print('[FIREBASE AUTH] SMS Verification Code dispatched to $formattedPhone!');
          }
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verify 6-digit SMS Code entered by user and retrieve Firebase ID Token
  Future<String?> verifyCode(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Verification session expired. Please request SMS code again.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    return await signInWithCredential(credential);
  }

  /// Sign in with an AuthCredential (e.g. auto-verified) and retrieve Firebase ID Token
  Future<String?> signInWithCredential(AuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      final idToken = await user.getIdToken();
      return idToken;
    }
    return null;
  }
}

