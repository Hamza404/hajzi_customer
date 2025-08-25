import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:hajzi/client/api_manager.dart';
import 'package:hajzi/presentation/profile/model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/category_model.dart';
import '../model/order_model.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState()) {
    updateFCM();
    fetchCategories();
    fetchUserOrder();
    getUserProfile();
  }

  // +923124278280 user
  // +923004666753 business

  Future<void> updateFCM() async {
    final token = await getToken();

    if(token?.isNotEmpty == true) {
      final fcm = await FirebaseMessaging.instance.getToken();
      print("FCM Token: $fcm");
      await ApiManager.get('User/UpdateUserDeviceToken?deviceToken=$fcm');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchCategories() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await ApiManager.get('Order/GetServiceCategories');
      if (response['isSuccess'] == true && response['content'] is List) {
        final categories = (response['content'] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();
        emit(state.copyWith(isLoading: false, categories: categories));
      } else {
        emit(state.copyWith(isLoading: false, error: response['messages']?.toString() ?? 'Unknown error'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> fetchUserOrder() async {
    emit(state.copyWith(isOrderLoading: true, orderError: null));
    try {
      final response = await ApiManager.get('Order/GetUserOrder');
      if (response['isSuccess'] == true && response['content'] is List) {
        final orders = (response['content'] as List);
        if (orders.isNotEmpty) {
          final orders = (response['content'] as List)
              .map((e) => GetOrder.fromJson(e))
              .toList();

          emit(state.copyWith(isOrderLoading: false, currentOrder: orders[0]));
        } else {
          emit(state.copyWith(isOrderLoading: false, currentOrder: null));
        }
      } else {
        emit(state.copyWith(isOrderLoading: false, orderError: response['messages']?.toString() ?? 'Unknown error'));
      }
    } catch (e) {
      emit(state.copyWith(isOrderLoading: false, currentOrder: null));
    }
  }

  Future<void> getUserProfile() async {
    emit(state.copyWith(isProfileLoading: true));
    try {
      final response = await ApiManager.get('User/UserProfile');
      if (response['isSuccess'] == true) {
        emit(state.copyWith(isProfileLoading: false, profileModel: ProfileModel.fromJson(response['content'])));
      } else {
        emit(state.copyWith(isProfileLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isProfileLoading: false, profileModel: null));
    }
  }

  Future<void> resetProfile() async {
    emit(state.copyWith(isProfileLoading: false, profileModel: null));
  }
}