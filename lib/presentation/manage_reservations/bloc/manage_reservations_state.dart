import 'package:hajzi/presentation/dashboard/model/order_model.dart';

class ManageReservationsState {
  final bool isLoading;
  final String? error;
  final List<GetOrder> pendingOrders;
  final List<GetOrder> queuedOrders;
  final List<GetOrder> payedOrders;
  final List<GetOrder> completedOrders;
  final List<GetOrder> cancelled;
  final bool orderCancelLoading;

  ManageReservationsState({
    this.isLoading = false,
    this.error,
    this.pendingOrders = const [],
    this.queuedOrders = const [],
    this.payedOrders = const [],
    this.completedOrders = const [],
    this.cancelled = const [],
    this.orderCancelLoading = false
  });

  ManageReservationsState copyWith({
    bool? isLoading,
    String? error,
    List<GetOrder>? pendingOrders,
    List<GetOrder>? queuedOrders,
    List<GetOrder>? payedOrders,
    List<GetOrder>? completedOrders,
    List<GetOrder>? cancelled,
    bool? orderCancelLoading
  }) {
    return ManageReservationsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      queuedOrders: queuedOrders ?? this.queuedOrders,
      payedOrders: payedOrders ?? this.payedOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelled: cancelled ?? this.cancelled,
      orderCancelLoading: orderCancelLoading ?? this.orderCancelLoading,
    );
  }
} 