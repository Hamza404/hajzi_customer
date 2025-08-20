class ChatMessage {
  final int messageFrom;
  final int messageTo;
  final int chatId;
  final String messageText;
  final String sentTime;
  final DateTime? readTime;

  ChatMessage({
    required this.messageFrom,
    required this.messageTo,
    required this.chatId,
    required this.messageText,
    required this.sentTime,
    this.readTime,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageFrom: json['messageFrom'],
      messageTo: json['messageTo'],
      chatId: json['chatId'],
      messageText: json['messageText'],
      sentTime: json['sentTime'] ?? '',
      readTime: json['readTime'] != null ? DateTime.parse(json['readTime']) : null,
    );
  }
}

class ChatInitiate {
  final int id;
  final int orderId;
  final int userId;
  final int businessId;
  bool status;
  final String userName;
  final String businessName;

  ChatInitiate({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.businessId,
    required this.status,
    this.userName = '',
    this.businessName = ''
  });

  factory ChatInitiate.fromJson(Map<String, dynamic> json) {
    return ChatInitiate(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      businessId: json['businessId'] ?? 0,
      status: json['status'] ?? false,
      userName: json['userName'] ?? '',
      businessName: json['businessName'] ?? '',
    );
  }
}