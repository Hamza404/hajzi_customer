class UserChatListing {
  final int id;
  final int orderId;
  final String description;
  final bool status;
  final String userName;
  final String businessName;
  final int userId;
  final int businessId;
  final int initiaterType;

  UserChatListing({
    required this.id,
    required this.orderId,
    required this.description,
    required this.status,
    required this.userName,
    required this.businessName,
    required this.userId,
    required this.businessId,
    required this.initiaterType,
  });

  factory UserChatListing.fromJson(Map<String, dynamic> json) {
    return UserChatListing(
      id: json['id'],
      orderId: json['orderId'],
      description: json['description'],
      status: json['status'],
      userName: json['userName'],
      businessName: json['businessName'],
      userId: json['userId'],
      businessId: json['businessId'],
      initiaterType: json['initiaterType'],
    );
  }
}
