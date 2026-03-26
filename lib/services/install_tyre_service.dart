import 'dart:convert';
import 'package:emtrack/services/api_constants.dart';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class InstallTyreService {
  Future<bool> submitInspection(Map<String, dynamic> data) async {
    try {
      final cookie = await SecureStorage.getCookie();
      print("🔐 INSTALL COOKIE => $cookie");

      if (cookie == null || cookie.isEmpty) {
        throw Exception("Session expired. Please login again.");
      }

      if (data.containsKey("inspectionDate") &&
          data["inspectionDate"] is DateTime) {
        data["inspectionDate"] =
            '${(data["inspectionDate"] as DateTime).toUtc().toIso8601String().split('.').first}Z';
      }

      final url = Uri.parse(
        "${ApiConstants.baseUrl}/api/Inspection/InstallTire",
      );
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Cookie": cookie,
      };

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      // 🔥 Temporary test fix
      data.remove("inspectionId");
      data.remove("removalReasonId");

      print("📡 STATUS: ${response.statusCode}");
      print("📥 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded["didError"] == false) return true;
        throw Exception(
          decoded["errorMessage"] ??
              "Backend returned an error without message.",
        );
      }

      if (response.statusCode == 401) {
        await SecureStorage.clearCookie();
        throw Exception("Session expired. Please login again.");
      }

      final fallback = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/api/Inspection/InstallTire"),
        headers: headers,
        body: jsonEncode(data),
      );
      print("RAW JSON => ${jsonEncode(data)}");

      print("📡 RETRY STATUS: ${fallback.statusCode}");
      print("📥 RETRY BODY: ${fallback.body}");

      if (fallback.statusCode == 200) {
        final decoded = jsonDecode(fallback.body);

        if (decoded["didError"] == false) return true;
        throw Exception(
          decoded["errorMessage"] ??
              "Backend returned an error without message.",
        );
      }

      throw Exception(
        "Failed with status code ${response.statusCode}: ${response.reasonPhrase}",
      );
    } catch (e) {
      print("❌ Install Tire API Error: $e");
      rethrow;
    }
  }
}
