import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/rider_repository.dart';

class RiderState {
  final bool isOnDuty;
  final bool isLoading;
  final List<dynamic> orders;
  final String? errorMessage;
  final String phoneNumber;

  RiderState({
    this.isOnDuty = true,
    this.isLoading = false,
    this.orders = const [],
    this.errorMessage,
    this.phoneNumber = '',
  });

  RiderState copyWith({
    bool? isOnDuty,
    bool? isLoading,
    List<dynamic>? orders,
    String? errorMessage,
    String? phoneNumber,
  }) {
    return RiderState(
      isOnDuty: isOnDuty ?? this.isOnDuty,
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class RiderNotifier extends StateNotifier<RiderState> {
  final RiderRepository _repository;

  RiderNotifier(this._repository) : super(RiderState());

  void toggleDuty() {
    state = state.copyWith(isOnDuty: !state.isOnDuty);
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null, phoneNumber: phoneNumber);
    try {
      await _repository.sendOtp(phoneNumber);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.verifyOtp(state.phoneNumber, otp);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> fetchTasks({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      String currentPhone = state.phoneNumber;
      if (currentPhone.isEmpty) {
        final savedPhone = await _repository.getRiderPhone();
        if (savedPhone != null && savedPhone.isNotEmpty) {
          currentPhone = savedPhone;
        }
      }

      final List<dynamic> rawTasks = await _repository.getRiderTasks();

      // Sort newest orders first (top of queue)
      rawTasks.sort((a, b) {
        final aTime = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      // Detect if new orders arrived to trigger vibration alert
      if (state.orders.isNotEmpty && rawTasks.length > state.orders.length) {
        try {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 300));
          await HapticFeedback.vibrate();
        } catch (_) {}
      }

      state = state.copyWith(isLoading: false, orders: rawTasks, phoneNumber: currentPhone);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> acceptTask(String orderId, String flowType) async {
    try {
      await _repository.acceptTask(orderId, flowType);
      await fetchTasks();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTaskStep(String orderId, String status) async {
    try {
      await _repository.updateTaskStep(orderId, status);
      await fetchTasks();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = RiderState();
  }
}

final riderStateProvider = StateNotifierProvider<RiderNotifier, RiderState>((ref) {
  final repository = ref.watch(riderRepositoryProvider);
  return RiderNotifier(repository);
});
