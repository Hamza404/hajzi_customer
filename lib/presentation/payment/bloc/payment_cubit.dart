import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/utils/navigator_service.dart';
import 'package:hajzi/presentation/payment/bloc/payment_state.dart';
import '../../../client/api_manager.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentState(status: PaymentStatus.initial));

  void makePayment() {
    emit(state.copyWith(status: PaymentStatus.success));
  }

  Future<void> updatePaymentStatus(int id, String paymentId) async {
    emit(state.copyWith(isOrderLoading: true));
    try {
      final response = await ApiManager.get('Order/UpdateQueueOrderStatus?id=$id&paymentId=$paymentId');
      if (response['isSuccess'] == true) {
        emit(state.copyWith(isOrderLoading: false));
        NavigatorService.popWithData('onRefresh');
      } else {
        emit(state.copyWith(isOrderLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isOrderLoading: false));
    }
  }
}

enum PaymentStatus { initial, success, failure }