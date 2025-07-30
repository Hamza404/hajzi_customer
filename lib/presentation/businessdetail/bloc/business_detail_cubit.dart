import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/utils/navigator_service.dart';
import 'package:hajzi/routes/app_routes.dart';
import '../../../client/api_manager.dart';
import '../../seachbusiness/model/business_model.dart';
import 'business_detail_state.dart';

class BusinessDetailCubit extends Cubit<BusinessDetailState> {
  BusinessDetailCubit({BusinessModel? business}) : super(BusinessDetailState(selectedBusiness: business));

  void updateFullName(String fullName) {
    emit(state.copyWith(
      fullName: fullName,
    ));
  }

  void updateNumberOfPeople(int numberOfPeople) {
    emit(state.copyWith(
      numberOfPeople: numberOfPeople
    ));
  }

  void updateMobileNumber(String mobileNumber) {
    emit(state.copyWith(
      mobileNumber: mobileNumber,
    ));
  }

  void toggleTextMessage(bool value) {
    emit(state.copyWith(
      textMessage: value,
    ));
  }

  void updateDistance(double distance) {
    emit(state.copyWith(distance: distance));
  }

  Future<void> reserveSpot() async {
    if (state.fullName==null) {
      emit(state.copyWith(error: 'Please enter your full name'));
      return;
    }

    if (state.mobileNumber==null) {
      emit(state.copyWith(error: 'Please enter your mobile number'));
      return;
    }

    if (state.numberOfPeople==null) {
      emit(state.copyWith(error: 'Please select number of people'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    final body = {
      'phoneNumber' : state.mobileNumber?.trim(),
      'serviceId' : state.selectedBusiness?.serviceCategoryId.toString(),
      'businessId': state.selectedBusiness?.id.toString(),
      'totalPerson': state.numberOfPeople.toString(),
      'status': 'Pending',
      'name' : state.fullName,
      'amount' : '0'
    };

    try {
      final response = await ApiManager.post('Order', body: body);

      if (response['isSuccess'] == true) {
        emit(state.copyWith(isLoading: false));
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.mainScreen, arguments: 'refresh');
      } else {
        emit(state.copyWith(isLoading: false, error: response['messages']?.toString() ?? 'Unknown error'));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to reserve spot: ${e.toString()}',
      ));
    }
  }

  Future<void> getUser() async {
    final response = await ApiManager.get('User/UserProfile');

    if (response['isSuccess'] == true) {
      final content = response['content'] ?? {};
      emit(state.copyWith(
        fullName: content['name'] ?? '',
        mobileNumber: content['phoneNumber'] ?? '',
      ));
    } else {
      emit(state.copyWith(error: 'User not found'));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
} 