import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/order_repository.dart';
import 'auth_provider.dart';

class OrdersState {
  final bool isLoading;
  final List<Map<String, dynamic>> orders;
  final String? errorMessage;

  OrdersState({
    this.isLoading = false,
    this.orders = const [],
    this.errorMessage,
  });

  OrdersState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? orders,
    String? errorMessage,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderRepository _repository;
  final String? _userPhoneNumber;
  Timer? _pollingTimer;

  OrdersNotifier(this._repository, this._userPhoneNumber) : super(OrdersState()) {
    fetchOrders();
    _startRealtimePolling();
  }

  void _startRealtimePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      fetchOrders(silent: true);
    });
  }

  Future<void> fetchOrders({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final fetched = await _repository.fetchOrders(phoneNumber: _userPhoneNumber);
      state = state.copyWith(isLoading: false, orders: fetched);
    } catch (e) {
      if (!silent) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  Future<Map<String, dynamic>?> placeOrder(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final createdOrder = await _repository.createOrder(payload);
      final finalOrder = createdOrder ?? payload;
      final updatedList = [finalOrder, ...state.orders];
      state = state.copyWith(isLoading: false, orders: updatedList);
      fetchOrders(silent: true);
      return finalOrder;
    } catch (e) {
      final updatedList = [payload, ...state.orders];
      state = state.copyWith(isLoading: false, orders: updatedList);
      return payload;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final updatedList = state.orders.map((o) {
      final id = (o['_id'] ?? o['orderId'] ?? o['id']).toString();
      if (id == orderId || o['orderId'] == orderId) {
        return {...o, 'status': newStatus};
      }
      return o;
    }).toList();
    state = state.copyWith(orders: updatedList);
    await _repository.updateOrderStatus(orderId, newStatus);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final userPhone = authState.user?['phoneNumber'] ?? authState.phoneNumber;
  return OrdersNotifier(repository, userPhone);
});
