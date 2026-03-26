import 'dart:convert';
import 'package:emtrack/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:emtrack/utils/secure_storage.dart';
import 'package:emtrack/models/user_models.dart';
import 'package:emtrack/services/api_constants.dart';

import '../models/role/profile_model.dart';

class AuthService {
  // ******** LOGIN FUNCTION ********
  static Future<UserModel?> login(String username, String password) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.login);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({"username": username, "password": password}),
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      // print("🔐 SESSION EXPIRED");
      // Get.find<GlobalLogoutHandler>().forceLogout();
      return null;
    }
    final rawCookie = response.headers['set-cookie'];
    String? authCookie;

    if (rawCookie != null) {
      // Take only name=value part (before first ;)
      authCookie = rawCookie.split(';').first;

      await SecureStorage.saveCookie(authCookie);

      print("🍪 CLEAN COOKIE SAVED 👉 $authCookie");
    }

    print("LOGIN STATUS 👉 ${response.statusCode}");
    print("BODY 👉 ${response.body}");

    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final json = jsonDecode(response.body);
    if (json['message'] != null &&
        json['message'].toString().toLowerCase().contains('access granted')) {
      return UserModel.fromJson(json);
    }

    return null;
  }

  // ******** LOGOUT FUNCTION ********
  static Future<bool> logout() async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.logout);
    final cookie = await SecureStorage.getCookie();
    // final xsrfToken = await SecureStorage.getXsrfToken();

    final response = await http.post(
      url,
      headers: {if (cookie != null) 'Cookie': cookie},
    );

    await SecureStorage.clearCookie();

    print("LOGOUT STATUS 👉 ${response.statusCode}");
    print("LOGOUT BODY 👉 ${response.body}");

    return response.statusCode == 200;
  }

  static Future<UserProfile?> getUserprofile() async {
    final response = await ApiService.getApi(
      endpoint: ApiConstants.getUserProfile,
    );

    final json = response;

    if (json['model'] != null) {
      UserProfile user = UserProfile.fromJson(json['model']);

      return user;
    }

    return null;
  }
}
