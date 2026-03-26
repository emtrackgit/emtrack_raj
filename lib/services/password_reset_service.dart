import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/password_reset_model.dart';
import '../utils/secure_storage.dart'; // 👈 import your storage file

class PasswordResetService {
  static const String baseUrl =
      "https://emtrackotrapi-staging.azurewebsites.net";

  Future<http.Response> resetPassword(PasswordResetModel model) async {
    final url = Uri.parse("$baseUrl/UserManagement/PasswordReset");

    /// 🔐 Get Auth Headers (Cookie + Content-Type)
    final headers = await SecureStorage.authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    /// 🔄 OPTIONAL: If server sends updated cookie in response
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      await SecureStorage.saveCookie(setCookie);
    }

    return response;
  }
}
