import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/widgets/custom_toast.dart';
import 'package:pay/pay.dart';
import '../dashboard/model/order_model.dart';
import 'bloc/payment_cubit.dart';
import 'bloc/payment_state.dart';

class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<PaymentCubit>(
      create: (context) => PaymentCubit(),
      child: PaymentScreen(),
    );
  }

  final String _googlePayConfig = '''{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA", "MASTERCARD"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "example",
            "gatewayMerchantId": "exampleGatewayMerchantId"
          }
        }
      }
    ],
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "0.29",
      "currencyCode": "SAR"
    },
    "merchantInfo": {
      "merchantId": "01234567890123456789",
      "merchantName": "Test Merchant"
    }
  }
}''';


  @override
  Widget build(BuildContext context) {

    final order = ModalRoute.of(context)!.settings.arguments as OrderModel;

    const _paymentItems = [
      PaymentItem(
        label: 'Total',
        amount: '0.29',
        status: PaymentItemStatus.final_price,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state.status == PaymentStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment successful!')),
            );
          } else if (state.status == PaymentStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment failed!')),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildBanner(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GooglePayButton(
                  paymentConfiguration: PaymentConfiguration.fromJsonString(_googlePayConfig),
                  paymentItems: _paymentItems,
                  type: GooglePayButtonType.pay,
                  width: double.infinity,
                  onPaymentResult: (result) => onGooglePayResult(result, context, order),
                  loadingIndicator: const Center(child: CircularProgressIndicator()),
                  margin: const EdgeInsets.only(top: 15.0),
                ),
              ),

              if(state.isOrderLoading)... [
                const SizedBox(height: 30),
                const CircularProgressIndicator(color: Colors.black)
              ]
            ],
          );
        },
      ),
    );
  }

  void onGooglePayResult(paymentResult, BuildContext context, OrderModel order) {
    if (paymentResult.containsKey('paymentMethodData')) {
      final data = paymentResult['paymentMethodData'];

      if (data['tokenizationData']?['type'] == 'PAYMENT_GATEWAY' &&
          data['tokenizationData']?['token'] != null) {
        CustomToast.show(context, message: 'Payment successful');

        context.read<PaymentCubit>().updatePaymentStatus(order.id, 'pm_1Hxxxxxxx');

      } else {
        CustomToast.show(context, message: 'Payment failed');
      }
    } else {
      CustomToast.show(context, message: 'Payment was not completed');
    }
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Image.asset('assets/ic_hajzi_banner.png', fit: BoxFit.cover),
    );
  }
}