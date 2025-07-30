class BusinessDetailModel {
  final String fullName;
  final int numberOfPeople;
  final String mobileNumber;
  final bool getTextMessage;

  BusinessDetailModel({
    this.fullName = '',
    this.numberOfPeople = 1,
    this.mobileNumber = '',
    this.getTextMessage = false,
  });

  BusinessDetailModel copyWith({
    String? fullName,
    int? numberOfPeople,
    String? mobileNumber,
    bool? getTextMessage,
  }) {
    return BusinessDetailModel(
      fullName: fullName ?? this.fullName,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      getTextMessage: getTextMessage ?? this.getTextMessage,
    );
  }
} 