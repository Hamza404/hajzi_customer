import '../model/category_model.dart';
import '../model/order_model.dart';

class DashboardState {
  final bool isLoading;
  final List<CategoryModel> categories;
  final String? error;
  final bool isOrderLoading;
  final OrderModel? currentOrder;
  final String? orderError;

  DashboardState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
    this.isOrderLoading = false,
    this.currentOrder,
    this.orderError,
  });

  DashboardState copyWith({
    bool? isLoading,
    List<CategoryModel>? categories,
    String? error,
    bool? isOrderLoading,
    OrderModel? currentOrder,
    String? orderError,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: error,
      isOrderLoading: isOrderLoading ?? this.isOrderLoading,
      currentOrder: currentOrder ?? this.currentOrder,
      orderError: orderError ?? this.orderError,
    );
  }
}