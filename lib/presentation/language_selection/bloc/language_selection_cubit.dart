import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/pref_utils.dart';
import 'language_selection_state.dart';

class LanguageSelectionCubit extends Cubit<LanguageSelectionState> {
  LanguageSelectionCubit() : super(LanguageSelectionState(selectedLanguage: 'en')) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLang = await PrefUtils().readValue(PrefUtils.language);
    emit(state.copyWith(selectedLanguage: savedLang ?? 'en'));
  }

  Future<void> selectLanguage(String code) async {
    PrefUtils().saveValue(PrefUtils.language, code);
    emit(state.copyWith(selectedLanguage: code));
  }
}