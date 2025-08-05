class ProfileModel {
  final int id;
  final String name;
  final String phoneNumber;
  final bool isCompleted;

  ProfileModel({required this.id, required this.name, required this.phoneNumber, required this.isCompleted});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      isCompleted: json['isCompleted'],
    );
  }
}