import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, loading, otpSent, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String phoneNumber;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.unauthenticated,
    this.phoneNumber = '',
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    Map<String, dynamic>? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    checkInitialAuthStatus();
  }

  Future<void> checkInitialAuthStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    final savedUser = await _repository.getUserData();
    final token = await _repository.getToken();

    if (isLoggedIn || savedUser != null || (token != null && token.isNotEmpty)) {
      final user = savedUser ?? await _repository.getMe() ?? {};
      final phone = user['phoneNumber']?.toString() ?? '';
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        phoneNumber: phone.isNotEmpty ? phone : state.phoneNumber,
      );
      return;
    }
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await _repository.sendOtp(phoneNumber);
      state = state.copyWith(
        status: AuthStatus.otpSent,
        phoneNumber: phoneNumber,
      );
      return true;
    } catch (e) {
      final errText = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        phoneNumber: phoneNumber,
        errorMessage: errText.isNotEmpty ? errText : 'Failed to send OTP code.',
      );
      return false;
    }
  }

  Future<bool> resendOtp(String phoneNumber) async {
    return await sendOtp(phoneNumber);
  }

  Future<bool> verifyOtp(String otp, {String? phoneNumber}) async {
    final phoneToVerify = (phoneNumber != null && phoneNumber.isNotEmpty)
        ? phoneNumber
        : state.phoneNumber;

    if (phoneToVerify.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Phone number missing. Please go back and enter phone number.',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final result = await _repository.verifyOtp(phoneToVerify, otp);
      final userData = (result['data']?['user'] as Map<String, dynamic>?) ?? {'phoneNumber': phoneToVerify};
      setPhoneNumber(phoneToVerify);
      await _repository.saveUserData(userData);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userData,
      );
      return true;
    } catch (e) {
      final errText = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: errText.isNotEmpty ? errText : 'Invalid 6-digit verification code. Please check and try again.',
      );
      return false;
    }
  }

  Future<bool> firebaseLogin(String idToken, String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _repository.firebaseLogin(idToken, phoneNumber);
      final userData = (result['data']?['user'] as Map<String, dynamic>?) ?? {'phoneNumber': phoneNumber};
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userData,
        phoneNumber: phoneNumber,
      );
      await _repository.saveUserData(userData);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void updateUserProfile({
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
    String? profilePic,
  }) {
    final updatedUser = {
      ...?state.user,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      if (address != null) 'fullAddress': address,
      if (profilePic != null) 'profilePic': profilePic,
    };
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: updatedUser,
      phoneNumber: phoneNumber,
    );
    _repository.saveUserData(updatedUser);
  }

  void setPhoneNumber(String phone) {
    final currentUser = state.user ?? {};
    final updatedUser = {
      ...currentUser,
      'phoneNumber': phone,
    };
    state = state.copyWith(
      status: AuthStatus.authenticated,
      phoneNumber: phone,
      user: updatedUser,
    );
    _repository.saveUserData(updatedUser);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
