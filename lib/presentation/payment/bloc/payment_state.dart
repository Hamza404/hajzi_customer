
import 'package:hajzi/presentation/payment/bloc/payment_cubit.dart';

class PaymentState {
  final PaymentStatus status;
  final bool isOrderLoading;
  final bool isSuccess;

  PaymentState({
    this.status = PaymentStatus.initial,
    this.isOrderLoading = false,
    this.isSuccess = false,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    bool? isOrderLoading,
    bool? isSuccess,
  }) {
    return PaymentState(
      status: status ?? this.status,
      isOrderLoading: isOrderLoading ?? this.isOrderLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
