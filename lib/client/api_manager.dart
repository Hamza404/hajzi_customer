import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static String userId = "";
  static bool isLoggedIn = false;
  static String VIDEO_URL = "";
  static int IS_ALLOWED = 1;
}

class ApiManager {
  static const String baseUrl = 'https://hajziuser.xpertbs.com/api/';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await getToken();
    final url = Uri.parse(baseUrl + endpoint);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    print('request_api => $body');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get data: ${response.body}');
    }
  }

  static Future<dynamic> get(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse(baseUrl + endpoint);
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get data: ${response.statusCode}');
    }
  }

  static String buildQueryString(Map<String, dynamic> params) {
    return params.entries.map((entry) => '${entry.key}=${entry.value}').join('&');
  }
}