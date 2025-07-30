import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  static SharedPreferences? _sharedPreferences;
  static String isLoggedIn = "logged_in";
  static String token = "token";
  static String isCompleted = "completed";

  PrefUtils() {
    // init();
    SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  void saveValue(String key, String value) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences?.setString(key, value);
  }

  Future<String?> readValue(String key) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences?.getString(key);
  }

  void saveBool(String key, bool value) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences?.setBool(key, value);
  }

  Future<bool?> readBool(String key) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences?.getBool(key);
  }

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    print('SharedPreference Initialized');
  }

  ///will clear all the data stored in preference
  void clearPreferencesData() async {
    _sharedPreferences!.clear();
  }

  Future<void> setThemeData(String value) {
    return _sharedPreferences!.setString('themeData', value);
  }

  String getThemeData() {
    try {
      return _sharedPreferences!.getString('themeData')!;
    } catch (e) {
      return 'primary';
    }
  }

  /*Future<void> saveMyUser(MyUser user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(user.toJson());
    await prefs.setString("my_user", jsonString);
  }

  Future<MyUser?> getMyUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString("my_user");
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return MyUser.fromJson(jsonMap);
    }
    return null;
  }*/

  Future<void> removeMyUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("my_user");
  }
}
    