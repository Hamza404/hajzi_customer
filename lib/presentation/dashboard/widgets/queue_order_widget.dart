import 'package:flutter/material.dart';
import 'package:hajzi/theme/app_colors.dart';
import 'package:hajzi/theme/font_styles.dart';
import '../../../core/constants/constants.dart';
import '../model/order_model.dart';

class QueueOrderWidget extends StatelessWidget {
  final GetOrder order;

  const QueueOrderWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.business.name,
                          style: FontStyles.fontW600.copyWith(fontSize: 16),
                        ),
                        Text(
                          Constants.getServiceNameById(order.orders.serviceId),
                          style: FontStyles.fontW900.copyWith(fontSize: 25),
                        ),
                      ],
                    ))
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  order.orders.positionInQueue == 1 ? Icons.push_pin : Icons.access_alarms_sharp,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          if(order.orders.positionInQueue == 1) ... [
            Text(
              'Your spot is Next',
              style: FontStyles.fontW800.copyWith(fontSize: 25),
            ),
          ],
          const SizedBox(height: 5),

          Row(
            children: List.generate(4, (index) {
              final isCompleted = index < (order.orders.positionInQueue == 1 ? 4  : 3);
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          if(order.orders.positionInQueue > 1)
            Row(
              children: [
                Text(
                  'Your 7ajzi number:',
                  style: FontStyles.fontW700.copyWith(fontSize: 18),
                ),
                const Spacer(),
                Text(
                  order.orders.positionInQueue.toString(),
                  style: FontStyles.fontW700.copyWith(fontSize: 18),
                ),
              ],
            ),
          if(order.orders.positionInQueue == 0)
            Text(
              'You are in Queue',
              style: FontStyles.fontW700.copyWith(fontSize: 18),
            ),
          if(order.orders.positionInQueue > 1)
            Text(
            'We will notify you when your turn will come',
            style: FontStyles.fontW400.copyWith(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }
}