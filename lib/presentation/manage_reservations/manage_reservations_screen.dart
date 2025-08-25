import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/constants/constants.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import 'package:hajzi/presentation/dashboard/model/order_model.dart';
import 'package:hajzi/theme/app_colors.dart';
import 'package:hajzi/theme/font_styles.dart';
import '../../core/utils/navigator_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import 'bloc/manage_reservations_cubit.dart';
import 'bloc/manage_reservations_state.dart';

class ManageReservationsScreen extends StatelessWidget {
  const ManageReservationsScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<ManageReservationsCubit>(
      create: (context) => ManageReservationsCubit(),
      child: const ManageReservationsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageReservationsCubit, ManageReservationsState>(
      builder: (context, state) {
        return Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
                padding: const EdgeInsets.only(top: 56, left: 18, right: 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('manage_your_reservations'.tr, style: FontStyles.fontW800.copyWith(fontSize: 36)))
                      ],
                    ),
                    state.isLoading ? const Center(child: CircularProgressIndicator(color: Colors.black))
                        : Expanded(
                        child: RefreshIndicator(
                          color: Colors.black,
                          onRefresh: () => context.read<ManageReservationsCubit>().refreshOrders(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),

                                if (state.pendingOrders.isEmpty &&
                                    state.queuedOrders.isEmpty &&
                                    state.payedOrders.isEmpty &&
                                    state.completedOrders.isEmpty) ... [
                                      Column(
                                        children: [
                                          Icon(Icons.queue, size: 44, color: Colors.grey[600]),
                                          const SizedBox(height: 14),
                                          Text(
                                            'no_reservations_found'.tr,
                                            style: FontStyles.fontW500.copyWith(
                                                fontSize: 16, color: Colors.grey[600]),
                                          )
                                        ],
                                      )
                                ]
                                else ...[
                                  _buildStatusSection(context, 'pending'.tr, state.pendingOrders, _buildPendingCard),
                                  _buildStatusSection(context, 'queued'.tr, state.queuedOrders, _buildQueuedCard),
                                  _buildStatusSection(context, 'confirmed'.tr, state.payedOrders, _buildConfirmCard),
                                  _buildStatusSection(context, 'cancelled'.tr, state.cancelled, _buildCancelledCard),
                                  _buildStatusSection(context, 'completed'.tr, state.completedOrders, _buildCompletedCard),
                                ],

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        )
                    )
                  ],
                )
            )
        );
      },
    );
  }

  Widget _buildStatusSection(BuildContext context, String title, List<GetOrder> orders, Widget Function(GetOrder, BuildContext) cardBuilder) {
    if (orders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: FontStyles.fontW600.copyWith(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 10),
        ...orders.map((order) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: cardBuilder(order, context),
        )),
      ],
    );
  }

  Widget _buildPendingCard(GetOrder order, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.light_gray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.8,
          )
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.business.name,
                  style: FontStyles.fontW700.copyWith(fontSize: 18),
                ),
                Text(
                  Constants.getServiceNameById(order.business.serviceCategoryId),
                  style: FontStyles.fontW400.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 58,
                height: 78,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),

                    Text(
                      'cancel'.tr,
                      style: FontStyles.fontW800.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQueuedCard(GetOrder order, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.light_gray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.8,
          )
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.business.name,
                      style: FontStyles.fontW700.copyWith(fontSize: 18),
                    ),
                    Text(Constants.getServiceNameById(order.business.serviceCategoryId),
                      style: FontStyles.fontW400.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 58,
                    height: 78,
                    decoration: BoxDecoration(
                      color: AppColors.dim_gray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          order.orders.totalPerson.toString(),
                          style: FontStyles.fontW600.copyWith(
                            fontSize: 20,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.person,
                          color: AppColors.blue,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(title: 'chat'.tr, onPressed: () {
            NavigatorService.pushNamed(AppRoutes.chatScreen, arguments: order.orders.id);
          }, backgroundColor: Colors.black, textColor: Colors.white)
        ],
      ),
    );
  }

  Widget _buildConfirmCard(GetOrder order, BuildContext context) {
    final cubit = context.read<ManageReservationsCubit>();
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.light_gray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 0.8,
            )
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.business.name,
                        style: FontStyles.fontW700.copyWith(fontSize: 18),
                      ),
                      Text(
                        Constants.getServiceNameById(order.business.serviceCategoryId),
                        style: FontStyles.fontW400.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 78,
                      decoration: BoxDecoration(
                        color: AppColors.dim_gray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.blue,
                            size: 20,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            order.business.address,
                            style: FontStyles.fontW800.copyWith(
                              fontSize: 9,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () {
                  NavigatorService.pushNamed(AppRoutes.payment, arguments: order.orders).then((onValue) {
                    if(onValue == 'onRefresh') {
                      cubit.refreshOrders();
                    }
                  });
                },
                title: 'proceed_to_pay'.tr,
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
            )
          ],
        )
    );
  }

  Widget _buildCancelledCard(GetOrder order, BuildContext context) {
    final cubit = context.read<ManageReservationsCubit>();
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.light_gray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 0.8,
            )
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.business.name,
                        style: FontStyles.fontW700.copyWith(fontSize: 18),
                      ),
                      Text(
                        Constants.getServiceNameById(order.business.serviceCategoryId),
                        style: FontStyles.fontW400.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 58,
                      height: 78,
                      decoration: BoxDecoration(
                        color: AppColors.dim_gray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.blue,
                            size: 20,
                          ),

                          Text(
                            order.business.address,
                            style: FontStyles.fontW800.copyWith(
                              fontSize: 11,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        )
    );
  }

  Widget _buildCompletedCard(GetOrder order, BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF1877F2),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.business.name,
                        style: FontStyles.fontW600.copyWith(fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        Constants.getServiceNameById(order.business.serviceCategoryId),
                        style: FontStyles.fontW400.copyWith(fontSize: 12, color: Colors.white),
                      ),
                      Text(
                        order.business.address,
                        style: FontStyles.fontW400.copyWith(fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SAR ${order.orders.amount.toStringAsFixed(0)}',
                        style: FontStyles.fontW800.copyWith(
                          fontSize: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset('assets/ic_completed_tick.png', width: 48, height: 48)
              ],
            )
          ],
        )
    );
  }
}