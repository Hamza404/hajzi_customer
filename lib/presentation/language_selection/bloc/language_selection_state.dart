class LanguageSelectionState {
  final String selectedLanguage;

  LanguageSelectionState({this.selectedLanguage = 'en'});

  LanguageSelectionState copyWith({String? selectedLanguage}) {
    return LanguageSelectionState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
} 