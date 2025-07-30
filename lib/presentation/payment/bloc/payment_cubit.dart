import 'package:flutter_bloc/flutter_bloc.dart';

enum PaymentStatus { initial, success, failure }

class PaymentCubit extends Cubit<PaymentStatus> {
  PaymentCubit() : super(PaymentStatus.initial);

  void makePayment() {
    emit(PaymentStatus.success);
  }
}