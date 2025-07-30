import 'package:hajzi/presentation/dashboard/model/order_model.dart';

class ManageReservationsState {
  final bool isLoading;
  final String? error;
  final List<OrderModel> pendingOrders;
  final List<OrderModel> queuedOrders;
  final List<OrderModel> payedOrders;
  final List<OrderModel> completedOrders;

  ManageReservationsState({
    this.isLoading = false,
    this.error,
    this.pendingOrders = const [],
    this.queuedOrders = const [],
    this.payedOrders = const [],
    this.completedOrders = const [],
  });

  ManageReservationsState copyWith({
    bool? isLoading,
    String? error,
    List<OrderModel>? pendingOrders,
    List<OrderModel>? queuedOrders,
    List<OrderModel>? payedOrders,
    List<OrderModel>? completedOrders,
  }) {
    return ManageReservationsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      queuedOrders: queuedOrders ?? this.queuedOrders,
      payedOrders: payedOrders ?? this.payedOrders,
      completedOrders: completedOrders ?? this.completedOrders,
    );
  }
} 