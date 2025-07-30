
import '../../seachbusiness/model/business_detail_model.dart';
import '../../seachbusiness/model/business_model.dart';

class BusinessDetailState {
  final BusinessModel? selectedBusiness;
  final bool isLoading;
  final String? error;
  final double? distance;
  final int? numberOfPeople;
  final String? mobileNumber;
  final String? fullName;
  final bool textMessage;

  BusinessDetailState({
    this.selectedBusiness,
    this.isLoading = false,
    this.error,
    this.distance,
    this.numberOfPeople,
    this.mobileNumber,
    this.textMessage = false,
    this.fullName
  });

  BusinessDetailState copyWith({
    BusinessModel? selectedBusiness,
    bool? isLoading,
    String? error,
    double? distance,
    int? numberOfPeople,
    String? mobileNumber,
    bool? textMessage,
    String? fullName
  }) {
    return BusinessDetailState(
      selectedBusiness: selectedBusiness ?? this.selectedBusiness,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      distance: distance ?? this.distance,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      textMessage: textMessage ?? this.textMessage,
      fullName: fullName ?? this.fullName,
    );
  }
} 