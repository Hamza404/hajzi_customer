import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../client/api_manager.dart';
import '../../../core/utils/navigator_service.dart';
import '../../../core/utils/pref_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_toast.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState(phoneNumber: null));

  Future<void> login(String phone) async {
    if (phone.isEmpty || phone.length < 10) {
      emit(state.copyWith(errorMessage: 'Please enter a valid phone number.'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await ApiManager.post(
        'Authenticate/UserLogin',
        body: {'phoneNumber': phone},
      );
      emit(state.copyWith(isLoading: false, errorMessage: null));
      if (response != null && response['isSuccess'] == true) {
        final context = NavigatorService.navigatorKey.currentContext;
        if (context != null) {
          CustomToast.show(
            context,
            message: response['message'] ?? 'Success'
          );
        }
        PrefUtils().saveBool(PrefUtils.isCompleted, response['isCompleted'] ?? false);
        
        NavigatorService.pushNamed(AppRoutes.otp, arguments: phone);
      } else {
        emit(state.copyWith(errorMessage: response['message'] ?? 'Login failed. Please try again.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Login failed. Please try again.'));
    }
  }

  Future<void> verifyOtp({required String number, required String pin}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final encodedNumber = Uri.encodeComponent(number);
      final endpoint = 'Authenticate/VerifyUserPIN?number=$encodedNumber&PIN=$pin';
      final response = await ApiManager.get(endpoint);
      emit(state.copyWith(isLoading: false));
      final context = NavigatorService.navigatorKey.currentContext;
      if (response != null && response['isSuccess'] == true && response['token'] != null) {
        PrefUtils().saveValue(PrefUtils.token, response['token']);
        PrefUtils().saveBool(PrefUtils.isLoggedIn, true);
        Global.isLoggedIn = true;
        if (context != null) {
          CustomToast.show(
            context,
            message: 'OTP verified successfully',
            backgroundColor: Colors.green,
          );
          if(response['isProfileCompleted'] == true) {
            NavigatorService.goBack();
            NavigatorService.popWithData('on_refresh');
          } else {
            NavigatorService.pushNamed(AppRoutes.userNameScreen);
          }
        }

      } else {
        if (context != null) {
          CustomToast.show(
            context,
            message: response['message'] ?? 'OTP verification failed',
            backgroundColor: Colors.red,
          );
        }
        emit(state.copyWith(errorMessage: response['message'] ?? 'OTP verification failed'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'OTP verification failed'));
      final context = NavigatorService.navigatorKey.currentContext;
      if (context != null) {
        CustomToast.show(
          context,
          message: 'OTP verification failed',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> updateUser(String name) async {

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await ApiManager.post('User',
        body: {
          'name': name,
          'isCompleted': true
        },
      );
      emit(state.copyWith(isLoading: false, errorMessage: null));

      if (response != null && response["isSuccess"] == true) {
        final context = NavigatorService.navigatorKey.currentContext;
        if (context != null) {
          NavigatorService.goBack();
          NavigatorService.goBack();
          NavigatorService.popWithData('on_refresh');
        }
      } else {
        emit(state.copyWith(errorMessage: response['message'] ?? 'Login failed. Please try again.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Login failed. Please try again.'));
    }
  }

  void logout() {
    emit(AuthState(phoneNumber: null, isLoggedIn: false));
  }

  void updateCountryCode(String code) {
    emit(state.copyWith(selectedCode: code));
  }
}