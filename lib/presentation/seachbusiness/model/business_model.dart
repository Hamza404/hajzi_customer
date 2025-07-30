
class BusinessResponseModel {
  final BusinessModel business;
  final List<WorkingHoursModel> workingHours;

  BusinessResponseModel({
    required this.business,
    required this.workingHours,
  });

  factory BusinessResponseModel.fromJson(Map<String, dynamic> json) {
    return BusinessResponseModel(
      business: BusinessModel.fromJson(json['business']),
      workingHours: (json['businessWorkingHours'] as List<dynamic>)
          .map((e) => WorkingHoursModel.fromJson(e))
          .toList(),
    );
  }
}

class BusinessModel {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final int serviceCategoryId;
  final double latitude;
  final double longitude;
  final bool isCompleted;
  final int queuedCount;

  BusinessModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.serviceCategoryId,
    required this.latitude,
    required this.longitude,
    required this.isCompleted,
    required this.queuedCount,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      serviceCategoryId: json['serviceCategoryId'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      isCompleted: json['isCompleted'],
      queuedCount: json['queuedCount'],
    );
  }
}

class WorkingHoursModel {
  final int? id;
  final int? businessId;
  final int? day;
  final String? startTime;
  final String? endTime;

  WorkingHoursModel({
    this.id,
    this.businessId,
    this.day,
    this.startTime,
    this.endTime
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursModel(
      id: json['id'] ?? 0,
      businessId: json['businessId'] ?? 0,
      day: json['day'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? ''
    );
  }
}