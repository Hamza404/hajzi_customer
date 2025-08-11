import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import 'package:hajzi/widgets/custom_toast.dart';
import '../../theme/app_colors.dart';
import '../../theme/font_styles.dart';
import '../../widgets/custom_button.dart';
import 'bloc/auth_cubit.dart';
import 'bloc/auth_state.dart';

class UserNameScreen extends StatelessWidget {
  const UserNameScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: const UserNameScreen()
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController userNameController = TextEditingController();

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
                  _buildBanner(),
                  const SizedBox(height: 60),
                  Text(
                    'Let’s personalize your experience.'.tr,
                    textAlign: TextAlign.center,
                    style: FontStyles.fontW800.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us your full name to get started.'.tr,
                    textAlign: TextAlign.center,
                    style: FontStyles.fontW400.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              textCapitalization: TextCapitalization.words,
                              controller: userNameController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: 'Full Name*',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ]
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    title: "Submit",
                    backgroundColor: Colors.black,
                    textColor: AppColors.white,
                    isLoading: state.isLoading == true,
                    onPressed: () {
                      if(userNameController.text.isEmpty) {
                        CustomToast.show(context, message: 'Please enter your name.');
                      } else {
                        context.read<AuthCubit>().updateUser(userNameController.text.trim());
                      }
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56),
      child: Image.asset('assets/ic_hajzi_banner.png', fit: BoxFit.cover),
    );
  }
}