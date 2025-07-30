import 'package:shared_preferences/shared_preferences.dart';
import '../utils/navigator_service.dart';
import 'de_de/ar_translations.dart';
import 'en_us/en_translations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

class AppLocalization {
  AppLocalization(this.locale);

  Locale locale;

  static final Map<String, Map<String, String>> _localizedValues = {'en': enUs, 'ar': arSA};

  static AppLocalization of() {
    return Localizations.of<AppLocalization>(
        NavigatorService.navigatorKey.currentContext!, AppLocalization)!;
  }

  static List<String> languages() => _localizedValues.keys.toList();
  String getString(String text) {
    final langCode = locale.languageCode;
    if (_localizedValues.containsKey(langCode)) {
      return _localizedValues[langCode]![text] ?? text;
    }
    return text;
  }

  static Future<Locale> getSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageSelection') ?? 'en';
    return Locale(languageCode);
    return Locale('ar');
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalization.languages().contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) {
    return SynchronousFuture<AppLocalization>(AppLocalization(locale));
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

extension LocalizationExtension on String {
  String get tr => AppLocalization.of().getString(this);
}
