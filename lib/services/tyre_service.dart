import 'dart:convert';
import 'package:emtrack/models/tyre_model.dart';
import 'package:emtrack/models/tyre_responsive_model.dart';
import 'package:emtrack/models/view_tyre_response.dart';
import 'package:emtrack/services/api_constants.dart';
import 'package:emtrack/services/api_service.dart';
import 'package:emtrack/services/global_logout_handler.dart';
import 'package:emtrack/utils/secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TyreService {
  // 🔹 GET BY ID URL
  static String get _getByIdUrl =>
      "${ApiConstants.baseUrl + ApiConstants.getTyresByAccount}/";

  /// Fetch tyre by Account
  Future<List<TyreModel>> getTyresByAccount(int accountId) async {
    try {
      print("🔥 TyreService.getTyreById called with ID: $accountId");

      // ✅ Read cookie
      final cookie = await SecureStorage.getCookie();
      if (cookie == null || cookie.isEmpty) {
        print("⚠️ Cookie not found or empty");
        throw Exception("Session expired. Please login again.");
      }
      print("📦 Using cookie: $cookie");

      // ✅ Prepare URL
      final url = Uri.parse("$_getByIdUrl$accountId");
      print("🌐 Request URL: $url");

      // ✅ Send GET request
      final response = await http.get(
        url,
        headers: {"Accept": "application/json", "Cookie": cookie},
      );

      print("STATUS => ${response.statusCode}");
      print("BODY => ${response.body}");

      // ✅ Success
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // 🔹 Parse response into model
        final tyreResponse = TyreResponseModel.fromJson(decoded);
        print("Decoded TyreResponseModel: $tyreResponse");

        // 🔹 Check API-level error
        if (tyreResponse.didError) {
          print("❌ API Error: ${tyreResponse.errorMessage}");
          throw Exception(tyreResponse.errorMessage ?? "API returned an error");
        }

        print(
          "✅ Tyres fetched successfully, count: ${tyreResponse.model.length}",
        );
        return tyreResponse.model;
      }

      // ✅ Unauthorized
      if (response.statusCode == 401 || response.statusCode == 403) {
        print("⚠️ Unauthorized access");
        print("🔐 SESSION EXPIRED");
        Get.find<GlobalLogoutHandler>().forceLogout();
        return [];
      }

      // ✅ Other errors
      print("❌ Failed to fetch tyre: ${response.statusCode}");
      throw Exception(
        "Failed to fetch tyre: ${response.statusCode} => ${response.body}",
      );
    } catch (e, stacktrace) {
      // ✅ Catch all exceptions and print stacktrace for debugging
      print("🔥 Exception in TyreService.getTyreById:");
      print(e);
      print(stacktrace);
      rethrow; // Propagate exception to caller
    }
  }

  Future<List<TyreModel>> getTyresById(int tireId) async {
    try {
      print("🔥 TyreService.getTyreById called with ID: $tireId");

      final response = await ApiService.getApi(
        endpoint: '${ApiConstants.getTyreById}$tireId',
      );

      if (response == null) {
        throw Exception("Empty API response");
      }

      final tyreResponse = TyreResponseModel.fromJson(response);

      if (tyreResponse.didError) {
        print("❌ API Error: ${tyreResponse.errorMessage}");
        throw Exception(tyreResponse.errorMessage ?? "API returned an error");
      }

      print("✅ Tyres fetched successfully: ${tyreResponse.model.length}");

      return tyreResponse.model;
    } catch (e, stacktrace) {
      print("🔥 Exception in TyreService.getTyreById:");
      print(e);
      print(stacktrace);
      rethrow;
    }
  }

  Future<ViewModel> cloneTyresById(int tireId) async {
    try {
      final response = await ApiService.getApi(
        endpoint: '${ApiConstants.getTyreById}$tireId',
      );

      if (response == null) {
        throw Exception("Empty API response");
      }

      final tyreResponse = ViewTyreResponse.fromJson(response);

      if (tyreResponse.didError) {
        throw Exception(tyreResponse.errorMessage);
      }

      return tyreResponse.viewModel; // ⭐ SINGLE OBJECT
    } catch (e) {
      rethrow;
    }
  }
}
