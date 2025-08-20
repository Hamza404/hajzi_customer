import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import '../../core/utils/navigator_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/font_styles.dart';
import '../../widgets/custom_button.dart';
import 'bloc/language_selection_cubit.dart';
import 'bloc/language_selection_state.dart';
import '../../core/localization/locale_cubit.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<LanguageSelectionCubit>(
      create: (context) => LanguageSelectionCubit(),
      child: const LanguageSelectionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageSelectionCubit, LanguageSelectionState>(
      builder: (context, state) {
        final cubit = context.read<LanguageSelectionCubit>();
        return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(),
                Text(
                  'Select the language',
                  style: FontStyles.fontW800.copyWith(
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                Directionality(textDirection: TextDirection.ltr, child: Row(
                  children: [
                    Expanded(
                      child: _buildLanguageButton(
                        context,
                        cubit,
                        state,
                        'English',
                        'en',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageButton(
                        context,
                        cubit,
                        state,
                        'عربي',
                        'ar',
                      ),
                    ),
                  ],
                )),
                const Spacer(),
                CustomButton(
                  title: 'next'.tr,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<LocaleCubit>().setLocale(Locale(state.selectedLanguage));
                    NavigatorService.pushNamed(AppRoutes.mainScreen);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageButton(
      BuildContext context,
      LanguageSelectionCubit cubit,
      LanguageSelectionState state,
      String languageName,
      String languageCode,
      ) {
    final isSelected = state.selectedLanguage == languageCode;

    return GestureDetector(
      onTap: () async {
        await cubit.selectLanguage(languageCode);
        //context.read<LocaleCubit>().setLocale(Locale(languageCode));
      },
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black,
            width: 1.5,
          ),
        ),
        child: Text(
          languageName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

} 