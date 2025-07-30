import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/client/api_manager.dart';
import 'package:hajzi/presentation/dashboard/model/order_model.dart';
import 'manage_reservations_state.dart';

class ManageReservationsCubit extends Cubit<ManageReservationsState> {
  ManageReservationsCubit() : super(ManageReservationsState()) {
    fetchUserOrders();
  }

  Future<void> fetchUserOrders() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await ApiManager.get('Order/GetUserOrder');
      if (response['isSuccess'] == true && response['content'] is List) {
        final orders = (response['content'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
        
        final pendingOrders = orders.where((order) =>
            order.status.toLowerCase() == 'pending').toList();
        final queuedOrders = orders.where((order) => 
            order.status.toLowerCase() == 'queued').toList();
        final payedOrders = orders.where((order) => 
            order.status.toLowerCase() == 'accepted' ||
            order.status.toLowerCase() == 'cancelled').toList();
        final completedOrders = orders.where((order) => 
            order.status.toLowerCase() == 'completed').toList();
        
        emit(state.copyWith(
          isLoading: false,
          pendingOrders: pendingOrders,
          queuedOrders: queuedOrders,
          payedOrders: payedOrders,
          completedOrders: completedOrders,
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

  Future<void> refreshOrders() async {
    await fetchUserOrders();
  }
} 