import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/client/api_manager.dart';
import 'package:hajzi/presentation/dashboard/model/order_model.dart';
import 'manage_reservations_state.dart';

class ManageReservationsCubit extends Cubit<ManageReservationsState> {
  ManageReservationsCubit() : super(ManageReservationsState()) {
    refreshOrders(true);
  }

  Future<void> fetchUserOrders(bool isRefresh) async {
    emit(state.copyWith(isLoading: isRefresh, error: null));
    try {
      final response = await ApiManager.get('Order/GetUserOrder');
      if (response['isSuccess'] == true && response['content'] is List) {
        final orders = (response['content'] as List)
            .map((e) => GetOrder.fromJson(e))
            .toList();
        
        final pendingOrders = orders.where((order) =>
            order.orders.status.toLowerCase() == 'pending').toList();
        final queuedOrders = orders.where((order) =>
            order.orders.status.toLowerCase() == 'queued').toList();
        final payedOrders = orders.where((order) =>
            order.orders.status.toLowerCase() == 'accepted').toList();
        final completedOrders = orders.where((order) => 
            order.orders.status.toLowerCase() == 'completed').toList();
        final cancelledOrders = orders.where((order) =>
            order.orders.status.toLowerCase() == 'cancelled').toList();
        
        emit(state.copyWith(
          isLoading: false,
          pendingOrders: pendingOrders,
          queuedOrders: queuedOrders,
          payedOrders: payedOrders,
          completedOrders: completedOrders,
          cancelled: cancelledOrders
        ));
      } else {
        emit(state.copyWith(
          isLoading: false, 
          error: response['messages']?.toString() ?? 'Unknown error'
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> refreshOrders(bool isRefresh) async {
    await fetchUserOrders(isRefresh);
  }
} 