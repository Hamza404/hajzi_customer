import 'package:hajzi/presentation/seachbusiness/model/business_model.dart';

class GetOrder {
  final OrderModel orders;
  final BusinessModel business;

  GetOrder({
    required this.orders,
    required this.business,
  });

  factory GetOrder.fromJson(Map<String, dynamic> json) {
    return GetOrder(
      orders: OrderModel.fromJson(json['order'] ?? {}),
      business: BusinessModel.fromJson(json['business'] ?? {}),
    );
  }
}

class OrderModel {
  final int id;
  final String phoneNumber;
  final int serviceId;
  final int businessId;
  final String status;
  final int totalPerson;
  final String name;
  final double amount;

  OrderModel({
    required this.id,
    required this.phoneNumber,
    required this.serviceId,
    required this.businessId,
    required this.status,
    required this.totalPerson,
    required this.name,
    required this.amount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      serviceId: json['serviceId'] ?? 0,
      businessId: json['businessId'] ?? 0,
      status: json['status'] ?? '',
      totalPerson: json['totalPerson'] ?? 0,
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}