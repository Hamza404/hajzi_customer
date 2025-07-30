class AuthState {
  final String? phoneNumber;
  final bool? isLoading;
  final bool isLoggedIn;
  String selectedCode;
  final String? errorMessage;
  final bool? isCompleted;

  AuthState({
    required this.phoneNumber,
    this.isLoading,
    this.isLoggedIn = false,
    this.selectedCode = '+971',
    this.errorMessage,
    this.isCompleted
  });

  AuthState copyWith({
    String? phoneNumber,
    bool? isLoading,
    bool? isLoggedIn,
    String? selectedCode,
    String? errorMessage,
    bool? isCompleted
  }) {
    return AuthState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      selectedCode: selectedCode ?? this.selectedCode,
      errorMessage: errorMessage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}