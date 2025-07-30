import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import 'package:hajzi/core/utils/navigator_service.dart';
import 'package:hajzi/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:hajzi/routes/app_routes.dart';
import 'package:hajzi/theme/app_colors.dart';
import '../../theme/font_styles.dart';
import 'bloc/dashboard_cubit.dart';
import 'widgets/pending_order_widget.dart';
import 'widgets/confirmed_order_widget.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (context) => DashboardCubit(),
      child: const DashboardScreen(),
    );
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top: 56, left: 18, right: 18),
            child: Column(
              children: [
                Image.asset('assets/ic_hajzi_banner.png', fit: BoxFit.cover),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        if (state.currentOrder != null) ...[
                          _buildOrderStatusWidget(state.currentOrder!),
                          const SizedBox(height: 10),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'find_service_near_you'.tr,
                                style: FontStyles.fontW800.copyWith(fontSize: 36),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Select your service',
                              style: FontStyles.fontW800.copyWith(fontSize: 20),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        state.isLoading
                            ? _buildShimmerGrid()
                            : _buildCategoryGrid(state),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusWidget(dynamic order) {
    if (order.status.toLowerCase() == 'pending') {
      return PendingOrderWidget(order: order);
    } else if (order.status.toLowerCase() == 'accepted' ||
        order.status.toLowerCase() == 'confirmed') {
      return ConfirmedOrderWidget(order: order);
    }
    return const SizedBox.shrink();
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryGrid(DashboardState state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 5,
        mainAxisSpacing: 8,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        final image = _getCategoryImage(category.id);
        return InkWell(
          onTap: () {
            NavigatorService.pushNamed(
              AppRoutes.searchBusiness,
              arguments: {'categoryId': category.id},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.light_gray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                if (image != null)
                  Positioned(
                    right: 5,
                    child: Image.asset(image, width: 90, height: 90, fit: BoxFit.cover),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              category.name,
                              style: FontStyles.fontW600.copyWith(fontSize: 16),
                              maxLines: 2,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '13',
                            style: FontStyles.fontW400.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _getCategoryImage(int id) {
    switch (id) {
      case 1:
        return 'assets/ic_hair_style.png';
      case 2:
        return 'assets/ic_car_wash.png';
      case 3:
        return 'assets/ic_resturant.png';
      case 4:
        return 'assets/ic_parlour.png';
      case 5:
        return 'assets/ic_massage.png';
      case 6:
        return 'assets/ic_doctor.png';
      default:
        return null;
    }
  }
}