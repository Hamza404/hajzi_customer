import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/presentation/payment/bloc/payment_state.dart';
import 'package:hajzi/widgets/custom_toast.dart';
import 'package:pay/pay.dart';
import 'bloc/payment_cubit.dart';

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

    const _paymentItems = [
      PaymentItem(
        label: 'Total',
        amount: '0.29',
        status: PaymentItemStatus.final_price,
      )
    ];

    return BlocProvider(
      create: (_) => PaymentCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<PaymentCubit, PaymentStatus>(
          listener: (context, state) {
            if (state == PaymentStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment successful!')),
              );
            } else if (state == PaymentStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment failed!')),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildBanner(),
                Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GooglePayButton(
                      paymentConfiguration: PaymentConfiguration.fromJsonString(_googlePayConfig),
                      paymentItems: _paymentItems,
                      type: GooglePayButtonType.pay,
                      width: double.infinity,
                      onPaymentResult: (result) => onGooglePayResult(result, context),
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      margin: const EdgeInsets.only(top: 15.0),
                    ))),
              ],
            );
          },
        ),
      ),
    );
  }

  void onGooglePayResult(paymentResult, context) {
    print(paymentResult);

    if (paymentResult.containsKey('paymentMethodData')) {
      final data = paymentResult['paymentMethodData'];

      if (data['tokenizationData']?['type'] == 'PAYMENT_GATEWAY' &&
          data['tokenizationData']?['token'] != null) {
        CustomToast.show(context, message: 'Payment successful');


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