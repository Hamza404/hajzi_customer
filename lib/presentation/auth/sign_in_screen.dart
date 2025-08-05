import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import '../../theme/app_colors.dart';
import '../../theme/font_styles.dart';
import '../../widgets/custom_button.dart';
import 'bloc/auth_cubit.dart';
import 'bloc/auth_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: const SignInScreen(),
    );
  }

  @override
  State<SignInScreen> createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {

  @override
  Widget build(BuildContext context) {

    final TextEditingController phoneController = TextEditingController();
    final codes = ['+966', '+971', '+92', '+1', '+44'];

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    'login_or_sign_up'.tr,
                    textAlign: TextAlign.center,
                    style: FontStyles.fontW800.copyWith(fontSize: 25),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'create_an_account_or_login_message'.tr,
                    textAlign: TextAlign.center,
                    style: FontStyles.fontW400.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: false,
                            value: state.selectedCode,
                            items: codes.map((code) => DropdownMenuItem<String>(
                              value: code,
                              child: Text(code),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                context.read<AuthCubit>().updateCountryCode(value);
                              }
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 48,
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              offset: const Offset(0, -4),
                              elevation: 3,
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(Icons.keyboard_arrow_down_rounded),
                              iconSize: 16,
                              iconEnabledColor: Colors.black,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'phone_number'.tr,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ]
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    title: "send_otp".tr,
                    backgroundColor: Colors.black,
                    textColor: AppColors.white,
                    isLoading: state.isLoading == true,
                    onPressed: () {
                      final fullNumber = '${state.selectedCode}${phoneController.text.trim()}';
                      context.read<AuthCubit>().login(fullNumber);
                    },
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('terms_policy'.tr, style: FontStyles.fontW400.copyWith(fontSize: 11, color: AppColors.blue)),
                      const SizedBox(width: 20),
                      Text('support'.tr, style: FontStyles.fontW400.copyWith(fontSize: 11, color: AppColors.blue)),
                      const SizedBox(width: 20),
                      Text('term_of_use'.tr, style: FontStyles.fontW400.copyWith(fontSize: 11, color: AppColors.blue)),
                    ],
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}