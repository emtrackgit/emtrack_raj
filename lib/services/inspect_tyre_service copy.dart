import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import 'global_logout_handler.dart';

class InspectTyreService {
  final String baseUrl = "https://emtrackotrapi-staging.azurewebsites.net";

  /// 🔹 PUT : Inspect Tire
  Future<bool> submitInspection(Map<String, dynamic> data) async {
    try {
      final cookie = await SecureStorage.getCookie();

      if (cookie == null || cookie.isEmpty) {
        throw Exception("Auth cookie missing");
      }

      final url = Uri.parse('$baseUrl/api/Inspection/InspectTire');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': cookie,
        },
        body: jsonEncode(data),
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📥 BODY: ${response.body}");

      /// ✅ SUCCESS
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        /// backend pattern: didError = false
        if (decoded is Map && decoded['didError'] == false) {
          return true;
        }

        throw Exception(decoded['errorMessage'] ?? 'Inspection failed');
      }

      /// 🔐 SESSION EXPIRED
      if (response.statusCode == 401 || response.statusCode == 403) {
        Get.find<GlobalLogoutHandler>().forceLogout();
        return false;
      }

      /// ⚠️ CUSTOM / BUSINESS ERROR (like 103)
      if (response.statusCode == 103) {
        throw Exception("Inspection validation failed (103)");
      }

      /// ❌ OTHER ERRORS
      throw Exception(
        "Failed to submit inspection. Status: ${response.statusCode}",
      );
    } catch (e) {
      print("❌ Inspect API Error: $e");
      rethrow;
    }
  }
}
