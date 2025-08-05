import '../../profile/model/profile_model.dart';
import '../model/category_model.dart';
import '../model/order_model.dart';

class DashboardState {
  final bool isLoading;
  final List<CategoryModel> categories;
  final String? error;
  final bool isOrderLoading;
  final GetOrder? currentOrder;
  final String? orderError;

  final ProfileModel? profileModel;
  final bool isProfileLoading;
  final bool unauthorized;

  DashboardState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
    this.isOrderLoading = false,
    this.currentOrder,
    this.orderError,
    this.profileModel, this.isProfileLoading = false, this.unauthorized = false
  });

  DashboardState copyWith({
    bool? isLoading,
    List<CategoryModel>? categories,
    String? error,
    bool? isOrderLoading,
    GetOrder? currentOrder,
    String? orderError,
    ProfileModel? profileModel, bool? isProfileLoading, bool? unauthorized
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: error,
      isOrderLoading: isOrderLoading ?? this.isOrderLoading,
      currentOrder: currentOrder ?? this.currentOrder,
      orderError: orderError ?? this.orderError,
      profileModel: profileModel ?? this.profileModel,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      unauthorized: unauthorized ?? this.unauthorized,
    );
  }
}