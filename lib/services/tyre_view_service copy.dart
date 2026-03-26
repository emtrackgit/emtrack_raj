import 'dart:convert';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:emtrack/models/tyre_view_model.dart';
import '../utils/secure_storage.dart'; // 🔹 adjust path if needed

class TyreViewService {
  final String baseUrl =
      "https://emtrackotrapi-staging.azurewebsites.net/api/Tire";

  /// Fetch tyre details by ID (with cookies)
  Future<TyreViewModel> fetchTyreDetailsById(int tireId) async {
    final url = Uri.parse('$baseUrl/GetById/$tireId');

    // 🔹 Get cookie from secure storage
    final cookie = await SecureStorage.getCookie();

    if (cookie == null || cookie.isEmpty) {
      throw Exception("Auth cookie not found. Please login again.");
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie, // ✅ COOKIE SET HERE
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      print("hello jksdklsjfk $jsonMap");
      // 🔹 API response structure:
      // { message, didError, errorMessage, httpStatusCode, model }
      return TyreViewModel.fromJson(jsonMap['model']);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      print("🔐 SESSION EXPIRED");
      Get.find<GlobalLogoutHandler>().forceLogout();
      return fetchTyreDetailsById(tireId);
    } else {
      throw Exception(
        "Failed to load tyre details. Status: ${response.statusCode}",
      );
    }
  }
}
