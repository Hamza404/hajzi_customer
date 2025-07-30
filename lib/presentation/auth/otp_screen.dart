import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../theme/app_colors.dart';
import '../../theme/font_styles.dart';
import 'bloc/auth_cubit.dart';

class OtpScreen extends StatefulWidget {

  const OtpScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: const OtpScreen(),
    );
  }

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late Timer _timer;
  int _start = 60;
  bool canResend = false;
  String otpCode = "";

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  void startTimer() {
    setState(() {
      _start = 60;
      canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          canResend = true;
        });
      } else {
        setState(() => _start--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullNumber = ModalRoute.of(context)!.settings.arguments as String;
    final formattedNumber = fullNumber.replaceAll(RegExp(r'\D'), '');
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = (screenWidth - 60) / 6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 46),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.light_gray,
                shape: const CircleBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Verify Phone Number",
                  style: FontStyles.fontW800.copyWith(fontSize: 25),
                )
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text: "We sent a 6-digit code to ",
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: formattedNumber,
                        style: FontStyles.fontW600.copyWith(
                            color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            PinCodeTextField(
              appContext: context,
              length: 6,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              onChanged: (value) {
                otpCode = value;
              },
              onCompleted: (pin) {
                context.read<AuthCubit>().verifyOtp(number: fullNumber, pin: pin);
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: fieldWidth * 1.2,
                fieldWidth: fieldWidth,
                activeColor: AppColors.black,
                selectedColor: AppColors.black,
                inactiveColor: Colors.grey.shade400,
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Text(
                '( 00:${_start.toString().padLeft(2, '0')} )',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 16),

            const Center(
              child: Text.rich(
                TextSpan(
                  text: "This session will expire in ",
                  style: TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: "2 minutes.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: GestureDetector(
                onTap: canResend ? () {
                  startTimer();
                } : null,
                child: Text(
                  "Didn't receive a code? Resend Code",
                  style: TextStyle(
                    color: canResend ? Colors.teal : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}